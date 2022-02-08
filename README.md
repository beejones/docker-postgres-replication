# Postgres Streaming Replication

Based on the image: https://github.com/nebirhos/docker-postgres-replication

Postgres-replication is meant to be used with orchestration systems such as Kubernetes.

## Run with Docker Compose

```sh
docker-compose up
```

Then you can try to make somes changes on primary

```sh
docker exec -it docker-postgres-replication_postgres-primary_1 psql -U postgres
```

```sql
create database test;
\c test
create table posts (title text);
insert into posts values ('it works');
```

Then changes will appear on replica

```sh
docker exec docker-postgres-replication_postgres-replica_1 psql -U postgres test -c 'select * from posts'
  title
----------
 it works
(1 row)
```
