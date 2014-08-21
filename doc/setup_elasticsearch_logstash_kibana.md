Setting up Elasticsearch, Logstash and Kibana
================

## Installing Elasticsearch

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
    port => 5228
    codec => json
  }
}

output {
  elasticsearch { host => localhost
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
