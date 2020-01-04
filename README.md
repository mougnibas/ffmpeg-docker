```
© Copyright 2018-2020 Yoann MOUGNIBAS

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

ffmpeg release is 4.2.2 'Ada', released 2019-12-31, with the following 'native' library versions :

```
libavutil      56. 31.100
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
libopus              1.3.1               (2019-04-13)
libaom               v1.0.0-errata1-avif (2019-12-12)
libvpx               1.8.2               (2019-12-19)
libx264              1771b556            (2019-11-25)
libx265 (8/10/12bit) 3.2.1               (2019-10-22)
libzimg (zscale)     2.9.2               (2019-07-31)
libvmaf              1.3.15              (2019-09-08)
```

## Misc

Source encoding is UTF-8 (without BOM) with "LF" (unix) end of line characters.

# Usage (advanced)

## Create from a linux host

```
docker run --rm -it --name ffmpeg -v /path/to/video:/mnt/encode   mougnibas/ffmpeg
cd /mnt/encode
```

## Create from a windows host

```
docker run --rm -it --name ffmpeg -v D:/path/to/video:/mnt/encode mougnibas/ffmpeg
cd /mnt/encode
```

## HD to H264-AAC

1. Adjust `-map` to map the reference streams :
  1. Default video
  1. Default audio
  1. Other audio
  1. Forced subtitle
  1. Other subtitle 1
  1. Other subtitle 1
1. Adjust `-disposition` according to the previously mapped streams
1. Adjust `-b:a:1` according to the previously mapped audio streams (delete / keep the linge)
1. Adjust `-b:a` bitrate according to the number of channels
  1. stereo (2 channels) : 128 kb/s
  1. 5.1    (6 channels) : 384 kb/s
  1. 7.1    (8 channels) : 512 kb/s
1. Remove `-filter:a aformat=channel_layouts="5.1"` parts only if the stream is not a 5.1 channels.

```
ffmpeg                                                                         \
  -y                                                                           \
  -hide_banner                                                                 \
  -i reference.mkv                                                             \
                                                                               \
  -map 0:0                                                                     \
  -map 0:2 -map 0:1                                                            \
  -map 0:5 -map 0:4 -map 0:3                                                   \
                                                                               \
  -map_metadata -1                                                             \
  -disposition:v:0 default                                                     \
  -disposition:a:0 default                                                     \
  -disposition:a:1 0                                                           \
  -disposition:s:0 forced                                                      \
  -disposition:s:1 0                                                           \
  -disposition:s:2 0                                                           \
                                                                               \
  -metadata:s:a:0 language=fre                                                 \
  -metadata:s:a:1 language=eng                                                 \
  -metadata:s:s:0 language=fre                                                 \
  -metadata:s:s:1 language=fre                                                 \
  -metadata:s:s:2 language=eng                                                 \
                                                                               \
  -codec:v libx264 -pix_fmt yuv420p                                            \
  -crf 21 -maxrate 16M -bufsize 64M -preset medium                             \
  -profile:v high                                                              \
  -x264-params level-idc=4.1:colorprim=bt709:transfer=bt709:colormatrix=bt709:fullrange=off  \
                                                                               \
  -codec:a aac                                                                 \
  -b:a:0 384k -filter:a:0 aformat=channel_layouts="5.1"                        \
  -b:a:1 384k -filter:a:1 aformat=channel_layouts="5.1"                        \
  -aac_coder twoloop                                                           \
  -profile:a aac_low                                                           \
                                                                               \
  -codec:s copy                                                                \
                                                                               \
  transcoded-H264-CRF21-16mbits-8bit.mkv
```

## VMAF score

`ffmpeg -i reference.mkv -i transcoded.mkv -filter_complex libvmaf -f null -`

# Build

## Requirements

* git client
* Docker 19.03.05 (or higher)

## Source clone

`git clone https://github.com/mougnibas/ffmpeg-docker.git`

## Docker build

```
cd ffmpeg-docker
docker image build --tag mougnibas/ffmpeg:latest src/main/docker/
```
