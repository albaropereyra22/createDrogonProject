#! /bin/sh -

#  This software is free
cd /opt/createDrogonProject;
git pull;

which -s drogon_ctl;
if [ $? != 0 ];
then
  cd ~/drogon;
  git pull;
  git submodule update --init;
  mkdir build
  cd build;
  cmake -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl -DOPENSSL_LIBRARIES=/usr/local/opt/openssl/lib -DCMAKE_BUILD_TYPE=Release ..;
  make && sudo make install;
fi
