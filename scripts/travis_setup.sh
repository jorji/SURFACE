#!/bin/bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then

	brew update
	# Install gcc 4.8
	brew install gcc48

else	# guess linux

	sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
	sudo apt-get update
	sudo apt-get install -yq build-essential gcc-4.8 g++-4.8 cmake make bison flex libpthread-stubs0-dev
	sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6
	sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.8
	echo 2 | sudo update-alternatives --config gcc

fi
