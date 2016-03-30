#!/usr/bin/env ruby

require 'bundler/setup'
require 'softlayer/object_storage'
require File.join(File.dirname(__FILE__), '../test/backend/creds.rb')

@cont = nil

class Upload
  def set_container cont
    unless @cont
      @conn = SoftLayer::ObjectStorage::Connection.new(CREDS)
      @cont = @conn.container(cont)
    end
  end

  def list
    set_container('caos')
    r = @cont.search()
    puts ""
    puts "Container caos: (#{@cont.count} objects, #{@cont.bytes} bytes)"
    r[:items].each do |o|
      puts "* #{o['name']} (#{o['content_type']})"
    end
  end

  def upload dir
    set_container('caos')
    puts "Starting upload..."
    list
    puts "---------------------------------------------------------------------"
    begin
      entries = Dir.entries(dir)
    rescue
      puts "Directory error"
    end
    entries.each do |f|
      file = File.join(dir, f)
      if File.file?(file)
        puts "upload file '#{file}'..."
        obj = @cont.create_object(f, false)
        #obj.load_from_filename(file)
        data = File.binread(file)
        obj.write(data)
        obj.set_metadata({album: 'CM2016'})
      end
    end
    puts "---------------------------------------------------------------------"
    list
  end
end

u = Upload.new

case ARGV[0]
when 'list'
  u.list
when 'upload'
  u.upload ARGV[1]
else
  puts "usage:"
  puts "        listup: #{File.basename(__FILE__)} list"
  puts "        upload: #{File.basename(__FILE__)} upload dir"
end
