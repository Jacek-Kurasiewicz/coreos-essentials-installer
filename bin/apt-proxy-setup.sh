#!/bin/bash -ex
# see:
# https://github.com/sameersbn/docker-apt-cacher-ng
# https://gist.github.com/dergachev/8441335

# Make script gives up on any error
set -e

APT_PROXY_PORT=3142
echo "APT_PROXY_PORT :${APT_PROXY_PORT}"

rm -rf /etc/apt/apt.conf.d/01proxy

HOST_IP=$(awk '/^[a-z]+[0-9]+\t00000000/ { printf("%d.%d.%d.%d\n", "0x" substr($3, 7, 2), "0x" substr($3, 5, 2), "0x" substr($3, 3, 2), "0x" substr($3, 1, 2)) }' < /proc/net/route)
nc -z -v -w2 ${HOST_IP} ${APT_PROXY_PORT} && AVAILABLE=1 || AVAILABLE=0

if [ ! -z "$APT_PROXY_PORT" ] && [ ! -z "$HOST_IP" ] && [[ 1 -eq $AVAILABLE ]]; then
	echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy
	echo "Acquire::HTTP::Proxy \"http://${HOST_IP}:${APT_PROXY_PORT}\";"  >> /etc/apt/apt.conf.d/01proxy
    cat /etc/apt/apt.conf.d/01proxy
    echo "Using host's apt proxy"
else
    echo "No squid-deb-proxy detected on docker host"
fi