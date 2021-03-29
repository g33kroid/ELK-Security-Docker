#!/bin/bash
# Usage:
# "./elastic-container.sh start" to start an Elasticsearch node and connected Kibana instance.
# "./elastic-container.sh stop" to stop an Elasticsearch node and connected Kibana instance.
# "./elastic-container.sh status" to get the status of the Elasticsearch node and connected Kibana instance.
# No data is retained!

# Define variables
ELASTIC_PASSWORD="${ELASTIC_PASSWORD:-password}"
ELASTICSEARCH_URL="${ELASTICSEARCH_URL:-http://elasticsearch:9200}"
STACK_VERSION="${STACK_VERSION:-7.12.0}"
# Elasticsearch and Kibana version options
# https://hub.docker.com/r/elastic/elasticsearch/tags?page=1&ordering=last_updated
# https://hub.docker.com/r/elastic/kibana/tags?page=1&ordering=last_updated
# STACK_VERSION="${STACK_VERSION:-8.0.0-SNAPSHOT}"

if [ $1 == start ]
then
docker network create elastic
docker run -d --network elastic --rm --name elasticsearch -p 9200:9200 -p 9300:9300 \
-e "discovery.type=single-node" \
-e "xpack.security.enabled=true" \
-e "xpack.security.authc.api_key.enabled=true" \
-e "ELASTIC_PASSWORD=${ELASTIC_PASSWORD}" \
docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION}
docker run -d --network elastic --rm --name kibana -p 5601:5601 \
-v $(pwd)/kibana.yml:/usr/share/kibana/config/kibana.yml \
-e "ELASTICSEARCH_HOSTS=${ELASTICSEARCH_URL}" \
-e "ELASTICSEARCH_USERNAME=elastic" \
-e "ELASTICSEARCH_PASSWORD=${ELASTIC_PASSWORD}" \
docker.elastic.co/kibana/kibana:${STACK_VERSION}

else
if [ $1 == stop ]
then
docker stop elasticsearch
docker stop kibana
docker network rm elastic

else
if [ $1 == status ]
then
docker ps -f "name=kibana" -f "name=elasticsearch" --format "table {{.Names}}: {{.Status}}"

else
echo "Proper syntax not used. Try ./elastic-container {start,stop,status}"
fi
fi
fi
