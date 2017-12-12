#!/usr/bin/env bash

function solc-err-only {
    solc "$@" 2>&1 | grep -A 2 -i "Error"
}

solc-err-only --overwrite --optimize --bin --abi ./contracts/WrisxToken.sol -o ./build/
cd ./build
wc -c WrisxToken.bin | awk '{print "WrisxToken: " $1}'
