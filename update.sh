#!/bin/bash

set -eo pipefail

declare -a versions=(
  3.5
  3.4
  3.3
)

for version in "${versions[@]}"
do
  rm -rf "$version"
  cp -R base "$version"

  cat > "$version/Dockerfile" <<-END
# Generated automatically by update.sh
# Do no edit this file

FROM bigtruedata/cron:$version

COPY dump-entrypoint /usr/local/bin/

VOLUME /dump
WORKDIR /dump

CMD ["dump-entrypoint"]
END

done
