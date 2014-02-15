# -*- coding: utf-8 -*-
require 'net/http'
require 'uri'
require 'yaml'

# ------------------------------
# user configuration
# ------------------------------
config = YAML.load_file 'config/twitter.yml'
STEW_GATE_TOKEN = config["stewgate"]["token"]
STEW_GATE_API = config["stewgate"]["post_api"]
MENTION_TO = config["account"]["yourself"]

# ------------------------------
# methods
# ------------------------------
def post_escape string
  string.gsub(/([^ a-zA-Z0-9_.-]+)/) do |match_letters|
    '%' + match_letters.unpack('H2' * match_letters.bytesize).join('%').upcase
  end.tr(' ', '+')
end

def post(msg)
  params = {
    "_t" => STEW_GATE_TOKEN,
    "msg" => "#{MENTION_TO} " + msg,
  }
  begin
    uri = URI::parse STEW_GATE_API
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.content_type = "application/x-www-form-urlencoded"
    query = params.map{|key, val| "#{key}=#{post_escape(val.to_s)}"}
    res = http.request( request, query.join('&') )
    puts "Response: #{res.code}"
  rescue
    post("Error while Stewing: #{$!}")
  end
end

post("Hello, Twitter!")