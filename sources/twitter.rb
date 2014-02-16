# -*- coding: utf-8 -*-
require 'net/http'
require 'uri'
require 'yaml'

class Twitter
  def initialize
    config = YAML.load_file '/mnt/sd/sources/config/settings.yml'
    @stewgate_token = config["twitter"]["stewgate"]["token"]
    @stewgate_api = config["twitter"]["stewgate"]["post_api"]
    @mention_to = config["twitter"]["account"]["yourself"]
  end

  def post(msg)
    params = {
      "_t" => @stewgate_token,
      "msg" => "#{@mention_to} #{msg} (#{generate_signature})"
    }
    begin
      uri = URI::parse @stewgate_api
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

  private
  def post_escape string
    string.gsub(/([^ a-zA-Z0-9_.-]+)/) do |match_letters|
      "%#{match_letters.unpack('H2' * match_letters.bytesize).join('%').upcase}"
    end.tr(' ', '+')
  end

  def generate_signature
  generator = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
  return 4.times.map{ generator[rand(generator.size)] }.join
  end
end