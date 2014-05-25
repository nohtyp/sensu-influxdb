#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'influxdb'

# Read event data
event = JSON.parse(STDIN.read, :symbolize_names => true)

influxdb_server = "influxdb.familyguy.com"
influxdb_port   =  8086
influxdb_user   = 'root'
influxdb_pass   = 'root'
influxdb_db     = 'stats'
data_point      = 'test'


#influxd_server = settings['influx']['server']
#influxdb_port   = settings['influx']['port']
#influxdb_user   = settings['influx']['username']
#influxdb_pass   = settings['influx']['password']
#influxdb_db     = settings['influx']['database']

influxdb_data = InfluxDB::Client.new influxdb_db, :host => influxdb_server,
                                                  :username => influxdb_user,
                                                  :password => influxdb_pass,
                                                  :port => influxdb_port,
                                                  :server => influxdb_server
      
  mydata = []
  #puts "#{event[:client][:name]}"
  event[:check][:output].each do |metric|
  #puts "#{metric}"
    m = metric.split
  next unless m.count == 3

    key = m[0].split('.', 2)[1]
    #puts "Key: #{key}"
    key.gsub!('.', '_')
    value = m[1].to_f
    #puts "Value: #{value}"
    mytime = Time.now

    mydata = {:host => "#{event[:client][:name]}", :check => "#{event[:check][:name]}", 
              :key => "#{key}", :value => "#{value}", :ip => "#{event[:client][:address]}", 
              :month => "#{mytime.month}", :day => "#{mytime.day}"}
    influxdb_data.write_point(data_point, mydata)
  end

