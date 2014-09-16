require "bugzilla_mirror_client/version"
require "bugzilla_mirror_client/response"
require "bugzilla_mirror_client/bug"

require 'rest-client'
require 'base64'
require 'json'

class BugzillaMirrorClient
  attr_accessor :bugzilla_mirror_uri, :username, :password

  DEFAULT_BUGZILLA_MIRROR_API_PREFIX = "/issues"
  DEFAULT_BUGZILLA_MIRROR_TIMEOUT    = 60
  API_SUCCEEDED, API_FAILED  = [true, false]

  def initialize(bugzilla_mirror_uri, username = nil, password = nil)
    self.bugzilla_mirror_uri = bugzilla_mirror_uri
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
    params[:bug_ids] &&= Array(params[:bug_ids]).join(",")
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
    target = "#{bugzilla_mirror_uri}#{DEFAULT_BUGZILLA_MIRROR_API_PREFIX}"
    target << "/#{suffix}" if suffix
    begin
      restclient_args = [method, target]
      restclient_args << data if method == :post
      restclient_args << base_params(method).merge(:params => params)

      response        = RestClient.send(*restclient_args)
      response_status = response.code >= 400 ? API_FAILED : API_SUCCEEDED
      Response.new(response_status, response.code, JSON.parse(response))
    rescue => e
      Response.new(API_FAILED, 500, [], "Failed to Parse Response from #{bugzilla_mirror_uri} - #{e.message}")
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
