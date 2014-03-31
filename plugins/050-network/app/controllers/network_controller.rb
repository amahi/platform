# Amahi Home Server
# Copyright (C) 2007-2013 Amahi
#

require 'leases'
require 'yajl'
class NetworkController < ApplicationController
  KIND = Setting::NETWORK
  before_filter :admin_required
  before_filter :set_page_title

  def index
    @leases = use_sample_data? ? SampleData.load('leases') : Leases.all
  end

  def hosts
    get_hosts
  end

  def create_host
    sleep 2 if development?
    @host = Host.create params[:host]
    get_hosts
  end

  def destroy_host
    sleep 2 if development?
    @host = Host.find params[:id]
    @host.destroy
    render json: {:status=>:ok,id: @host.id }
  end

  def dns_aliases
    get_dns_aliases
  end

  def create_dns_alias
    sleep 2 if development?
    @dns_alias = DnsAlias.create params[:dns_alias]
    get_dns_aliases
  end

  def destroy_dns_alias
    sleep 2 if development?
    @dns_alias = DnsAlias.find params[:id]
    @dns_alias.destroy
    render json: { :status=>:ok, id: @dns_alias.id }
  end

  def settings
    @net = Setting.get 'net'
    @dns = Setting.find_or_create_by(KIND, 'dns', 'opendns')
    @dns_ip_1, @dns_ip_2 = DnsIpSetting.custom_dns_ips
    @dnsmasq_dhcp = Setting.find_or_create_by(KIND, 'dnsmasq_dhcp', '1')
    @dnsmasq_dns = Setting.find_or_create_by(KIND, 'dnsmasq_dns', '1')
    @lease_time = Setting.get("lease_time") || "14400"
    @gateway = Setting.find_or_create_by(KIND, 'gateway', '1').value
  end

  def update_dns
    sleep 2 if development?
    case params[:setting_dns]
    when 'opendns', 'google', 'opennic'
      @saved = Setting.set("dns", params[:setting_dns], KIND)
      system("hda-ctl-hup")
    else
      @saved = true
    end
    render :json => { :status => @saved ? :ok : :not_acceptable }
  end

  def update_dns_ips
    sleep 2 if development?
    Setting.transaction do
      @ip_1_saved = DnsIpSetting.set("dns_ip_1", params[:dns_ip_1], KIND)
      @ip_2_saved = DnsIpSetting.set("dns_ip_2", params[:dns_ip_2], KIND)
      Setting.set("dns", 'custom', KIND)
      system("hda-ctl-hup")
    end
    if @ip_1_saved && @ip_2_saved
      render json: {status: :ok}
    else
      render json: {status: :not_acceptable, ip_1_saved: @ip_1_saved, ip_2_saved: @ip_2_saved}
    end
  end

  def update_lease_time
    sleep 2 if development?
    @saved = params[:lease_time].present? && params[:lease_time].to_i > 0 ? Setting.set("lease_time", params[:lease_time], KIND) : false
    render :json => { :status => @saved ? :ok : :not_acceptable }
    system("hda-ctl-hup")
  end

  def update_gateway
    sleep 2 if development?
    @saved = params[:gateway].to_i > 0 && params[:gateway].to_i < 255 ? Setting.set("gateway", params[:gateway], KIND) : false
    if @saved
      @net = Setting.get 'net'
      render json: { status: :ok, data: @net + '.' + params[:gateway] }
    else
      render json: { status: :not_acceptable }
    end
  end

  def toggle_setting
		sleep 2 if development?
		id = params[:id]
		s = Setting.find id
		s.value = (1 - s.value.to_i).to_s
		if s.save
			render json: { status: 'ok' }
			system("hda-ctl-hup")
		else
			render json: { status: 'error' }
		end
  end

  def statistics
    if !development?
      if(params[:stats])
        #Authentication
        r = Excon.post "http://#{params[:host]}/cgi-bin/luci?status=1", 
               :body => "username=#{params[:username]}&password=#{params[:password]}",
               :headers => { 'Content-Type' => 'application/x-www-form-urlencoded' }

        parser = Yajl::Parser.new
        
        @parsed_auth_details = pp parser.parse(r.body)
        
        sysauth, path = r.headers['Set-Cookie'].split
        path = path.split('=')[1..-1].join('=')

        #Network Traffic
        r = Excon.get "http://192.168.66.1/#{path}/admin/status/realtime/bandwidth_status/eth0.1", 
              :headers => { 'Cookie' => sysauth }
        @parsed_network_traffic = pp parser.parse(r.body)

        #System Load
        r = Excon.get "http://#{host}/#{path}/admin/status/realtime/load_status", 
              :headers => { 'Cookie' => sysauth }
        @parsed_system_load = pp parser.parse(r.body)

        #Connection Status

        r = Excon.get "http://#{host}/#{path}/admin/status/realtime/connections_status", 
              :headers => { 'Cookie' => sysauth }

        r.body.gsub! /(connections|statistics)/, '"\\1"'
        @parsed_connection_status = pp parser.parse(r.body)

        #Web Interface Status
        r = Excon.get "http://#{host}/#{path}/admin/status/realtime/wireless_status/wl0", 
              :headers => { 'Cookie' => sysauth }
        @parsed_web_interface_status = pp parser.parse(r.body)

      end
    else
      
      @chart2 = LazyHighCharts::HighChart.new('line_ajax') do |f|
        f.chart({ type: 'line',
                marginRight: 130,
                marginBottom: 25 })
        f.title(:text => "Network Traffic Graph")
        f.xAxis(:title => {:text => "Time"},:categories => [ Time.at(1358095466),Time.at(1358095467)])
        f.series(:name => "Data packets Transmitted", data: [101161697,101161703] )
        f.series(:name => "Data packets Received",  :data => [62541131,62541137] )

        f.yAxis({
        title: {
          text: 'Data Packets'
        },
        plotLines: [{
          value: 0,
          width: 1,
          color: '#808080'
        }]
      })
        f.legend({
        layout: 'vertical',
        align: 'right',
        verticalAlign: 'top',
        x: -10,
        y: 100,
        borderWidth: 0
      })
      end
    render 'stats_graph'
    end
  end

private
  def set_page_title
    @page_title = t('network')
  end

  def get_hosts
    @hosts = Host.order('name ASC')
    @net = Setting.get 'net'
  end

  def get_dns_aliases
    @dns_aliases = DnsAlias.order('name ASC')
    @net = Setting.get 'net'
  end
end
