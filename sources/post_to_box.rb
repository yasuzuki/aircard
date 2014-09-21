# -*- coding: utf-8 -*-
require 'yaml'
require 'net/ftp'

class PostToBox
  AUTPRINT_MRK = "/mnt/sd/MISC/AUTPRINT.MRK"
  LAST_UPDATED_FILE = "/mnt/sd/MISC/LASTFILE.txt"
  PHOTO_FILES_PATH = "/mnt/sd/DCIM/200MSDCF"

  def initialize
    @config ||= YAML.load_file '/mnt/sd/sources/config/settings.yml'
    @server   = @config["box"]["server"]
    @username = @config["box"]["username"]
    @password = @config["box"]["password"]
    @upload_folder = @config["box"]["upload_folder"]
  end

  def execute
    begin
      # Printable files exists?
      if File.exists?(AUTPRINT_MRK)
        read_sections = File.read(AUTPRINT_MRK).split("\r\n\r\n")
        @sections = read_sections.dup
        read_sections.each do |section|
          file = parse_section(section)
          upload(file) if !file.nil? && File.exists?(file)
          update_mrk(section)
        end
      # Uploading latest files
      else
        setup_last_updated_file unless File.exists?(LAST_UPDATED_FILE)
        last_updated_file = File.read(LAST_UPDATED_FILE)
        uploading_files = Dir::entries(PHOTO_FILES_PATH).select{|file| file > last_updated_file }
        uploading_files.each do |filename|
          file = "#{PHOTO_FILES_PATH}/#{filename}"
          upload(file) if !file.nil? && File.exists?(file)
          update_last(file)
        end
        Twitter.new.post("All uploads done.")
      end
    rescue
      Twitter.new.post("Error while processing: #{$!}")
    end
  end

  def setup_last_updated_file
    File.write(LAST_UPDATED_FILE, @config["file"]["filename_for_setup"])
  end

  def setup_ftp
    @ftp = Net::FTP.open(@server, @username, @password)
    # Use passive mode for Box
    @ftp.passive = true
    @ftp.chdir(@upload_folder)
  end

  def upload file
    setup_ftp
    @ftp.putbinaryfile(file)
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

  def update_last file
    File.write(LAST_UPDATED_FILE, file)
  end

end
