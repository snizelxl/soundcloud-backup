# soundcloud-backup
Backup your music on soundcloud!

## Prerequisites
You need to install [docker](https://www.docker.com)

## Setup

- ```git clone https://github.com/snizelxl/soundcloud-backup soundcloud-backup```
- ```cd soundcloud-backup```
- ```sudo docker build -t soundcloud .```

## HowTo

#### Load a single track:
```sudo ./dl-track http://soundcloud.com/dedydread/the-knife-dedy-dread-cut```

#### Load all (your) likes:
```sudo ./dl-likes http://soundcloud.com/dunkelbunt/likes```
