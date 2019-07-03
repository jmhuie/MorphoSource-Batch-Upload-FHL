#!/bin/bash
set -e
set -u
set -o pipefail
if test -d ./unzips
then
    rm -r ./unzips
fi
if test -d ./ToUpload
then
    rm -r ./ToUpload
fi
if test -f ./BatchWorksheet.xlsx
then
    rm BatchWorksheet.xlsx
fi
if test -f ./filenames.txt
then
    rm ./filenames.txt
fi
