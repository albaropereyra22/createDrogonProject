#! /bin/sh -

#  variables
drogonDir="/opt/drogon";
createDrogonProjectDir="/opt/createDrogonProject";

#  update createDrogonProject
cd $createDrogonProjectDir;
git pull;

#  update drogon
which drogon_ctl;
if [ $? != 1 ];
then
  cd $drogonDir;
  git pull;
  git submodule update --init;
  mkdir -p build;
  cd build;
  cmake -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl -DOPENSSL_LIBRARIES=/usr/local/opt/openssl/lib -DCMAKE_BUILD_TYPE=Release ..;
  make && sudo make install;
fi
