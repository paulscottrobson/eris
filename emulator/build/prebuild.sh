set -e
pushd ../assembler >/dev/null
sh build.sh
popd >/dev/null
pushd ../processor >/dev/null
sh build.sh
popd >/dev/null
#python uasm.py
pushd ../kernel >/dev/null
sh build.sh
popd >/dev/null
pushd ../basic >/dev/null
sh build.sh
popd >/dev/null