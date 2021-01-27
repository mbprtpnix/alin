#!/bin/bash

set -e -u

sudo reflector --verbose --latest 25 --age 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
