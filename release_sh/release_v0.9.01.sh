#!/bin/sh

git diff bb47089 8ca74aa --name-only > tar_list.txt

tar zcvf mtkcam3_IQ_v0p9p01.tgz --files-from=tar_list.txt

rm -f tar_list.txt

