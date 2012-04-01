#!/bin/bash
view -c ":set ft=man | SetupManPager" -MRn </dev/tty <(sed -e 's/\x1B\[[[:digit:]]\+m//g' | col -bx)

