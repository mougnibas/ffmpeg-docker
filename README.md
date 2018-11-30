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
ffmpeg release is 4.1 'al-Khwarizmi', released 2018-11-06, with the following library versions :

```
libavutil      56. 22.100
libavcodec     58. 35.100
libavformat    58. 20.100
libavdevice    58.  5.100
libavfilter     7. 40.101
libswscale      5.  3.100
libswresample   3.  3.100
libpostproc    55.  3.100
```

It also provide the following ones :

```
libopus        1.3
libaom         1.0
libvpx         1.7
libx265        2.9
```

## Misc

Source encoding is UTF-8 (without BOM) with "LF" (unix) end of line characters.

# Requirements

* Maven 3.6.0
* JDK 11.0.1
* Windows 10 (amd64)
* Docker 18.06.1-ce (or higher)
   * it may be necessary to delete $HOME/.docker/config.json

# Setup

## Maven

1) Set `JAVE_HOME` environment variable to point to the JDK install directory.
1) Get and unzip maven.
1) Add the `bin` maven directory to the user path.

## Package

`mvn clean package`
