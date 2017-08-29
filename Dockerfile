FROM ubuntu:16.04

RUN apt-get update && apt-get install -y curl jq

COPY track.sh /usr/bin/track.sh
COPY likes.sh /usr/bin/likes.sh
