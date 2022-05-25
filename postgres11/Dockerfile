FROM debian:11

MAINTAINER rmorozov

ENV TZ=Europe/Moscow

RUN apt update -y && apt install -y nano curl htop wget
RUN apt install -y sysstat libicu67 
COPY *.deb /opt/
RUN apt install -y /opt/*.deb
RUN mkdir -p /d01/postgres/11 &&\
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen 

COPY sleep.sh /opt/
CMD ["/opt/sleep.sh"]



