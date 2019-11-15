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

# From ubuntu 18.04 LTS image
FROM ubuntu:18.04

# "Server" install without ffplay. Omit some dependencies.
# Put source directory to home directory
# Install YASM assembler (used by some library)
# Install NASM assembler (used by some library)
# Compile libopus dependency (opus) from tarball
# Compile libaom dependency (AV1) from git
# Compile libvpx dependency (VP8-VP9) from git
# Compile libx264 (H264 / AVC) from git
# Compile libx265 (H265 / HEVC) from tarball
# Compile ffmpeg from tarball
# Install ffmpeg and ffprobe binary under /usr/local/bin
# Remove sources and build directories
# "forget" commands
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
        zlib1g-dev                                                                        && \
                                                                                             \
    mkdir -p ~/ffmpeg_sources ~/bin                                                       && \
                                                                                             \
    apt-get install -y yasm                                                               && \
                                                                                             \
    cd ~/ffmpeg_sources                                                                   && \
    wget --no-check-certificate                                                              \
        https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2           && \
    tar xjvf nasm-2.13.03.tar.bz2                                                         && \
    cd nasm-2.13.03                                                                       && \
    ./autogen.sh                                                                          && \
    PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && \
    make                                                                                  && \
    make install                                                                          && \
    rm -R ~/ffmpeg_sources/nasm-*                                                         && \
                                                                                             \
    cd ~/ffmpeg_sources                                                                   && \
    wget -q -O  opus-1.3.tar.gz https://github.com/xiph/opus/archive/v1.3.tar.gz          && \
    tar xzvf opus-1.3.tar.gz                                                              && \
    cd opus-1.3                                                                           && \
    ./autogen.sh                                                                          && \
    ./configure --prefix="$HOME/ffmpeg_build" --disable-shared                            && \
    make                                                                                  && \
    make install                                                                          && \
    rm -R ~/ffmpeg_sources/opus*                                                          && \
                                                                                             \
    cd ~/ffmpeg_sources                                                                   && \
    git clone https://aomedia.googlesource.com/aom                                        && \
    cd aom                                                                                && \
    git checkout v1.0.0                                                                   && \
    mkdir ~/ffmpeg_sources/aom_build                                                      && \
    cd    ~/ffmpeg_sources/aom_build                                                      && \
    PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_TESTS=0 -DENABLE_SHARED=off -DENABLE_NASM=on ../aom && \
    PATH="$HOME/bin:$PATH" make                                                           && \
    make install                                                                          && \
    rm -R ~/ffmpeg_sources/aom*                                                           && \
                                                                                             \
    cd ~/ffmpeg_sources                                                                   && \
    git clone https://chromium.googlesource.com/webm/libvpx.git                           && \
    cd libvpx                                                                             && \
    git checkout v1.7.0                                                                   && \
    PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm && \
    PATH="$HOME/bin:$PATH" make                                                           && \
    make install                                                                          && \
    rm -R ~/ffmpeg_sources/libvpx*                                                        && \
                                                                                             \
    cd ~/ffmpeg_sources                                                                   && \
    git clone https://code.videolan.org/videolan/x264.git                                 && \
    cd x264                                                                               && \
    git checkout stable                                                                   && \
    PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --enable-pic && \
    PATH="$HOME/bin:$PATH" make                                                           && \
    make install                                                                          && \
    rm -R ~/ffmpeg_sources/x264*                                                          && \
                                                                                             \
    cd ~/ffmpeg_sources                                                                   && \
    wget -q -O  x265.tar.gz https://bitbucket.org/multicoreware/x265/downloads/x265_3.2.1.tar.gz && \
    tar xzvf x265.tar.gz                                                              && \
    cd x265_*/build/linux                                                               && \
    PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED=off -DHIGH_BIT_DEPTH=ON ../../source && \
    PATH="$HOME/bin:$PATH" make                                                           && \
    make install                                                                          && \
    rm -R ~/ffmpeg_sources/x265*                                                          && \
                                                                                             \
    cd ~/ffmpeg_sources                                                                   && \
    wget -q -O zimg.tar.gz https://github.com/sekrit-twc/zimg/archive/release-2.9.2.tar.gz && \
    tar xzvf zimg.tar.gz                                                                  && \
    cd zimg-release-2.9.2                                                                 && \
    ./autogen.sh                                                                          && \
    PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-shared --enable-static  && \
    PATH="$HOME/bin:$PATH" make                                                           && \
    make install                                                                          && \
    rm -R ~/ffmpeg_sources/zimg-release-*                                                 && \
                                                                                             \
    cd ~/ffmpeg_sources                                                                   && \
    wget -q -O ffmpeg.tar.bz2 https://ffmpeg.org/releases/ffmpeg-4.2.1.tar.bz2            && \
    tar xjvf ffmpeg.tar.bz2                                                               && \
    cd ffmpeg-4.2.1                                                                       && \
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
        --enable-libvpx                                                                      \
        --enable-libx264                                                                     \
        --enable-libx265                                                                     \
        --enable-libzimg                                                                  && \
    PATH="$HOME/bin:$PATH" make                                                           && \
    make install                                                                          && \
    cp ~/bin/ffmpeg  /usr/local/bin                                                       && \
    cp ~/bin/ffprobe /usr/local/bin                                                       && \
    rm -Rf ~/ffmpeg_build                                                                 && \
    rm -Rf ~/ffmpeg_sources                                                               && \
    rm -Rf ~/bin                                                                          && \
                                                                                             \
    apt-get remove -y                                                                        \
        autoconf                                                                             \
        automake                                                                             \
        build-essential                                                                      \
        cmake                                                                                \
        git-core                                                                             \
        libtool                                                                              \
        pkg-config                                                                           \
        texinfo                                                                              \
        wget                                                                                 \
        zlib1g-dev                                                                        && \
    apt-get autoremove -y                                                                 && \
    apt-get purge                                                                         && \
                                                                                             \
    hash -r
