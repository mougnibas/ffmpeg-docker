```
© Copyright 2018-2023 Yoann MOUGNIBAS

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

ffmpeg release is 5.1 'Riemann', released 2022-07-22, with the following 'native' library versions :

```
libavutil      57. 28.100
libavcodec     59. 37.100
libavformat    59. 27.100
libavdevice    59.  7.100
libavfilter     8. 44.100
libswscale      6.  7.100
libswresample   4.  7.100
libpostproc    56.  6.100
```

It also provide the following external ones :

```
libx265 (8bit)       3.5                 (2021-03-19)
libvmaf              2.3.1               (2022-04-11)
```

# For developers

## Project link

* Public project repository : https://github.com/mougnibas/ffmpeg-docker

## Sources convention

* "LF" line ending (Unix)
* UTF-8 (without BOM)

## Requirements

* git 2.27.0 (2020-01-01)
* Docker Engine 19.03.08 (Docker Desktop for Windows, 2020-03-10), or Docker Engine 19.03.11 (2020-06-01)

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

### Build (arm64)

`Terminal / Run Build Task`

```
cd ffmpeg-docker
docker image build --platform linux/arm64 --progress plain --tag mougnibas/ffmpeg:latest src/main/docker/
```

### Build (amd64)

`Terminal / Run Build Task`

```
cd ffmpeg-docker
docker image build --platform linux/amd64 --progress plain --tag mougnibas/ffmpeg:latest src/main/docker/
```

# For end users

## Create from a linux host (or from Windows 10 WSL)

```
docker run --rm -it --name ffmpeg --hostname ffmpeg -v /path/to/video:/mnt/encode   mougnibas/ffmpeg
cd /mnt/encode
```

## Create from a windows host

```
docker run --rm -it --name ffmpeg --hostname ffmpeg -v D:/path/to/video:/mnt/encode mougnibas/ffmpeg
cd /mnt/encode
```

## HD to HEVC-AAC with VMAF

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
!/bin/bash

# Adjust this to get a VMAF score between 96.00 and 96.25
CRF=23.00

# These variables don't need to be changed
REFERENCE_FILE="reference.mkv"
PRESET="slow"
DISTORDED_FILE="distorded-VMAF-XX.XXXXXX-HEVC-CRF-$CRF-preset-$PRESET-AAC-64kbps-Subs-Chapters.mkv"

ffmpeg                                                                         \
  -y                                                                           \
  -hide_banner                                                                 \
  -i reference.mkv                                                             \
                                                                               \
  -map 0:v                                                                     \
  -map 0:a:0 -map 0:a:1                                                        \
  -map 0:s:0 -map 0:s:1 -map 0:s:2                                             \
                                                                               \
  -map_metadata -1                                                             \
  -disposition:v:0 default                                                     \
  -disposition:a:0 default                                                     \
  -disposition:a:1 0                                                           \
  -disposition:s:0 forced                                                      \
  -disposition:s:1 0                                                           \
  -disposition:s:2 0                                                           \
                                                                               \
  -metadata:s:v:0 language=eng,title="Video / en_us / HEVC / Level 5.1 / Main / Main tier" \
  -metadata:s:a:0 language=fre,title="Audio / fr_fr / AAC / 5.1"               \
  -metadata:s:a:1 language=eng,title="Audio / en_us / AAC / 5.1"               \
  -metadata:s:s:0 language=fre,title="Subtitle / fr_fr / PGS / forced"         \
  -metadata:s:s:1 language=fre,title="Subtitle / fr_fr / PGS / regular"        \
  -metadata:s:s:2 language=eng,title="Subtitle / en_us / PGS / regular"        \
                                                                               \
  -filter:v "format=yuv420p,setfield=prog,setpts=PTS-STARTPTS"                 \
  -codec:v libx265                                                             \
  -crf $CRF -maxrate 40000K -bufsize 40000K -preset $PRESET                    \
  -profile:v main                                                              \
  -g 240 -keyint_min 24                                                        \
  -x265-params level-idc=5.1:high-tier=0:colorprim=bt709:transfer=bt709:colormatrix=bt709:range=limited:scenecut=0:open-gop=0:no-sao=1 \
                                                                               \
  -codec:a aac                                                                 \
  -aac_coder:a twoloop                                                         \
  -profile:a aac_low                                                           \
                                                                               \
  -filter:a:0 "channelmap=map=FL-FL|FR-FR|FC-FC|LFE-LFE|SL-BL|SR-BR,asetpts=PTS-STARTPTS" \
  -b:a:0 384k                                                                  \
                                                                               \
  -filter:a:1 "channelmap=map=FL-FL|FR-FR|FC-FC|LFE-LFE|SL-BL|SR-BR,asetpts=PTS-STARTPTS" \
  -b:a:1 384k                                                                  \
                                                                               \
  -codec:s copy                                                                \
                                                                               \
  -f matroska                                                                  \
  -default_mode infer_no_subs                                                  \
  -reserve_index_space 512k                                                    \
                                                                               \
  $DISTORDED_FILE                                                           && \
                                                                               \
ffmpeg                                                                         \
                                                                               \
  -y                                                                           \
  -hide_banner                                                                 \
  -i $REFERENCE_FILE                                                           \
  -i $DISTORDED_FILE                                                           \
                                                                               \
  -filter_complex                                                              \
  '
   [0:v]                       format=yuv420p,setfield=prog,setpts=PTS-STARTPTS    [video_reference_normalize];
   [video_reference_normalize] scale=1920x1080:flags=lanczos,settb=expr=1001/24000 [video_reference_vmaf_friendly];
   [1:v]                       scale=1920x1080:flags=lanczos,settb=expr=1001/24000 [video_distorded_vmaf_friendly];
   [video_distorded_vmaf_friendly] [video_reference_vmaf_friendly] libvmaf
  '                                                                            \
  -f null                                                                      \
                                                                               \
  /dev/null
```
