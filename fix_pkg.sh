#!/bin/bash

cd $PWD/vendor/$1 && find -name '*.pc' | while read pc; do sed -e "s@^prefix=.*@prefix=$PWD@" -i "$pc"; done
