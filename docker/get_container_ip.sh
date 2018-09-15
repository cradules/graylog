#!/usr/bin/env bash

CONTAINER="$1"

docker inspect   --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CONTAINER}