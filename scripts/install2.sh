#!/bin/bash -ex
mkdir build
cd build
sudo apt-get install git python-pip
git clone https://github.com/insanity54/gst-switch.git
cd gst-switch
chmod +x .travis-setup.sh
./.travis-setup.sh
