#!/bin/bash

set -e # setting the automatic exit, if we get error, set -ex for debug

failure(){
echo "Failed at : $1:$2"
}
trap 'failure "${LINENO}" "$BASH_COMMAND"' ERR #ERR is the error signal
echo "hello world success"
echoo "hellow world failure"
echo "hello world after failure"