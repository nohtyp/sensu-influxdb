#!/usr/bin/env ruby

require 'rubygems'
require 'sensu-handler'
require 'influxdb'

class SensuToInfluxDB < Sensu::Handler

  def filter; end

  def handle

  influxdb_server = settings['influxdb']['server']
  influxdb_port   = settings['influxdb']['port']
  influxdb_user   = settings['influxdb']['username']
  influxdb_pass   = settings['influxdb']['password']
  influxdb_db     = settings['influxdb']['database']
  influxdb_dp     = settings['influxdb']['datapoint']

  influxdb_data = InfluxDB::Client.new influxdb_db, :host => influxdb_server,
                                                    :username => influxdb_user,
                                                    :password => influxdb_pass,
                                                    :port => influxdb_port,
                                                    :server => influxdb_server

    mydata = []
    @event['check']['output'].each do |metric|
      m = metric.split
    next unless m.count == 3

      key = m[0].split('.', 2)[1]
      #puts "Key: #{key}"
      key.gsub!('.', '_').to_sym
      value = m[1].to_f
      #puts "Value: #{value}"

      mydata = {:host => @event['client']['name'], "#{key}" => "#{value}",
                :ip => @event['client']['address']
               }
      influxdb_data.write_point(influxdb_dp, mydata)
    end
  end
end
