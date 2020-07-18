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

# General

The purpose of this project is to provide ffmpeg onto docker.

ffmpeg release is 4.3.1 '4:3', released 2020-07-11, with the following 'native' library versions :

```
libavutil      56. 51.100
libavcodec     58. 91.100
libavformat    58. 45.100
libavdevice    58. 10.100
libavfilter     7. 85.100
libswscale      5.  7.100
libswresample   3.  7.100
libpostproc    55.  7.100
```

It also provide the following external ones :

```
libopus              1.3.1               (2019-04-13)
libaom               v2.0.0              (2020-05-18)
libvpx               1.8.2               (2019-12-19)
libx264              296494a4            (2020-04-05)
libx265 (8/10/12bit) 3.3                 (2020-02-17)
libzimg (zscale)     2.9.3               (2020-03-02)
libvmaf              1.5.1               (2020-02-28)
```

# For developers

## Project link

* Public project repository : https://github.com/mougnibas/ffmpeg-docker

## Sources convention

* "LF" line ending (Unix)
* UTF-8 (without BOM)

## Requirements

* git 2.27.0 (2020-01-01)
* Docker Engine 19.03.08 (Docker Desktop for Windows, 2020-03-10), or Docker Engine Engine 19.03.11 (2020-06-01)

## Project import

* From Visual Studio Code, open Workspace file `project.code-workspace`
* Install recommended extensions

## Application lifecycle instructions

### Clean

`Terminal / Run Task / clean`

```
cd ffmpeg-docker
docker image rm mougnibas/ffmpeg:latest
```

### Build

`Terminal / Run Build Task`

```
cd ffmpeg-docker
docker image build --tag mougnibas/ffmpeg:latest src/main/docker/
```

# For end users

## Create from a linux host

```
docker run --rm -it --name ffmpeg --hostname ffmpeg -v /path/to/video:/mnt/encode   mougnibas/ffmpeg
cd /mnt/encode
```

## Create from a windows host

```
docker run --rm -it --name ffmpeg --hostname ffmpeg -v D:/path/to/video:/mnt/encode mougnibas/ffmpeg
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
1. Adjust `-b:a:1` according to the previously mapped audio streams (delete / keep the line)
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
  -crf 21 -maxrate 16M -bufsize 78125K -preset medium                          \
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
