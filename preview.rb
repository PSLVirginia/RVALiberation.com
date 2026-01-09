#!/usr/bin/env ruby
# Local preview server for linkyee
# Builds the site and serves it on http://localhost:4000

require 'webrick'
require 'fileutils'

def build_site
  puts "Building site with scaffold.rb..."
  # Run the scaffold script
  load File.join(__dir__, 'scaffold.rb')
  puts "Site built in _output/"
rescue LoadError => e
  puts "Error loading dependencies: #{e.message}"
  puts "Make sure you have run: bundle install"
  exit 1
rescue => e
  puts "Build failed: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  exit 1
end

def start_server(port = 4000)
  puts "Starting preview server on http://localhost:#{port}"
  puts "Press Ctrl+C to stop"
  
  root = File.join(__dir__, '_output')
  unless Dir.exist?(root)
    puts "Error: _output directory not found. Build failed?"
    exit 1
  end
  
  server = WEBrick::HTTPServer.new(
    Port: port,
    DocumentRoot: root,
    BindAddress: 'localhost'
  )
  
  trap('INT') { server.shutdown }
  trap('TERM') { server.shutdown }
  
  server.start
end

if __FILE__ == $PROGRAM_NAME
  # Build first
  build_site
  
  # Determine port (optional argument)
  port = ARGV[0]&.to_i || 4000
  
  start_server(port)
end