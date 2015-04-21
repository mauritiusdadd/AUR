#!/usr/bin/sh

#expac -S %v w3m | awk -F - '{print $1}'
#cower -i w3m-mouse --format "%v"

[[ -z $AURDIR ]] && export AURDIR="$(pwd)"

getCurrentVersion()
{
  cower -i --format '%v' "$1" 2>/dev/null |  awk -F - '{print $1}'
  [[ ${PIPESTATUS[0]} -eq 0 ]] ||  echo "??"
}

isOutOfDate()
{
  cower -i --format '%t' "$1" 2>/dev/null
  [[ ${PIPESTATUS[0]} -eq 0 ]] ||  echo "??"
}

for x in "$AURDIR"/*/; do
  pkgname="$(basename $x)"
  pkgver="$(getCurrentVersion $pkgname)"
  iood="$(isOutOfDate $pkgname)"
  echo -e "$iood -- $pkgname $pkgver"
done

