#!/usr/bin/env bash

# $1 - the tint color. e.g., "#2e3440"

start_trayer() {
    echo " blab la $1"
    trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut false --expand true --monitor 1 --transparent true --alpha 0 --tint "$1" --height 20
}

restart_trayer() {

    killall trayer
    start_trayer "$1"

    # Ugly hack to fix artifacts on Dropbox icon.
    sleep 8
    killall trayer
    start_trayer "$1"
}

# e.g., "#2e3440" -> "0x2e3440"
tint=${1//#/0x}

restart_trayer "$tint"
