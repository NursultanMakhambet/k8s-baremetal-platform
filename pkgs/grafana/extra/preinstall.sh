#!/bin/sh

set -e

getent group grafana > /dev/null || groupadd -r grafana
getent passwd grafana > /dev/null || \
    useradd -d /opt/grafana -g grafana -M -r grafana

exit 0
