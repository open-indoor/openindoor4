#!/bin/bash

set -x
set -e

for action in $(find /tmp/actions -name "*.sh"); do
  /bin/bash ${action}
  rm -rf ${action}
done