# -*- coding: utf-8 -*-
require 'ruby-box'
require './twitter.rb'

class PostToBox
  AUTPRINT_MRK = "/mnt/sd/MISC/AUTPRINT.MRK"

  def initialize
    config = YAML.load_file '/mnt/sd/sources/config/settings.yml'
    @client_id = config["box"]["client_id"]
    @client_secret = config["box"]["client_secret"]
    @access_token = config["box"]["access_token"]
    @upload_folder = config["box"]["upload_folder"]
    @session = RubyBox::Session.new({ 
      client_id: @client_id, 
      client_secret: @client_id,
      access_token: @access_token
    })
    @client = RubyBox::Client.new(@session)
  end

  def execute
    if File.exists?(AUTPRINT_MRK)
      begin
        read_sections = File.read(AUTPRINT_MRK).split("\r\n\r\n")
        @sections = read_sections.dup
        read_sections.each do |section|
          file = parse_section(section)
          upload(file) if !file.nil? && File.exists?(file)
          update_mrk(section)
        end
      rescue
        Twitter.new.post("Error while processing: #{$!}")
      end
    end
  end

  def upload file
    @client.upload_file(file, @upload_folder)
    Twitter.new.post("#{File.basename(file)} uploaded into Box.")
  rescue
    Twitter.new.post("Error while uploading into Box: #{$!}")
  end

  def parse_section section
    lines = section.split("\r\n")
    if lines[0].match(/\[JOB\]/)
      image_source = lines.find{|l| l.match(/^<IMG SRC = "(.+)">/)}
      image_source.match(/^<IMG SRC = "(.+)">/)[1].sub("..", "/mnt/sd")
    end
  end

  def update_mrk section
    @sections.delete(section)
    unless @sections.length.zero?
      File.write(AUTPRINT_MRK, @sections.join("\r\n"))
    else
      File.unlink(AUTPRINT_MRK)
      Twitter.new.post("All uploads done.")
    end
  end

end
