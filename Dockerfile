# This is a slightly modified version of the Dockerfile included in the
# Official pytorch/glow repository
# https://github.com/pytorch/glow/blob/master/utils/docker/Dockerfile

FROM ubuntu:18.04

ARG WORKDIR=/root/dev

# Create working folder
RUN mkdir -p $WORKDIR
WORKDIR $WORKDIR

# Update and install tools
RUN apt-get update && \
    apt-get install -y clang clang-8 cmake graphviz libpng-dev \
        libprotobuf-dev llvm-8 llvm-8-dev ninja-build protobuf-compiler wget \
        opencl-headers libgoogle-glog-dev libboost-all-dev \
        libdouble-conversion-dev libevent-dev libssl-dev libgflags-dev \
        libjemalloc-dev libpthread-stubs0-dev \
        # Additional dependencies
        git python-numpy patchelf vim \
        # ARM cross compiler and libraries
        gcc-multilib-arm-linux-gnueabihf g++-multilib-arm-linux-gnueabihf && \
    # Delete outdated llvm to avoid conflicts
    apt-get autoremove -y llvm-6.0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Point clang to llvm-8 version
RUN update-alternatives --install /usr/bin/clang clang \
        /usr/lib/llvm-8/bin/clang 50 && \
    update-alternatives --install /usr/bin/clang++ clang++ \
        /usr/lib/llvm-8/bin/clang++ 50

# Point default C/C++ compiler to clang
RUN update-alternatives --set cc /usr/bin/clang && \
    update-alternatives --set c++ /usr/bin/clang++

# Install fmt
RUN git clone https://github.com/fmtlib/fmt && \
    mkdir fmt/build && \
    cd fmt/build && \
    cmake .. && make && \
    make install

# Clean up
RUN rm -rf fmt

# Install glow from source
RUN mkdir -p $WORKDIR/Build_Debug
RUN git clone https://github.com/pytorch/glow.git && cd glow && git submodule update --init --recursive
RUN cd Build_Debug && cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug ../glow && ninja all

# update cmake from source after glow is installed
RUN wget https://github.com/Kitware/CMake/releases/download/v3.23.2/cmake-3.23.2.tar.gz && \
    tar -xzf cmake-3.23.2.tar.gz && \
    cd cmake-3.23.2 && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf cmake-3.23.2 cmake-3.23.2.tar.gz

ENV GLOW_SOURCE_DIR=/root/dev/glow
ENV PATH="$PATH:/root/dev/glow/Build_Debug/bin" 

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
