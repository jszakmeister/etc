#!/bin/bash
vim -R -c ":set ft=man | SetupManPager" -MRn </dev/tty <(sed -e 's/\x1B\[[[:digit:]]\+m//g' | col -bx)

