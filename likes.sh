#!/usr/bin/env bash
URL=$1

CLIENTID=JlZIsxg2hY5WnBgtn3jfS0UYCl0K8DOg
APPVERSION=1503404125
PAGE_SIZE=48
PARALLEL=4
USERID=$(curl -s -L $URL | grep -Eo "users:([0-9]+)\"*" | sed -e 's/users://g' -e 's/\"//g' | head -n1)

echo "user: $USERID"

function loadPage {
  OFFSET=$1
  echo "load page $OFFSET"
  LIST_URL="https://api-v2.soundcloud.com/users/$USERID/likes?client_id=$CLIENTID&limit=$PAGE_SIZE&offset=$OFFSET&linked_partitioning=1&app_version=$APPVERSION"

  TRACKS_CONTENT=$(curl -s -X GET -H "Content-type: application/json" -H "Accept: application/json" "$LIST_URL")

  TRACKS=$(echo "$TRACKS_CONTENT" | jq '.collection[].track.permalink_url' | grep -v null | sed s/\"//g)

  TRACKCOUNT=$(echo "$TRACKS" | grep -v "#" | wc -l)

  OFFSET=$(echo "$TRACKS_CONTENT" | jq '.next_href' | grep -Eo "offset\=[0-9]?*\&" | sed -e 's/\&//g' -e 's/offset\=//g' )

  echo "download $TRACKCOUNT tracks"

  COUNT=1
  echo "$TRACKS" | while read LINK; do
    #echo "$COUNT of $TRACKCOUNT download: $LINK"

    COUNT=$(($COUNT+1))
    echo $LINK 
  done | xargs -n1 -P$PARALLEL bash -c 'track.sh $0'

  if [ -z "$OFFSET" ]; then
    echo "complete"
  else
    echo "next: $OFFSET" 
    loadPage $OFFSET
  fi

}

loadPage 0
