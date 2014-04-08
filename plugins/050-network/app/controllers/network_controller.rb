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
    unless @advanced
      redirect_to network_engine_path
    else
      get_dns_aliases
    end
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
    unless @advanced
      redirect_to network_engine_path
    else
      @net = Setting.get 'net'
      @dns = Setting.find_or_create_by(KIND, 'dns', 'opendns')
      @dns_ip_1, @dns_ip_2 = DnsIpSetting.custom_dns_ips
      @dnsmasq_dhcp = Setting.find_or_create_by(KIND, 'dnsmasq_dhcp', '1')
      @dnsmasq_dns = Setting.find_or_create_by(KIND, 'dnsmasq_dns', '1')
      @lease_time = Setting.get("lease_time") || "14400"
      @gateway = Setting.find_or_create_by(KIND, 'gateway', '1').value
    end
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
        @env = "production"
        #Authentication
        r = Excon.post "http://#{params[:stats][:host]}/cgi-bin/luci?status=1", 
               :body => "username=#{params[:stats][:username]}&password=#{params[:stats][:password]}",
               :headers => { 'Content-Type' => 'application/x-www-form-urlencoded' }

        parser = Yajl::Parser.new
        @network_traffic_status = r.status
        if !r.status == 404
            sysauth, path = r.headers['Set-Cookie'].split
            path = path.split('=')[1..-1].join('=')

            #Network Traffic
            r = Excon.get "http://192.168.66.1/#{path}/admin/status/realtime/bandwidth_status/eth0.1", 
                  :headers => { 'Cookie' => sysauth }
            rx_bytes = []
            time = []
            tx_bytes = []
            @parsed_network_traffic = pp parser.parse(r.body)
            @parsed_system_load.each do |u|
              rx_bytes.push(u[1])
              tx_bytes.push(u[3])
            end
            rx = []
            rx_bytes.each_cons(2) do |i,j|
              rx << j-i
            end
            tx = []
            tx_bytes.each_cons(2) do |i,j|
              tx << j-i
            end
          @chart_network_traffic = LazyHighCharts::HighChart.new('line_ajax') do |f|
            f.chart({ type: 'line',
                    marginRight: 170,
                    marginBottom: 100 })
            f.title(:text => "Network Traffic Graph")
            f.xAxis(:title => {:text => "Time"},:categories => ['1','5','10','15','20','25','30'] )
            f.series(:name => "Data bytes Transmitted", data: tx )
            f.series(:name => "Data bytes Received",  :data => rx )

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
        end

        #System Load
        r = Excon.get "http://#{host}/#{path}/admin/status/realtime/load_status", 
              :headers => { 'Cookie' => sysauth }
        @system_load_status = r.status
        if !r.status == 404
          one_min_load = []
          five_min_load = []
          @parsed_system_load = pp parser.parse(r.body)
          @parsed_system_load.each do |u|
            one_min_load.push(u[1])
            five_min_load.push(u[2])
          end
          @chart_system_load = LazyHighCharts::HighChart.new('line_ajax') do |f|
            f.chart({ type: 'line',
                    marginRight: 170,
                    marginBottom: 100 })
            f.title(:text => "System Load")
            f.xAxis(:title => {:text => "Time"},:categories => ['1','5','10','15','20','25','30'])
            f.series(:name => "1 minute Load", data: one_min_load )
            f.series(:name => "5 min load",  :data => five_min_load )

              f.yAxis({
              title: {
                text: 'Time Load'
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
        end
           

        #Connection Status

        r = Excon.get "http://#{host}/#{path}/admin/status/realtime/connections_status", 
              :headers => { 'Cookie' => sysauth }
        @system_connection_status = r.status
        if !r.status == 404
            r.body.gsub! /(connections|statistics)/, '"\\1"'
          @parsed_connection_status = pp parser.parse(r.body)
          other_connections = []
          @parsed_connection_status["statistics"].each do |u|
            other_connections.pushu[3]
          end
          
          @chart_connection_status = LazyHighCharts::HighChart.new('line_labels') do |f|
            f.chart({ type: 'line',
                    marginRight: 130,
                    marginBottom: 100 })
            f.title(:text => "Connection Status")
            f.xAxis(:title => {:text => "Time"},:categories => ['1','5','10','15','20','25','30'])
            f.series(:name => "Other Connections", data: other_connections )
            
              f.yAxis({
              title: {
                text: 'Number of Connections'
              },
              plotLines: [{
                value: 0,
                width: 0.5,
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
        end
        

        #Wireless Interface Status
        r = Excon.get "http://#{host}/#{path}/admin/status/realtime/wireless_status/wl0", 
              :headers => { 'Cookie' => sysauth }
        @wireless_interface_status = r.status
        if !r.status == 404
            @parsed_wireless_interface_status = pp parser.parse(r.body)
          rssi = []
          noise = []
          @parsed_wireless_interface_status.each do |u|
            rssi.push(u[2])
            noise.push(u[3])
          end
            @chart_wireless_interface_status = LazyHighCharts::HighChart.new('line_time_series') do |f|
            f.chart({ type: 'line',
                    marginRight: 130,
                    marginBottom: 100 })
            f.title(:text => "Wireless Interface Status")
            f.xAxis(:title => {:type=>"datetime", :text => "Time"},:categories => ['1','5','10','15','20','25','30'])
            f.series(:name => "RSSI",  :data => rssi )
            f.series(:name => "Noise",  :data => noise )

              f.yAxis({
              title: {
                text: 'Wireless interface Parameters'
              },
              plotLines: [{
                value: 0,
                width: 0.5,
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
        end
      end
    else
      @env = "development"
      @chart_network_traffic = LazyHighCharts::HighChart.new('basic_line') do |f|
        f.chart({ type: 'line',
                marginRight: 170,
                marginBottom: 100 })
        f.title(:text => "Network Traffic Graph")
        f.xAxis(:title => {:text => "Time"},:categories => ['1','5','10','15','20','25','30','35','40'])
        f.series(:name => "Data bytes Transmitted", data: [36,35,0,78,291,2930,293] )
        f.series(:name => "Data bytes Received",  :data => [8760,14510,953,937,465,964,273,3400,8860] )

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
      @chart_system_load = LazyHighCharts::HighChart.new('line_ajax') do |f|
        f.chart({ type: 'line',
                marginRight: 130,
                marginBottom: 100 })
        f.title(:text => "System Load")
        f.xAxis(:title => {:text => "Time"},:categories => ['1','5','10','15','20','25','30'])
        f.series(:name => "1 minute Load", data: [36,36,38,41,37,49,39] )
        f.series(:name => "5 min load",  :data => [40,40,42,44,41,48,43] )

          f.yAxis({
          title: {
            text: 'Time Load'
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
      @chart_connection_status = LazyHighCharts::HighChart.new('line_labels') do |f|
        f.chart({ type: 'line',
                marginRight: 130,
                marginBottom: 100 })
        f.title(:text => "Connection Status")
        f.xAxis(:title => {:text => "Time"},:categories => ['1','5','10','15','20','25','30'])
        f.series(:name => "Other Connections", data: [48,50,49,55,62,50,51] )

          f.yAxis({
          title: {
            text: 'Number of Connections'
          },
          plotLines: [{
            value: 0,
            width: 0.5,
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
      @chart_wireless_interface_status = LazyHighCharts::HighChart.new('line_time_series') do |f|
        f.chart({ type: 'line',
                marginRight: 130,
                marginBottom: 100 })
        f.title(:text => "Wireless Interface Status")
        f.xAxis(:title => {:type=>"datetime", :text => "Time"},:categories => ['1','5','10','15','20','25','30'])
        f.series(:name => "RSSI",  :data => [213,231,220,245,280,270,295] )
        f.series(:name => "Noise",  :data => [167,166,140,180,160,142,165] )

          f.yAxis({
          title: {
            text: 'Wireless interface Parameters'
          },
          plotLines: [{
            value: 0,
            width: 0.5,
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
