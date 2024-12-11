#!/bin/bash -e

# shellcheck disable=SC1091
FILENAME="apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz"

url=$(curl --stderr /dev/null "https://www.apache.org/dyn/closer.cgi?path=/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}&as_json=1" | jq -r '"\(.preferred)\(.path_info)"')
# Test to see if the suggested mirror has this version
# do not appear to be actively mirrored. This may also be useful if closer.cgi is down.
if [[ ! $(curl -s -f -I "${url}") ]]; then
    echo "Mirror does not have desired version, downloading direct from Apache"
    url="https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}"
fi

echo "Downloading Zookeeper from $url"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"

cd /tmp
wget -U "${UA}" "${url}" -O "${FILENAME}"
wget -U "${UA}" -q https://www.apache.org/dist/zookeeper/KEYS
wget -U "${UA}" -q "https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}.asc"
wget -U "${UA}" -q "https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${FILENAME}.sha512"

sha512sum -c "${FILENAME}.sha512"
gpg --import KEYS
gpg --verify "${FILENAME}.asc"
