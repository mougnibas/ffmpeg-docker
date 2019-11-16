```
© Copyright 2018 Yoann MOUGNIBAS

This file is part of ffmpeg-docker.

ffmpeg-docker is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ffmpeg-docker is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with ffmpeg-docker. If not, see <http://www.gnu.org/licenses/>
```

# Project informations

## General

The purpose of this project is to provide ffmpeg onto docker.

ffmpeg release is 4.2.1 'Ada', released 2019-10-05, with the following 'native' library versions :

```
libavutil      56. 31.00
libavcodec     58. 54.100
libavformat    58. 29.100
libavdevice    58.  8.100
libavfilter     7. 57.100
libswscale      5.  5.100
libswresample   3.  5.100
libpostproc    55.  5.100
```

It also provide the following external ones :

```
libopus          1.3
libaom           1.0
libvpx           1.7
libx264          stable (r2945 72db437)
libx265          3.2.1
libzimg (zscale) 2.9.2
```

## Misc

Source encoding is UTF-8 (without BOM) with "LF" (unix) end of line characters.

# Build

## Requirements

* git client
* Docker 19.03.04 (or higher)

## Source clone

`git clone https://github.com/mougnibas/ffmpeg-docker.git`

## Docker build

```
cd ffmpeg-docker
docker build src/main/docker/
```

# Usage


## TODO

TODO
