#!/usr/bin/env bash
#
# Common functions
#


function max() {
  cat - | awk '{if(max<$0) max=$0} END{print max}'
}
export -f max


function min() {
  cat - | awk '{if(min>$0) min=$0} END{print min}'
}
export -f min


function test1() {
  cat -
}
export -f test1