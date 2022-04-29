###########################################################################################
## evoxd Dockerfile
###########################################################################################

#
# Usage:
# (make sure you have correct permission for /var/data/evox-data prior to run!)
#
#   docker run --restart=always -v /var/data/evox-data:/home/evox/.Evox -p 11121:11121 -p 11211:11211 --name=evoxd -dit sowle/evox-full-node
#
# To get into container and interact with the daemon:
#   docker attach evoxd
#
# To detach from container and left it running:
#   Ctrl+P, Ctrl+Q
#
# To stop container:
#   docker stop evoxd
#

#
# Build Evox
#

FROM ubuntu:18.04 as evox-build

RUN apt update && \
    apt install -y build-essential \
    libicu-dev \
    curl \
    g++ \
    git


WORKDIR /root

# CMake 3.15.5

RUN curl https://github.com/Kitware/CMake/releases/download/v3.15.5/cmake-3.15.5-Linux-x86_64.sh -OL &&\
    echo '62e3e7d134a257e13521e306a9d3d1181ab99af8fcae66699c8f98754fc02dda cmake-3.15.5-Linux-x86_64.sh' | sha256sum -c - &&\
    mkdir /opt/cmake &&\
    sh cmake-3.15.5-Linux-x86_64.sh --prefix=/opt/cmake --skip-license &&\
    ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake &&\
    cmake --version &&\
    rm cmake-3.15.5-Linux-x86_64.sh

# Boost 1.68

RUN curl  https://boostorg.jfrog.io/artifactory/main/release/1.68.0/source/boost_1_68_0.tar.bz2 -OL &&\
    echo '7f6130bc3cf65f56a618888ce9d5ea704fa10b462be126ad053e80e553d6d8b7 boost_1_68_0.tar.bz2' | sha256sum -c - &&\
    tar -xjf boost_1_68_0.tar.bz2 &&\
    rm boost_1_68_0.tar.bz2 &&\
    cd boost_1_68_0 &&\
    ./bootstrap.sh --with-libraries=system,filesystem,thread,date_time,chrono,regex,serialization,atomic,program_options,locale,timer &&\
    ./b2 &&\
    cd ..

ENV BOOST_ROOT=/root/boost_1_68_0

# Evox

RUN pwd && mem_avail_gb=$(( $(getconf _AVPHYS_PAGES) * $(getconf PAGE_SIZE) / (1024 * 1024 * 1024) )) &&\
    make_job_slots=$(( $mem_avail_gb < 4 ? 1 : $mem_avail_gb / 4)) &&\
    echo make_job_slots=$make_job_slots &&\
    set -x &&\
    git clone --single-branch https://github.com/evolution-project/zano.git &&\
    cd evox &&\
    git submodule update --init --recursive &&\
    mkdir build && cd build &&\
    cmake -D STATIC=TRUE .. &&\
    make -j $make_job_slots daemon simplewallet


#
# Run Evox
#

FROM ubuntu:18.04

RUN useradd -ms /bin/bash evox &&\
    mkdir -p /home/evox/.Evox &&\
    chown -R evox:evox /home/evox/.Evox

USER evox:evox

WORKDIR /home/evox
COPY --chown=evox:evox --from=evox-build /root/evox/build/src/evoxd .
COPY --chown=evox:evox --from=evox-build /root/evox/build/src/simplewallet .

# blockchain loaction
VOLUME /home/evox/.Evox

EXPOSE 11121 11211

ENTRYPOINT ["./evoxd"]
CMD ["--disable-upnp", "--rpc-bind-ip=0.0.0.0", "--log-level=0"]
