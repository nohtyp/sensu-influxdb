## Sensu to InfluxDB metrics

This handler is to send metrics to an InfluxDB database with certain columns filled out.
To use this handler I created the directory structure to use when downloading and what 
locations to use for each file.

Assumptions:
---
1. InfluxDB database has been created on the InfluxDB server
2. Port is available for communication ("telnet/nc to port")
3. The stats database is created on InfluxDB server


```
###### '/etc/sensu/handlers/metrics/influxdb-metrics.rb'
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

  influxdb_data = InfluxDB::Client.new influxdb_db, :host => influxdb_server,
                                                    :username => influxdb_user,
                                                    :password => influxdb_pass,
                                                    :port => influxdb_port,
                                                    :server => influxdb_server
      
    mydata = []

    @event['check']['output'].each_line do |metric|
      m = metric.split
      next unless m.count >= 3
      key = m[0].split('.', 1)[0]
      key.gsub!('.', '_')
      value = m[1].to_f
      mydata = {:host => @event['client']['name'], :value => value,
                :ip => @event['client']['address']
               } 
      influxdb_data.write_point(key, mydata)
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
               "database"    : "stats"
     }
}
```

###### '/etc/sensu/conf.d/handlers/influxdb-metrics.json'
```
{
  "handlers": {
       "influxdb": {
           "type"        : "pipe",
           "command"     : "/etc/sensu/handlers/metrics/influxdb-metrics.rb"
     }
  }
}
```


Then restart sensu-server..and you should see a metric in the stats database as 'cpu_total_system'.
To see the data run the following query on the stats database: select * from cpu_total_system

---
Todo:
---
1. Add checking for network connectivity failure.
2. Add check to create database and datapoint.
3. Figure out multiple passwords and databases
4. Don't know what else to add to list, because still working on file will add new todo's when I get a chance.
