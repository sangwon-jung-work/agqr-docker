FROM centos

MAINTAINER gecko655 <aqwsedrft1234@yahoo.co.jp>

WORKDIR /root

RUN echo "set -o vi" >> /etc/bashrc
RUN yum install git gcc openssl-devel make -y

RUN git clone git://git.ffmpeg.org/rtmpdump
RUN (cd rtmpdump && make SYS=posix && make install)
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/rtmpdump.conf
RUN ldconfig

CMD tail -f /dev/null
