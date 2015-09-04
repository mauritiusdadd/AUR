#!/usr/bin/bash

#expac -S %v w3m | awk -F - '{print $1}'
#cower -i w3m-mouse --format "%v"

source info-database.sh

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

getVerExpac()
{
  curver="$(expac -S %v $1)"

}

checkSourceforge()
{
  oldver="$(getCurrentVersion $1)"
  fname="/tmp/${1}.rss"
  url="http://sourceforge.net/projects/$1/rss?path=/$1"

  wget -q --no-clobber "${url}" -O "${fname}"
  curver="$(awk -F '/' '/.tar.gz/ {print $3; exit}' ${fname})"

  if [[ $? -eq 0 ]]; then
    if [[ ${oldver} != ${curver} ]]; then
      echo "${oldver} -> ${curver})"
    else
      echo "updated (${curver})"
    fi
  else
    echo "[!]"
  fi
}

checkGitHubRelease()
{
  oldver="$(getCurrentVersion $2)"
  frmt="\/$1\/$2\/tree\/(.*?)"
  url="https://github.com/$1/$2/releases"
  curver="$(checkUrlLink $url $frmt)"

  if [[ $? -eq 0 ]]; then
    if [[ ${oldver} != ${curver} ]]; then
      echo "${oldver} -> ${curver})"
    else
      echo "updated (${curver})"
    fi
  else
    echo "[!]"
  fi
}

checkExpac()
{
  db_var="EXPAC_VER_$1"
  curver="$(expac -S %v $1)"
  oldver="${!db_var}"
  if [[ $? -eq 0 ]]; then
    if [[ ${oldver} != ${curver} ]]; then
      echo "${oldver} -> ${curver}"
    else
      echo "updated"
    fi
  else
    echo "[!]"
  fi
}

getSRCINFO()
{
  wget -O- -q "https://aur.archlinux.org/cgit/aur.git/plain/.SRCINFO?h=$1"
}

checkUrlLink()
{
  wget -O- -q "$1"  | perl -lne "
    /href[ ]*=[ ]*[\047\042]$2[\042\047]/;
    if  (\$1 ne '')
    {
      print \$1;
      exit 0;
    }"
}

checkCalculix()
{

  oldver="$(getCurrentVersion ${pkgname})"

  url="http://www.dhondt.de/index.html"
  ccx_frmat='ccx_(.+?)\.src\.tar\.bz2'
  cgx_frmat='cgx_(.+?)\.all\.tar\.bz2'

  ccx_ver="$(checkUrlLink ${url} ${ccx_frmat})"
  cgx_ver="$(checkUrlLink ${url} ${cgx_frmat})"

  ccx_ups="ccx_${ccx_ver}.src.tar.bz2"
  cgx_ups="cgx_${cgx_ver}.all.tar.bz2"

  srcinfo="$(getSRCINFO 'calculix')"

  ccx_src="$(echo -e $srcinfo | grep -oP 'ccx_.+?\.bz2')"
  cgx_src="$(echo -e $srcinfo | grep -oP 'cgx_.+?\.bz2')"

  outdate=0

  if [[ "${ccx_ups}" != "${ccx_src}" ]]; then
    let outdate+=1
  fi

  if [[ "${cgx_ups}" != "${cgx_src}" ]]; then
    let outdate+=2
  fi

  if [[ $outdate -eq 0 ]]; then
    echo "updated"
  elif [[ $outdate -eq 1 ]]; then
    echo "${oldver} -> cgx:${ccx_ver}"
  elif [[ $outdate -eq 2 ]]; then
    echo "${oldver} -> cgx:${cgx_ver}"
  elif [[ $outdate -eq 3 ]]; then
    echo "${oldver} -> ccx:${ccx_ver} cgx:${cgx_ver}"
  else
    echo "[!]"
  fi
}

needsUpdate()
{
  case $1 in
    "w3m-mouse")
      checkExpac w3m
      ;;
    "makedumpfile")
      checkSourceforge $1
      ;;
    "calculix")
      checkCalculix
      ;;
    "calculix-doc")
      ;;
    "crtwo2fits")
      checkGitHubRelease 'mauritiusdadd' $1
      ;;
    "lxnstack")
      checkGitHubRelease 'mauritiusdadd' $1
      ;;
    *)
      echo "??"
      ;;
  esac
}

for x in "$AURDIR"/*/; do
  pkgname="$(basename $x)"
  pkgver="$(getCurrentVersion $pkgname)"
  iood="$(isOutOfDate $pkgname)"
  needupd="$(needsUpdate $pkgname)"
  printf "%3s -- %-20s\t(%s)\t[%s]\n" "$iood" "$pkgname" "$pkgver" "$needupd"
done

