#!/usr/bin/env ruby
##
## Author: Thomas Foster <thomas.foster80@gmail.com>
##
## Released under the same terms as Sensu (the MIT license); see LICENSE
## for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'influxdb'

# This class will take event data and send results to influxDB for
# metric collections
#
class Sensutoinfluxdb < Sensu::Handler
  def filter; end

  def handle
    influxdb_server = settings['influx']['server']
    influxdb_port   = settings['influx']['port']
    influxdb_user   = settings['influx']['username']
    influxdb_pass   = settings['influx']['password']
    influxdb_db     = settings['influx']['database']

    influxdb_data = InfluxDB::Client.new(influxdb,
                                         username: influxdb_user,
                                         password: influxdb_pass,
                                         port:     influxdb_port,
                                         server:   influxdb_server
                                        )

    metrics    = @event['check']['output']
    data_point = @event['check']['name']
    host       = @event['client']['name']
    myip       = @event['client']['address']

    data = []

    metrics.split("\n").each do |metric|
      m = metric.split

      next unless m.count == 3

      key = m[0].split('.', 2)[1]
      key.gsub!('.', '_')
      value = m[1].to_f

      data << { host: host, stat: key, value: value, ip: myip }
    end
  end

  influxdb_data.write_point(data_point, data)
end
