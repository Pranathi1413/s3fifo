#!/bin/bash 
set -euo pipefail


SORUCE=$(readlink -f ${BASH_SOURCE[0]})
DIR=$(dirname ${SORUCE})

cd ${DIR}/../;
mkdir -p _build || true 2>/dev/null;
cd _build;
cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5  .. \
        -DCMAKE_INSTALL_PREFIX=$HOME/.local \
    -DCMAKE_PREFIX_PATH=$CONDA_PREFIX \
    -DGLIB_INCLUDE_DIRS="$CONDA_PREFIX/include/glib-2.0;$CONDA_PREFIX/lib/glib-2.0/include";

make -j;
cd ${DIR};
