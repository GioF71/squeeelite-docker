#!/bin/sh

docker build --push --platform linux/arm/v7,linux/amd64 --tag giof71/squeezelite:stable .