# Docker

## Requirements
You will need a fairly recent version of Docker (https://docs.docker.com/install/)

We will use the following Docker images in this chapter:

- Graylog: graylog/graylog
- MongoDB: mongo
- Elasticsearch: docker.elastic.co/elasticsearch/elasticsearch

### Quick start

If you simply want to checkout Graylog without any further customization, you can run the following three commands to create the necessary environment:
```bash
 docker run --name mongo -d mongo:3
 docker run --name elasticsearch \
    -e "http.host=0.0.0.0" -e "xpack.security.enabled=false" \
    -d docker.elastic.co/elasticsearch/elasticsearch:5.6.2
 docker run --link mongo --link elasticsearch \
    -p 9000:9000 -p 12201:12201 -p 514:514 \
    -e GRAYLOG_WEB_ENDPOINT_URI="http://127.0.0.1:9000/api" \
    -d graylog/graylog:2.4.0-1 
```

### How to get log data in
You can create different kinds of inputs under System / Inputs, however you can only use ports that have been properly mapped to your docker container, otherwise data will not go through.

For example, to start a Raw/Plaintext TCP input on port 5555, stop your container and recreate it, whilst appending ```-p 5555:5555``` to your [docker run](https://docs.docker.com/engine/reference/run/) command:
```bash
docker run --link mongo --link elasticsearch \
    -p 9000:9000 -p 12201:12201 -p 514:514 -p 5555:5555 \
    -e GRAYLOG_WEB_ENDPOINT_URI="http://127.0.0.1:9000/api" \
    -d graylog/graylog:2.4.0-1
```

Similarly, the same can be done for UDP by appending ```-p 5555:5555/udp```

After that you can send a plaintext message to the Graylog Raw/Plaintext TCP input running on port 5555 using the following command:
```bash
echo 'First log message' | nc localhost 5555
```

### Settings
Graylog comes with a default configuration that works out of the box but you have to set a password for the admin user and the web interface needs to know how to connect from your browser to the Graylog REST API.

Both settings can be configured via environment variables (also see Configuration):

```text
-e GRAYLOG_ROOT_PASSWORD_SHA2=8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918
-e GRAYLOG_WEB_ENDPOINT_URI="http://127.0.0.1:9000/api"
```

In this case you can login to Graylog with the username and password ```admin```.

Generate your own admin password with the following command and put the SHA-256 hash into the ```GRAYLOG_ROOT_PASSWORD_SHA2``` environment variable:
```bash
echo -n yourpassword | shasum -a 256
```

All these settings and command line parameters can be put in a ```docker-compose.yml``` file, so that they don’t have to be executed one after the other.


[General Example](docker-compose-general-example.yml)

After starting all three Docker containers by running docker-compose up, you can open the URL ```http://127.0.0.1:9000``` in a web browser and log in with ```username admin``` and ```password admin``` (make sure to change the password later).

# Configuration
Every configuration option can be set via [environment variables](/misc/graylog.conf). Simply prefix the parameter name with ```GRAYLOG_``` and put it all in upper case.

For example, setting up the SMTP configuration for sending Graylog alert notifications via email, the `docker-compose.yml` would look like this:

[General Example with SMPT](docker-compose-general-example-smtp.yml)

Another option would be to store the configuration file outside of the container and edit it directly.

### Custom configuration files
Instead of using a long list of environment variables to configure Graylog (see [Configuration](/misc/graylog.conf)), you can also overwrite the bundled Graylog configuration files.

The bundled configuration files are stored in `/usr/share/graylog/data/config/` inside the Docker container.
Create the new configuration directory next to the `docker-compose.yml` file and copy the default files from GitHub:

```bash
mkdir -p ./graylog/config
cd ./graylog/config
wget https://raw.githubusercontent.com/cradules/graylog/master/misc/graylog.conf
wget https://raw.githubusercontent.com/cradules/graylog/master/misc/log4j2.xml
```

The newly created directory `./graylog/config/` with the custom configuration files now has to be mounted into the Graylog Docker container.

This can be done by adding an entry to the [volumes](https://docs.docker.com/compose/compose-file/#volume-configuration-reference) section of the docker-compose.yml file:

[General example with volume for configuration files](docker-compose-general-example-volume-conf-files.yml)

### Persisting data

In order to make the recorded data persistent, you can use external volumes to store all data.

In case of a container restart, this will simply re-use the existing data from the former instances.

Using Docker volumes for the data of MongoDB, Elasticsearch, and Graylog, the `docker-compose.yml` file looks as follows: