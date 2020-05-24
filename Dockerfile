# Use the official image as a parent image.
FROM innovanon/poobuntu:latest
MAINTAINER Innovations Anonymous <InnovAnon-Inc@protonmail.com>

LABEL version="1.0"                                                        \
      maintainer="Innovations Anonymous <InnovAnon-Inc@protonmail.com>"    \
      about="Compile/Install InnovAnon, Inc. C libraries and applications" \
      org.label-schema.build-date=$BUILD_DATE                              \
      org.label-schema.license="PDL (Public Domain License)"               \
      org.label-schema.name="InnovAnon, Inc. C libraries and applications" \
      org.label-schema.url="InnovAnon-Inc.github.io/instAll"               \
      org.label-schema.vcs-ref=$VCS_REF                                    \
      org.label-schema.vcs-type="Git"                                      \
      org.label-schema.vcs-url="https://github.com/InnovAnon-Inc/instAll"

# Run the command inside your image filesystem.
# Copy the file from your host to your current location.
COPY dpkg.list .
RUN apt-fast install `grep -v '^[\^#]' dpkg.list`

#ENV B /tmp
ENV B /usr

# Do you want fewer intermediate containers
# or do you want to be able to pick up where you left off?
ARG OPT4SZ=0

ENV C_INCLUDE_PATH  /usr/local/include
# TODO these are probably superfluous
#ENV LD_LIBRARY_PATH /usr/local/lib
#ENV PATH            /usr/local/lib:${PATH}
#RUN rm -rf /usr/local/*/*

RUN mkdir -pv ${B}/src
# Set the working directory.
WORKDIR ${B}/src

COPY innovanon-inc-c.sh .
COPY reset* ./
RUN [ ${OPT4SZ} -eq 0 ] || ./innovanon-inc.c.sh
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh glitter
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh iSqrt
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh restart
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh ezfork
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh SFork
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh DFork
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh kahan
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh ZePaSt
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh MultiMalloc
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh swap
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh C-Thread-Pool
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh StD
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh Array
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh PArray
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh DArr
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh CAQ
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh CPAQ
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh TSCPAQ
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh CHeap
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh SLL
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh network
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh ezudp
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh eztcp
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh EZIO
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh EVIO
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh ThIpe
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh ThrIO
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh ThrEv
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh ThrEll
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh RW2ChIPC
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh RW2ChIPCStd
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh RW2ChIPCStdExec
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh ezparse
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh YACS
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh DOS
RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh shell
#RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh solar
#RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh lunar
#RUN [ ${OPT4SZ} -ne 0 ] || ./innovanon-inc-c.sh AVA
RUN rm -v innovanon-inc-c.sh



WORKDIR /

RUN apt-mark manual libev4                      \
 && apt-fast purge `grep -v '^[\^#]' dpkg.list` \
 && ./poobuntu-clean.sh                         \
 && rm -v dpkg.list

CMD ! command -v /bin/laden || /bin/laden && if [ -n "`find ${B}/src -mindepth 1 -maxdepth 1 -name '*.log' -print -quit`" ] ; then ls ${B}/src/*.log && cat ${B}/src/*.log ; fi

