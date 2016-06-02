FROM centos

MAINTAINER gecko655 <aqwsedrft1234@yahoo.co.jp>

WORKDIR /root

RUN echo "set -o vi" >> /etc/bashrc
RUN yum install git gcc openssl-devel make crontabs -y

RUN git clone git://git.ffmpeg.org/rtmpdump
RUN (cd rtmpdump && make SYS=posix && make install)
# http://qiita.com/yayugu/items/12c0ffd92bc8539098b8
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/rtmpdump.conf 
RUN ldconfig
# http://blogs.yahoo.co.jp/mrsd_tangerine/40359620.html

RUN touch /tmp/cron.log
COPY src/rec.sh rec.sh

CMD /sbin/init 
