## Sensu to InfluxDB metrics

This handler is to send metrics to an InfluxDB database with certain columns filled out.
To use this handler I created the directory structure to use when downloading and what 
locations to use for each file.


###### '/etc/sensu/handlers/metrics/influxdb-metrics.rb'
```
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
      key.gsub!('.', '_')
      value = m[1].to_f
      #puts "Value: #{value}"
      mytime = Time.now

      mydata = {:host => @event['client']['name'], :check => @event['check']['name'], 
                :key => "#{key}", :value => "#{value}", :ip => @event['client']['address'], 
                :month => "#{mytime.month}", :day => "#{mytime.day}"}
      influxdb_data.write_point(influxdb_dp, mydata)
    end
  end
end
```


###### '/etc/sensu/conf.d/checks/check_cpu_metrics.json'
```
 {
  "checks": {
      "check_cpu_metrics": {
      "type": "metric",
      "command": "/etc/sensu/plugins/system/cpu-metrics.rb",
      "interval": 30,
      "subscribers": [ "test" ],
      "handlers": [ "influxdb" ]
      }
    }
}
```

###### '/etc/sensu/conf.d/influxdb-metrics.json'
```
{
    "influxdb"   : {
               "server"      : "influxdb.familyguy.com",
               "port"        : "8086",
               "username"    : "root",
               "password"    : "root",
               "database"    : "stats",
               "datapoint"   : "test"
     }
}
```



---
Todo:
---
1. Add checking for network connectivity failure.
2. Add check to create database and datapoint.
3. Don't know what else to add to list, because still working on file will add new todo's when I get a chance.
