class NetworkController < ApplicationController
  before_filter :admin_required
  before_filter :set_page_title

  def index
    @leases = use_sample_data? ? SampleData.load('leases') : Lease.all
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
    render json: { id: @host.id }
  end

private
  def set_page_title
    @page_title = t('network')
  end

  def get_hosts
    @hosts = Host.all
    @net = Setting.get 'net'
  end
end
