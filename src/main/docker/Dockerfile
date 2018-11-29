# (c) Copyright 2018 Yoann MOUGNIBAS
#
# This file is part of ffmpeg-docker.
#
# ffmpeg-docker is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ffmpeg-docker is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ffmpeg-docker. If not, see <http://www.gnu.org/licenses/>

#
# ffmpeg-docker dockerfile
#
# Sources :
# - https://ffmpeg.org/download.html#releases
# - https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
#

# From debian "stretch" image
FROM debian:9

# "Server" install without ffplay. Omit some dependencies.
RUN apt-get update                                                                        && \
    apt-get -y install                                                                       \
        autoconf                                                                             \
        automake                                                                             \
        build-essential                                                                      \
        cmake                                                                                \
        git-core                                                                             \
        libtool                                                                              \
        pkg-config                                                                           \
        texinfo                                                                              \
        wget                                                                                 \
        zlib1g-dev

# Put source directory to home directory
RUN mkdir -p ~/ffmpeg_sources ~/bin

# Install YASM assembler (used by some library)
RUN apt-get install -y yasm

# Install NASM assembler (used by some library)
RUN cd ~/ffmpeg_sources                                                                   && \
    wget https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2          && \
    tar xjvf nasm-2.13.03.tar.bz2                                                         && \
    cd nasm-2.13.03                                                                       && \
    ./autogen.sh                                                                          && \
    PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && \
    make                                                                                  && \
    make install                                                                          && \
    rm -R ~/ffmpeg_sources/nasm-*

# Compile libopus dependency (opus)
RUN cd ~/ffmpeg_sources                                                                   && \
    wget -q -O  opus-1.3.tar.gz https://github.com/xiph/opus/archive/v1.3.tar.gz          && \
    tar xzvf opus-1.3.tar.gz                                                              && \
    cd opus-1.3                                                                           && \
    ./autogen.sh                                                                          && \
    ./configure --prefix="$HOME/ffmpeg_build" --disable-shared                            && \
    make                                                                                  && \
    make install                                                                          && \
    rm -R ~/ffmpeg_sources/opus*

# Compile libaom dependency (AV1)
RUN cd ~/ffmpeg_sources                                                                   && \
    git clone https://aomedia.googlesource.com/aom                                        && \
    cd aom                                                                                && \
    git checkout v1.0.0                                                                   && \
    mkdir ~/ffmpeg_sources/aom_build                                                      && \
    cd    ~/ffmpeg_sources/aom_build                                                      && \
    PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_TESTS=0 -DENABLE_SHARED=off -DENABLE_NASM=on ../aom && \
    PATH="$HOME/bin:$PATH" make                                                           && \
    make install                                                                          && \
    rm -R ~/ffmpeg_sources/aom*

# Compile libvpx dependency (VP8-VP9)
RUN cd ~/ffmpeg_sources                                                                   && \
    git clone https://chromium.googlesource.com/webm/libvpx.git                           && \
    cd libvpx                                                                             && \
    git checkout v1.7.0                                                                   && \
    PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm && \
    PATH="$HOME/bin:$PATH" make                                                           && \
    make install                                                                          && \
    rm -R ~/ffmpeg_sources/libvpx*

# Compile ffmpeg
RUN cd ~/ffmpeg_sources                                                                   && \
    wget -q -O ffmpeg.tar.bz2 https://ffmpeg.org/releases/ffmpeg-4.1.tar.bz2              && \
    tar xjvf ffmpeg.tar.bz2                                                               && \
    cd ffmpeg-4.1                                                                         && \
    PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure    \
        --prefix="$HOME/ffmpeg_build"                                                        \
        --pkg-config-flags="--static"                                                        \
        --extra-cflags="-I$HOME/ffmpeg_build/include"                                        \
        --extra-ldflags="-L$HOME/ffmpeg_build/lib"                                           \
        --extra-libs="-lpthread -lm"                                                         \
        --bindir="$HOME/bin"                                                                 \
        --enable-gpl                                                                         \
        --enable-libopus                                                                     \
        --enable-libaom                                                                      \
        --enable-libvpx                                                                   && \
    PATH="$HOME/bin:$PATH" make                                                           && \
    make install

# Install ffmpeg and ffprobe binary under /usr/local/bin
RUN cp ~/bin/ffmpeg  /usr/local/bin                                                       && \
    cp ~/bin/ffprobe /usr/local/bin

# Remove sources and build directories
RUN rm -Rf ~/ffmpeg_build                                                                 && \
    rm -Rf ~/ffmpeg_sources                                                               && \
    rm -Rf ~/bin

# "forget" commands
RUN hash -r
