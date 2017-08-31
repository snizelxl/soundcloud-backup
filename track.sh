#!/usr/bin/env bash
URL=$1

FOLDER="/downloads"
CLIENTID=JlZIsxg2hY5WnBgtn3jfS0UYCl0K8DOg
CONTENT=$(curl -s -L $URL)
TRACKID=$(echo "$CONTENT" | grep -Eo "sounds:([0-9]+)\"*" | sed -e 's/sounds://g' -e 's/\"//g' | head -n1)
TITLE=$(echo "$CONTENT" | grep -Eo "(<title>).*(</title>)" | grep -Eo "^[^|]+" | sed s/\<title\>//g)
# urldecode
TITLE=$(printf '%b' "${TITLE//%/\\x}" | sed "s/&#39;/'/g")
# trim and remove slashes
TITLE=$(echo "$TITLE" | sed -e 's/\//\|/g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | xargs -0 echo -E)

if [[ $TITLE == *" - "* ]]; then
  # artist - trackname
  TRACK=$(echo $TITLE | sed -e 's/[ -].*//g')
  ARTIST=$(echo $TITLE | sed -e 's/^.*[ -]//g' -e 's/by.*$//g')
else
  # trackname by artist
  ARTIST=$(echo $TITLE | sed -e 's/^.*by //g')
  TRACK=$(echo $TITLE | sed -e 's/ by.*$//g')
fi

TITLE="$ARTIST - $TRACK"

STREAM_URL="https://api.soundcloud.com/i1/tracks/$TRACKID/streams?client_id=$CLIENTID"
PLAYLIST_URL=$(curl -s -L $STREAM_URL | jq '.hls_mp3_128_url' | sed s/\"//g | xargs -0 echo -E)
PARTS=$(curl -s -L $PLAYLIST_URL)
PARTCOUNT=$(echo "$PARTS" | grep -v "#" | wc -l)
FILEPARTS=$(echo "$PARTS" | grep -v "#" | tr '\n' ' ')

echo "download: $TITLE ($PARTCOUNT parts)"

rm -rf "$FOLDER/$TITLE.part"
rm -rf "$FOLDER/$TITLE.mp3"
curl -s -L $FILEPARTS >> "$FOLDER/$TITLE.part"
mv "$FOLDER/$TITLE.part" "$FOLDER/$TITLE.mp3"

id3v2 -a "$ARTIST" -t "$TRACK" "$FOLDER/$TITLE.mp3"

echo "complete: $TITLE ($PARTCOUNT parts)"
