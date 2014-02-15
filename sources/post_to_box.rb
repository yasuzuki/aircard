# -*- coding: utf-8 -*-
require 'ruby-box'
require 'yaml'

class PostToBox
  attr_reader :client

  AUTPRINT_MRK = "/mnt/sd/MISC/AUTPRINT.MRK"

  def initialize
    config = YAML.load_file 'config/settings.yml'
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
          upload(file) if File.exists?(file_path)
          update_mrk(section)
        end
      rescue
        post("Error while processing: #{$!}")
      end
    end
  end

  def upload file
    @client.upload_file(file, @upload_folder)
    #post("#{File.basename(file)} uploaded.")
  rescue
    #post("Error while ftp put: #{$!}")
  end

  def parse_section section
    lines = section.split("\r\n")
    if lines[0].match(/\[JOB\]/)
      lines.map do |l|
        if md = l.match(/^<IMG SRC = "(.+)">/)
          md[1].sub("..", "/mnt/sd") 
        end
      end
    end
  end

  def update_mrk section
    @sections.delete(section)
    if (@sections.length > 1)
      File.write(AUTPRINT_MRK, @sections.join("\r\n"))
    else
      File.unlink(AUTPRINT_MRK)
      post("All uploads done.")
    end
  end

end
