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

# From debian "stretch" image
FROM debian:9

# "Server" install without ffplay. Omit some dependencies.
# Source :
# - https://ffmpeg.org/download.html#releases
# - https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
RUN apt-get update                                                         && \
    apt-get -y install                                                        \
        autoconf                                                              \
        automake                                                              \
        build-essential                                                       \
        cmake                                                                 \
        git-core                                                              \
        libtool                                                               \
        pkg-config                                                            \
        texinfo                                                               \
        wget                                                                  \
        zlib1g-dev

# Put source directory to home directory
RUN mkdir -p ~/ffmpeg_sources ~/bin

# Install YASM assembler (used by some library)
RUN apt-get install -y yasm

# Install Yasm assembler (used by some library)
RUN cd ~/ffmpeg_sources                                                                   && \
    wget https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2          && \
    tar xjvf nasm-2.13.03.tar.bz2                                                         && \
    cd nasm-2.13.03                                                                       && \
    ./autogen.sh                                                                          && \
    PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && \
    make                                                                                  && \
    make install

# Compile dependencies about :
# - libopus
# - libaom (AV1 video encoder / decoder)
RUN cd ~/ffmpeg_sources                                                                   && \
    git -C opus pull 2> /dev/null || git clone --depth 1 https://github.com/xiph/opus.git && \
    cd opus                                                                               && \
    ./autogen.sh                                                                          && \
    ./configure --prefix="$HOME/ffmpeg_build" --disable-shared                            && \
    make &&                                                                                  \
    make install
RUN cd ~/ffmpeg_sources                                                                                                                                       && \
    git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom                                                                  && \
    mkdir aom_build                                                                                                                                           && \
    cd aom_build                                                                                                                                              && \
    PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_TESTS=0 -DENABLE_SHARED=off -DENABLE_NASM=on ../aom && \
    PATH="$HOME/bin:$PATH" make                                                                                                                               && \
    make install

# Compile ffmpeg
RUN cd ~/ffmpeg_sources                                                                     && \
    wget -O ffmpeg.tar.bz2 https://ffmpeg.org/releases/ffmpeg-4.1.tar.bz2                   && \
    tar xjvf ffmpeg.tar.bz2                                                                 && \
    cd ffmpeg-4.1                                                                           && \
    PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure      \
        --prefix="$HOME/ffmpeg_build"                                                          \
        --pkg-config-flags="--static"                                                          \
        --extra-cflags="-I$HOME/ffmpeg_build/include"                                          \
        --extra-ldflags="-L$HOME/ffmpeg_build/lib"                                             \
        --extra-libs="-lpthread -lm"                                                           \
        --bindir="$HOME/bin"                                                                   \
        --enable-gpl                                                                           \
        --enable-libopus                                                                       \
        --enable-libaom                                                                     && \
    PATH="$HOME/bin:$PATH" make                                                             && \
    make install                                                                            && \
    hash -r