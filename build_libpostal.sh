#!/usr/bin/env bash
./bootstrap.sh
mkdir -p /opt/libpostal_data
mkdir -p /opt/libpostal
./configure --datadir=/opt/libpostal_data --prefix=/opt/libpostal DESTDIR=/opt/libpostal
make
make install
ldconfig
