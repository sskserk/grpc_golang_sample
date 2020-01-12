#!/usr/bin/env bash

RED="\033[0;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"


function base_folder() {
    cd `dirname $0` && pwd
}