#!/usr/bin/env bash
#
#  ASIX AX88179 DKMS driver installation program
#  Copyright (C) 2024 by Florian LAUNAY
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

pkgname="asix-ax88179"
pkgver="$(git describe --tags 2> /dev/null || echo 'No tag found' >&2)"
archivename="ASIX_USB_NIC_Linux_Driver_Source_v${pkgver}"
archiveurl="https://www.asix.com.tw/en/support/download/file/1893"
drvname="ax_usb_nic"
srcdir="/usr/src/${pkgname}-${pkgver}"
log="/var/lib/dkms/${pkgname}/${pkgver}/build/make.log"

usage() {
  echo "Usage: $0 [options]"
  echo
  echo 'Options:'
  echo '  -h  Display usage and exit'
  echo '  -u  Uninstall'
  echo
  echo 'Example:'
  echo "  to install: $0"
  echo "  to uninstall: $0 -u"
}

build() {
  echo "Downloading sources and configuring DKMS..."
  mkdir -p "${srcdir}"
  if wget -q --show-progress -O - "${archiveurl}" | tar -xj -C "${srcdir}" --no-same-owner --transform "s/${archivename}/./g"; then
    install -D -m 644 dkms.conf "${srcdir}/dkms.conf"
    sed -i "s/#PKGNAME#/${pkgname}/" "${srcdir}/dkms.conf"
    sed -i "s/#PKGVER#/${pkgver}/" "${srcdir}/dkms.conf"
    sed -i "s/#DRVNAME#/${drvname}/" "${srcdir}/dkms.conf"
    echo -e "Done\n"
    
    echo "Building with DKMS..."
    if dkms install -m "${pkgname}" -v "${pkgver}"; then
      echo -e "Done\n"
    
      echo "Configuring driver..."
      install -D -m 644 udev.rules "/etc/udev/rules.d/90-${pkgname}.rules"
      install -D -m 644 modprobe-blacklist.conf "/etc/modprobe.d/${pkgname}.conf"
      modprobe -r ax88179_178a
      udevadm control --reload-rules && udevadm trigger
      echo "Done"
    else
      echo "Build error" >&2
      if [ -r "$log" ]; then
        cat "$log" >&2
      fi
    
      exit 1
    fi
  else
    echo "Download error" >&2
    exit 1
  fi
}

uninstall() {
  status="$(dkms status ${pkgname})"
  if [ -n "$status" ]; then
    echo "Uninstalling driver ${pkgname} version ${pkgver}..."
    modprobe -r "${drvname}"
    dkms remove -m "${pkgname}" -v "${pkgver}"
    rm -rf "${srcdir}"
    rm -f "/etc/udev/rules.d/90-${pkgname}.rules"
    rm -f "/etc/modprobe.d/${pkgname}.conf"
    modprobe ax88179_178a
    udevadm control --reload-rules && udevadm trigger
    echo "Done"
  else
    echo "Driver ${pkgname} is not installed!" >&2
    exit 1
  fi
}

while getopts 'hu' opt; do
  case "${opt}" in
    h) usage; exit 0;;
    u) [ -n "$pkgver" ] || exit 1; uninstall; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
done

[ -n "$pkgver" ] || exit 1
build
# vim: set sw=2 sts=2 et :
