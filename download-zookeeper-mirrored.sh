#!/bin/bash -e

# shellcheck disable=SC1091
FILENAME="apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz"
MIRROR="http://mirrors.c0f3.net/apache/zookeeper"

url="${MIRROR}/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}"

echo "Downloading Zookeeper from $url"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"

cd /tmp
wget -U "${UA}" "${url}" -O "${FILENAME}"

url="${MIRROR}/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}.asc"
echo "ASC: $url"
wget -S -U "${UA}" "${url}"

url="${MIRROR}/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}.sha512"
echo "SHA512: $url"
wget -S -U "${UA}" "${url}"

wget -S -U "${UA}" --no-check-certificate -q https://www.apache.org/dist/zookeeper/KEYS

sha512sum -c "${FILENAME}.sha512"
gpg --import KEYS
gpg --verify "${FILENAME}.asc"
