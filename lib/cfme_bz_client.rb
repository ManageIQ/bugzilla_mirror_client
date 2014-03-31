require "cfme_bz_client/version"
require "cfme_bz_client/response"

require 'rest-client'
require 'base64'
require 'json'

class CfmeBzClient
  attr_accessor :cfme_bz_uri, :username, :password

  DEFAULT_CFME_BZ_URI        = "http://cfme-bz.manageiq.redhat"
  DEFAULT_CFME_BZ_API_PREFIX = "/issues"
  DEFAULT_CFME_BZ_TIMEOUT    = 60
  API_SUCCEEDED, API_FAILED  = [true, false]

  def initialize(cfme_bz_uri = DEFAULT_CFME_BZ_URI, username = nil, password = nil)
    self.cfme_bz_uri = cfme_bz_uri
    self.username    = username
    self.password    = password
  end

  def inspect
    super.gsub(/,[ ]*@password=\".+?\"/, "")
  end

  def get(bug_ids, params = {})
    bug_ids = Array(bug_ids)
    return get_multiple(bug_ids, params) if bug_ids.count > 1
    execute(:get, bug_ids.first.to_s, nil, params)
  end

  def get_multiple(bug_ids, params = {})
    params[:bug_ids] = bug_ids.join(",")
    execute(:get, nil, nil, params)
  end

  def search(params = {})
    execute(:get, nil, nil, params)
  end

  def refresh(id)
    raise "Must specify a single Issue Id for a refresh" if id.nil? || id.kind_of?(Array)
    execute(:get, "refresh/#{id.to_s}")
  end

  def update(id, data, params = {})
    raise "Must specify a single Issue Id with an update" if id.nil? || id.kind_of?(Array)
    raise "Must specify data to update Issue #{id}"       if data.nil?
    raise "Must specify Hash data to update Issue #{id}"  unless data.kind_of?(Hash)
    raise "Hash data specified is empty"                  if data.empty?
    execute(:post, id.to_s, data.to_json, params)
  end

  private

  def execute(method, suffix = nil, data = nil, params = {})
    raise "Unsupported Method #{method} specified" unless [:get, :post].include?(method)
    target = "#{cfme_bz_uri}#{DEFAULT_CFME_BZ_API_PREFIX}"
    target << "/#{suffix}" if suffix
    begin
      restclient_args = [method, target]
      restclient_args << data if method == :post
      restclient_args << base_params(method).merge(:params => params)

      RestClient.send(*restclient_args) do |response, request, result, &block|
        api_response = Response.new(API_SUCCEEDED, response.code)
        begin
          api_response.result = JSON.parse(response)
          api_response.status = API_FAILED if response.code >= 400
        rescue => e
          api_response.assign(API_FAILED, 500, {}, "Failed to Parse Response from #{cfme_bz_uri} - #{e}")
        end
        api_response
      end
    rescue => e
      Response.new(API_FAILED, 500, {}, e.message)
    end
  end

  def base_params(method = :get)
    params = {:accept => :json}
    params[:content_type]  = :json                  if method == :post
    params[:authorization] = "Basic #{credentials}" if credentials
    params
  end

  def credentials
    return nil unless username
    Base64.encode64 "#{username}:#{password}"
  end
end
