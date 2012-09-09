#!/bin/bash

#version of ENet to use
ENET_VERSION="1.3.5"

#default path to emscripten
EMSCRIPTEN_HOME="${HOME}/Dev/emscripten"

# Retrieve EMSCRIPTEN path to use
EMSCRIPTEN=$1
if [ "${EMSCRIPTEN}" == "" ]
then
	EMSCRIPTEN=${EMSCRIPTEN_HOME}
fi

echo "Emscripten path: ${EMSCRIPTEN}"

if [ ! -e "${EMSCRIPTEN}/emcc" ]
then
  echo "Please specify a valid path to emscripten."
  exit 1
fi


# download and unzip ENet
if [ ! -e "enet-${ENET_VERSION}.tar.gz" ]
then
  curl -O "http://enet.bespin.org/download/enet-${ENET_VERSION}.tar.gz"
fi

#configure the library
if [ ! -e "enet-${ENET_VERSION}/config.status" ]
then
	tar xzf "enet-${ENET_VERSION}.tar.gz"
	pushd "enet-${ENET_VERSION}"
	BASEDIR=$(dirname $(pwd))
	${EMSCRIPTEN}/emconfigure ./configure --libdir=${BASEDIR}/libs --includedir=${BASEDIR}/include
	popd
fi

pushd "enet-${ENET_VERSION}"
#build/rebuild the library..
make
make install
popd

#compile test app
pushd "test"
export EMCC="${EMSCRIPTEN}/emcc"
make -e test
popd

#run the test
node test

