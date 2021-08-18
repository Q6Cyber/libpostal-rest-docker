FROM golang:1.17.0-buster AS builder

ARG COMMIT
ENV COMMIT ${COMMIT:-master}
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y

RUN apt-get install -y \
    autoconf automake build-essential curl git libsnappy-dev libtool pkg-config

RUN cd / && git clone https://github.com/openvenues/libpostal -b $COMMIT

COPY ./*.sh /libpostal/

WORKDIR /libpostal
RUN ./build_libpostal.sh
ENV PKG_CONFIG_PATH=/opt/libpostal/lib/pkgconfig
RUN mkdir -p /libpostal/bin
RUN mkdir -p /libpostal/workspace
RUN cd workspace && git clone https://github.com/johnlonganecker/libpostal-rest.git -b master && cd libpostal-rest && go build -o /libpostal/bin/libpostal-rest

FROM debian:buster

RUN apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y

WORKDIR /

COPY --from=builder /libpostal/bin/libpostal-rest /
COPY --from=builder /opt/libpostal_data /opt/libpostal_data
COPY --from=builder /opt/libpostal /opt/libpostal

RUN cp -R /opt/libpostal/* /usr/local
RUN ldconfig

EXPOSE 8080

ENTRYPOINT ["/libpostal-rest"]


