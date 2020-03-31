set -e
pushd ../assembler
sh build.sh
popd 
pushd ../processor
sh build.sh
popd
# python uasm.py
pushd ../kernel
sh build.sh
popd
pushd ../basic
sh build.sh
popd
