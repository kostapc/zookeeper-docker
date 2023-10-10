#!/bin/bash -e

# shellcheck disable=SC1091
FILENAME="apache-zookeeper-${ZOOKEEPER_VERSION}.tar.gz"

#url=$(curl --stderr /dev/null "https://www.apache.org/dyn/closer.cgi?path=/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}&as_json=1" | jq -r '"\(.preferred)\(.path_info)"')
url=$(curl --insecure --stderr /dev/null "https://www.apache.org/dyn/closer.cgi?path=/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}&as_json=1" | jq -r '"\(.preferred)\(.path_info)"')
# Test to see if the suggested mirror has this version
# do not appear to be actively mirrored. This may also be useful if closer.cgi is down.
if [[ ! $(curl -s -f -I "${url}") ]]; then
    echo "Mirror does not have desired version, downloading direct from Apache"
    url="https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}"
fi

echo "Downloading Zookeeper from $url"

cd /tmp
wget --no-check-certificate "${url}" -O "${FILENAME}"
wget --no-check-certificate -q https://www.apache.org/dist/zookeeper/KEYS
wget --no-check-certificate -q "https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}.asc"
wget --no-check-certificate -q "https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}.sha512"

sha512sum -c "${FILENAME}.sha512"
gpg --import KEYS
gpg --verify "${FILENAME}.asc"
