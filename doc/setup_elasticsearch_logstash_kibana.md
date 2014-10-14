Setting up Elasticsearch, Logstash and Kibana
================

## Installing Elasticsearch

### APT

```
wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
```

Add the repo to /etc/apt/sources.list
```
deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main
```

```
sudo apt-get update
sudo apt-get install elasticsearch
```

To start Elasticsearch
```
sudo service elasticsearch start
```
or
```
/etc/init.d/elasticsearch start
```

### Old

```
curl -O https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.1.tar.gz
tar zxvf elasticsearch-1.1.1.tar.gz
cd elasticsearch-1.1.1/
./bin/elasticsearch
```

Configuration files are located in

```
elasticsearch-1.1.1/config/
```

To start Elasticsearch

```
./bin/elasticsearch
```

## Installing Logstash

### APT

```
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
```

Add the repo to /etc/apt/sources.list
```
deb http://packages.elasticsearch.org/logstash/1.4/debian stable main
```

```
sudo apt-get update
sudo apt-get install logstash
```

Create a configuration file for logstash

```
cd /etc/logstash/cong.d
sudo vim logstash.conf
```

```
input {
  udp {
    host => "localhost"
    port => 5228 # For ruby apps
    codec => json_lines
    buffer_size => 16384
  }
  udp {
    host => "localhost"
    port => 5229 # For node apps
    codec => json
    buffer_size => 16384
  }
}

output {
  elasticsearch {
    host => localhost
  }
}
```

To start logstash with the configuration file, you just created

```
sudo service logstash start
```
or
```
/etc/init.d/logstash start
```

### Old

```
curl -O https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz
tar zxvf logstash-1.4.2.tar.gz
cd logstash-1.4.2
```

Create a configuration file for logstash

```
vim logstash.conf
```

```
input {
  udp {
    host => "localhost"
    port => 5228 # For ruby apps
    codec => json_lines
    buffer_size => 16384
  }
  udp {
    host => "localhost"
    port => 5229 # For node apps
    codec => json
    buffer_size => 16384
  }
}

output {
  elasticsearch {
    host => localhost
  }
}
```

To start logstash with the configuration file, you just created

```
bin/logstash -f logstash.conf
```


## Installing Kibana
```
wget http://download.elasticsearch.org/kibana/kibana/kibana-latest.zip
unzip kibana-latest.
```

Install apache2 or something.

```
sudo mv ./kibana-latest/* /var/www/*
```

Edit congig.js if needed

```
elasticsearch: "http://"+window.location.hostname+":9200",
```
