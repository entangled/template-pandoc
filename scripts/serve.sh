#!/bin/bash

dir=$(mktemp -d)
echo "Copying to ${dir}"
copier copy . "${dir}"
pushd "${dir}"
entangled tangle
brei weave
popd

browser-sync start -w -s "${dir}/docs/site" &
browser_sync_pid=$!

while true; do
  echo "Watching for changes"
  inotifywait -r -e close_write template || break
  copier recopy "${dir}" -A -w
  pushd "${dir}"
  entangled tangle
  brei weave -B
  popd
done

kill -INT ${browser_sync_pid}
rm -rf ${dir}
