FROM ubuntu:18.04
MAINTAINER swjung89 <sangwon-jung-work@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y software-properties-common build-essential libxml2-utils wget curl git libxml2-utils openssl libssl-dev tzdata
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
RUN mkdir /var/src
WORKDIR /var/src

RUN wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz && tar zxvf yasm-1.2.0.tar.gz && cd yasm-1.2.0 && ./configure && make && make install
RUN git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg && cd ffmpeg && ./configure --enable-openssl && make && make install

RUN echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf && ldconfig
ADD rec_agqr.sh /usr/local/bin/rec_agqr.sh
RUN chmod +x /usr/local/bin/rec_agqr.sh
RUN mkdir /var/agqr
WORKDIR /var/agqr
ENTRYPOINT ["/usr/local/bin/rec_agqr.sh"]
