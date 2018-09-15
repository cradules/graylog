# Docker

## Requirements
You will need a fairly recent version of Docker (https://docs.docker.com/install/)

We will use the following Docker images in this chapter:

- Graylog: graylog/graylog
- MongoDB: mongo
- Elasticsearch: docker.elastic.co/elasticsearch/elasticsearch

##Quick start

If you simply want to checkout Graylog without any further customization, you can run the following three commands to create the necessary environment:
```$ docker run --name mongo -d mongo:3
$ docker run --name elasticsearch \
    -e "http.host=0.0.0.0" -e "xpack.security.enabled=false" \
    -d docker.elastic.co/elasticsearch/elasticsearch:5.6.2
$ docker run --link mongo --link elasticsearch \
    -p 9000:9000 -p 12201:12201 -p 514:514 \
    -e GRAYLOG_WEB_ENDPOINT_URI="http://127.0.0.1:9000/api" \
    -d graylog/graylog:2.4.0-1 ```
