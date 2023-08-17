#!/bin/bash

mkdir build
cd build
cmake -G "Ninja Multi-Config" -B . -S .. -DCED_BUILD_DOCUMENTATION:BOOL=ON
