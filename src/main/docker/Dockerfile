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
# References :
# - https://ffmpeg.org/download.html#releases
# - https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
# - https://bitbucket.org/multicoreware/x265/wiki/Home
# - https://github.com/jrottenberg/ffmpeg
# - https://docs.docker.com/develop/develop-images/multistage-build/
# - https://github.com/Netflix/vmaf/blob/master/resource/doc/libvmaf.md

# ==============================================================================
# /!\ BUILD STAGE ONLY /!\
# 
# Build sources.
# 
# Don't optimize layer count or layer size here.
# Focus on maintenability.
# ==============================================================================
FROM ubuntu:18.04 AS builder

# Set library URLs
ARG NASM_URL=https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2
ARG ZIMG_URL=https://github.com/sekrit-twc/zimg/archive/release-2.9.2.tar.gz
ARG OPUS_URL=https://github.com/xiph/opus/archive/v1.3.tar.gz
ARG AOM_URL=https://aomedia.googlesource.com/aom
ARG VPX_URL=https://chromium.googlesource.com/webm/libvpx.git
ARG X264_URL=https://code.videolan.org/videolan/x264.git
ARG X265_URL=https://bitbucket.org/multicoreware/x265/downloads/x265_3.2.1.tar.gz
ARG VMAF_URL=https://github.com/Netflix/vmaf/archive/v1.3.15.tar.gz
ARG FFMPEG_URL=https://ffmpeg.org/releases/ffmpeg-4.2.1.tar.bz2

# "Server" install without ffplay. Omit some dependencies.
RUN apt-get update                                                          && \
    apt-get -y install                                                         \
        autoconf                                                               \
        automake                                                               \
        build-essential                                                        \
        cmake                                                                  \
        git-core                                                               \
        libtool                                                                \
        pkg-config                                                             \
        texinfo                                                                \
        wget                                                                   \
        zlib1g-dev

# Put source directory to home directory
RUN mkdir -p ~/ffmpeg_sources ~/bin

# Install YASM assembler (used by some library)
RUN apt-get install -y yasm

# Compile and install NASM assembler (used by some library)
RUN cd ~/ffmpeg_sources                                                     && \
    wget -O nasm.tar.bz2 --no-check-certificate ${NASM_URL}                 && \
    tar xjf nasm.tar.bz2                                                    && \
    cd nasm-*                                                               && \
    ./autogen.sh                                                            && \
    ./configure                                                             && \
    make                                                                    && \
    make install

# Compile and install libzimg (zscale)
RUN cd ~/ffmpeg_sources                                                     && \
    wget -q -O zimg.tar.gz ${ZIMG_URL}                                      && \
    tar xzf zimg.tar.gz                                                     && \
    cd zimg-release-*                                                       && \
    ./autogen.sh                                                            && \
    ./configure                                                                \
        --disable-shared                                                       \
        --enable-static                                                     && \
    make                                                                    && \
    make install

# Compile and install libopus (opus) from tarball
RUN cd ~/ffmpeg_sources                                                     && \
    wget -q -O opus.tar.gz ${OPUS_URL}                                      && \
    tar xzf opus.tar.gz                                                     && \
    cd opus-*                                                               && \
    ./autogen.sh                                                            && \
    ./configure                                                                \
        --disable-shared                                                    && \
    make                                                                    && \
    make install

# Compile and install libaom (AV1) from git
RUN cd ~/ffmpeg_sources                                                     && \
    git clone ${AOM_URL}                                                    && \
    cd aom                                                                  && \
    git checkout v1.0.0                                                     && \
    mkdir ~/ffmpeg_sources/aom_build                                        && \
    cd    ~/ffmpeg_sources/aom_build                                        && \
    cmake                                                                      \
        -G "Unix Makefiles"                                                    \
        -DENABLE_TESTS=0                                                       \
        -DENABLE_SHARED=off                                                    \
        -DENABLE_NASM=on                                                       \
        ../aom &&                                                              \
    make                                                                    && \
    make install

# Compile and install libvpx (VP8-VP9) from git
RUN cd ~/ffmpeg_sources                                                     && \
    git clone ${VPX_URL}                                                    && \
    cd libvpx                                                               && \
    git checkout v1.7.0                                                     && \
    ./configure                                                                \
        --disable-examples                                                     \
        --disable-unit-tests                                                   \
        --enable-vp9-highbitdepth                                              \
        --as=yasm                                                           && \
    make                                                                    && \
    make install

# Compile and install libx264 (H264 / AVC) from git
RUN cd ~/ffmpeg_sources                                                     && \
    git clone ${X264_URL}                                                   && \
    cd x264                                                                 && \
    git checkout stable                                                     && \
    ./configure                                                                \
        --enable-static                                                        \
        --enable-pic                                                        && \
    make                                                                    && \
    make install

# Compile and install libx265 (H265 / HEVC) from tarball
COPY multilib.sh /tmp
RUN cd ~/ffmpeg_sources                                                     && \
    wget -q -O  x265.tar.gz ${X265_URL}                                     && \
    tar xzf x265.tar.gz                                                     && \
    cd x265_*/build/linux                                                   && \
    mv /tmp/multilib.sh . && chmod u+x multilib.sh && ./multilib.sh         && \
    make --directory=8bit install

# Compile and install libvmaf from tarball
RUN cd ~/ffmpeg_sources                                                     && \
    wget -q -O vmaf.tar.gz ${VMAF_URL}                                      && \
    tar xzf vmaf.tar.gz                                                     && \
    cd vmaf-*                                                               && \
    cd ptools     && make                                                   && \
    cd ../wrapper && make                                                   && \
    cd ../        && make install

# Compile and install ffmpeg from tarball
# Default install is '/usr/local/bin/ffmpeg'
RUN cd ~/ffmpeg_sources                                                     && \
    wget -q -O ffmpeg.tar.bz2 ${FFMPEG_URL}                                 && \
    tar xjf ffmpeg.tar.bz2                                                  && \
    cd ffmpeg-*                                                             && \
    ./configure                                                                \
        --pkg-config-flags="--static"                                          \
        --extra-libs="-lpthread -lm"                                           \
        --enable-gpl                                                           \
        --enable-libopus                                                       \
        --enable-libaom                                                        \
        --enable-libvpx                                                        \
        --enable-libx264                                                       \
        --enable-libx265                                                       \
        --enable-libzimg                                                       \
        --enable-libvmaf                                                       \
        --enable-version3                                                   && \
    make                                                                    && \
    make install

# ==============================================================================
# /!\ RELEASE STAGE ONLY /!\
# 
# Just copy ffmpeg binary previously builded from "build" image
# ==============================================================================
FROM ubuntu:18.04

# Copy VMAF models
COPY --from=builder /usr/local/share/model /usr/local/share/model

# Copy ffmpeg binary to /usr/local/bin
COPY --from=builder /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
