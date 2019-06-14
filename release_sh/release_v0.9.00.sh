#!/bin/sh

git diff acd2fdc c8a625e --name-only > tar_list.txt
git diff fb447e5 bb47089 --name-only >> tar_list.txt

tar zcvf mtkcam3_IQ_v0p9p00.tar --files-from=tar_list.txt

