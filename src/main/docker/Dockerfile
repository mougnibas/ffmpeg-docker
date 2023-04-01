# (c) Copyright 2018-2020 Yoann MOUGNIBAS
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
FROM ubuntu:22.04 AS builder

# tzdata installation hack
ARG DEBIAN_FRONTEND=noninteractive

# Install "generic" build related tools
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

# Install VMAF build related tools
# "xdd" tool MUST be there at compilation time to avoid "model not found" error.
RUN apt-get update                                                          && \
    apt-get -y install                                                         \
        xxd                                                                    \
        python3                                                                \
        python3-pip                                                            \
        python3-setuptools                                                     \
        python3-wheel                                                          \
        ninja-build doxygen                                                 && \
    pip3 install meson

# Put source directory to home directory
RUN mkdir -p ~/ffmpeg_sources ~/bin

# Install YASM assembler (used by some library)
RUN apt-get install -y yasm

# Compile and install NASM assembler (used by some library)
ARG NASM_URL=https://www.nasm.us/pub/nasm/releasebuilds/2.15/nasm-2.15.tar.bz2
RUN cd ~/ffmpeg_sources                                                     && \
    wget -O nasm.tar.bz2 --no-check-certificate ${NASM_URL}                 && \
    tar xjf nasm.tar.bz2                                                    && \
    cd nasm-*                                                               && \
    ./autogen.sh                                                            && \
    ./configure                                                             && \
    make                                                                    && \
    make install

# Compile and install libzimg (zscale)
#ARG ZIMG_URL=https://github.com/sekrit-twc/zimg/archive/refs/tags/release-3.0.4.tar.gz
#RUN cd ~/ffmpeg_sources                                                     && \
#    wget -q -O zimg.tar.gz ${ZIMG_URL}                                      && \
#    tar xzf zimg.tar.gz                                                     && \
#    cd zimg-release-*                                                       && \
#    ./autogen.sh                                                            && \
#    ./configure                                                                \
#        --disable-shared                                                       \
#        --enable-static                                                     && \
#    make                                                                    && \
#    make install

# Compile and install libopus (opus) from tarball
#ARG OPUS_URL=https://github.com/xiph/opus/archive/v1.3.1.tar.gz
#RUN cd ~/ffmpeg_sources                                                     && \
#    wget -q -O opus.tar.gz ${OPUS_URL}                                      && \
#    tar xzf opus.tar.gz                                                     && \
#    cd opus-*                                                               && \
#    ./autogen.sh                                                            && \
#    ./configure                                                                \
#        --disable-shared                                                    && \
#    make                                                                    && \
#    make install

# Compile and install libaom (AV1) from git
#ARG AOM_URL=https://aomedia.googlesource.com/aom
#ARG AOM_TAG=v3.4.0
#RUN cd ~/ffmpeg_sources                                                     && \
#    git clone ${AOM_URL}                                                    && \
#    cd aom                                                                  && \
#    git checkout ${AOM_TAG}                                                 && \
#    mkdir ~/ffmpeg_sources/aom_build                                        && \
#    cd    ~/ffmpeg_sources/aom_build                                        && \
#    cmake                                                                      \
#        -G "Unix Makefiles"                                                    \
#        -DENABLE_TESTS=0                                                       \
#        -DENABLE_SHARED=off                                                    \
#        -DENABLE_NASM=on                                                       \
#        ../aom &&                                                              \
#    make                                                                    && \
#    make install

# Compile and install libvpx (VP8-VP9) from git
#ARG VPX_URL=https://chromium.googlesource.com/webm/libvpx.git
#ARG VPX_TAG=v1.12.0
#RUN cd ~/ffmpeg_sources                                                     && \
#    git clone ${VPX_URL}                                                    && \
#    cd libvpx                                                               && \
#    git checkout ${VPX_TAG}                                                 && \
#    ./configure                                                                \
#        --disable-examples                                                     \
#        --disable-unit-tests                                                   \
#        --enable-vp9-highbitdepth                                              \
#        --as=yasm                                                           && \
#    make                                                                    && \
#    make install

# Compile and install libx264 (H264 / AVC) from git
#ARG X264_URL=https://code.videolan.org/videolan/x264.git
#ARG X264_COMMIT=baee400fa9ced6f5481a728138fed6e867b0ff7f
#RUN cd ~/ffmpeg_sources                                                     && \
#    git clone ${X264_URL}                                                   && \
#    cd x264                                                                 && \
#    git checkout ${X264_COMMIT}                                             && \
#    ./configure                                                                \
#        --enable-static                                                        \
#        --enable-pic                                                        && \
#    make                                                                    && \
#    make install

# Compile and install libx265 (H265 / HEVC) from tarball
ARG X265_URL=https://bitbucket.org/multicoreware/x265_git/downloads/x265_3.5.tar.gz
RUN cd ~/ffmpeg_sources                                                     && \
    wget -q -O  x265.tar.gz ${X265_URL}                                     && \
    tar xzf     x265.tar.gz                                                 && \
    cd x265_*/build                                                         && \
    cmake ../source -DENABLE_SHARED=OFF -DENABLE_CLI=OFF                    && \
    make install

## Compile and install libvmaf from tarball
ARG VMAF_URL=https://github.com/Netflix/vmaf/archive/refs/tags/v2.3.1.tar.gz
RUN cd ~/ffmpeg_sources                                                     && \
    wget -q -O vmaf.tar.gz ${VMAF_URL}                                      && \
    tar xzf vmaf.tar.gz                                                     && \
    cd vmaf-*                                                               && \
    cd libvmaf                                                              && \
    meson build -Denable_tests=false                                           \
                -Denable_docs=false                                            \
                --buildtype=release                                            \
                --default-library=static                                    && \
    ninja -vC build                                                         && \
    ninja -vC build install

# Compile and install ffmpeg from tarball
# Default install is '/usr/local/bin/ffmpeg'
ARG FFMPEG_URL=https://ffmpeg.org/releases/ffmpeg-5.1.tar.bz2
RUN cd ~/ffmpeg_sources                                                     && \
    wget -q -O ffmpeg.tar.bz2 ${FFMPEG_URL}                                 && \
    tar xjf ffmpeg.tar.bz2                                                  && \
    cd ffmpeg-*                                                             && \
    ./configure                                                                \
        --pkg-config-flags="--static"                                          \
        --extra-libs="-lpthread -lm"                                           \
        --ld="g++"                                                             \
        --enable-static                                                        \
        --enable-gpl                                                           \
        --enable-version3                                                      \
        --enable-libx265                                                       \
        --enable-libvmaf                                                    && \
    make                                                                    && \
    make install

# ==============================================================================
# /!\ RELEASE STAGE ONLY /!\
# 
# Just copy ffmpeg binary previously builded from "build" image
# ==============================================================================
FROM ubuntu:22.04

# Copy ffmpeg binary to /usr/local/bin
COPY --from=builder /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg

# Go to this working directory
WORKDIR /mnt/encode