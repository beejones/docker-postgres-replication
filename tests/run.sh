#!/usr/bin/env bash

IMAGE="postgres-replication:test"
CONTAINER_PREFIX="postgres-replication-test"
POSTGRES_USER='postgres'
POSTGRES_PASSWORD=''
POSTGRES_DB='postgres'

docker container rm -f "$CONTAINER_PREFIX-master" # 2> /dev/null
docker container rm -f "$CONTAINER_PREFIX-slave" # 2> /dev/null

docker build -t $IMAGE .

docker run -e POSTGRES_USER=test \
           -e POSTGRES_PASSWORD=password \
           -e REPLICATION_USER=test_rep \
           -e REPLICATION_PASSWORD=password \
           -e POSTGRES_MASTER_SERVICE_HOST=postgres-master \
           -e REPLICATION_ROLE=master \
           --name "$CONTAINER_PREFIX-master" \
           --detach \
           $IMAGE

sleep 5

docker run  --link "$CONTAINER_PREFIX-master" \
           -e POSTGRES_USER=test \
           -e POSTGRES_PASSWORD=password \
           -e REPLICATION_USER=test_rep \
           -e REPLICATION_PASSWORD=password \
           -e POSTGRES_MASTER_SERVICE_HOST=$CONTAINER_PREFIX-master \
           -e REPLICATION_ROLE=slave \
           --name "$CONTAINER_PREFIX-slave" \
           --detach \
           $IMAGE

sleep 5

docker exec "$CONTAINER_PREFIX-master" psql -U test postgres -c 'CREATE TABLE replication_test (a INT, b INT, c VARCHAR(255))'
docker exec "$CONTAINER_PREFIX-master" psql -U test postgres -c "INSERT INTO replication_test VALUES (1, 2, 'it works')"

sleep 5

docker exec "$CONTAINER_PREFIX-slave" psql -U test postgres -c "SELECT COUNT(*) FROM replication_test" -X -A

docker logs "$CONTAINER_PREFIX-slave"
result=$(docker exec "$CONTAINER_PREFIX-slave" psql -U test postgres -c "SELECT COUNT(*) FROM replication_test" -X -A -t)

if [ "$result" = "1" ]
then
    exit 0
else
    exit 1
fi
