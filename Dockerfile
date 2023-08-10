ARG from=ubuntu:22.04
FROM ${from} as build

ARG BUILDARCH
ENV BUILDARCH=$BUILDARCH

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y 
RUN apt install -y ssl-cert make libpcap-dev libtalloc2 libreadline8 libsqlite-dev \
                   libsqlite3-0 libwbclient-dev libhiredis-dev libpython3-dev python3 \
                   redis-server neovim

WORKDIR /
COPY data/freeradius /etc/freeradius


COPY data/pkg/$BUILDARCH /tmp

WORKDIR /tmp
RUN dpkg -i freeradius-common_3.2.3+git_all.deb	
RUN dpkg --force-all -i freeradius-config_3.2.3+git_${BUILDARCH}.deb
RUN dpkg -i libfreeradius3_3.2.3+git_${BUILDARCH}.deb 
RUN dpkg -i freeradius_3.2.3+git_${BUILDARCH}.deb 
RUN dpkg -i freeradius-utils_3.2.3+git_${BUILDARCH}.deb 
RUN dpkg -i freeradius-redis_3.2.3+git_${BUILDARCH}.deb 
RUN dpkg -i freeradius-python3_3.2.3+git_${BUILDARCH}.deb 

RUN chown -R freerad:freerad /etc/freeradius && chmod -R 744 /etc/freeradius


COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 1812/udp 1813/udp
ENTRYPOINT ["/docker-entrypoint.sh"] 
CMD ["/etc/init.d/freeradius start"]
