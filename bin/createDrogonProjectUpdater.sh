#! /bin/sh -

#  variables
drogonDir="/opt/drogon/";
createDrogonProjectDir="/opt/createDrogonProject/";
exeName="createDrogonProject.sh";
binDir="~/bin/";
#  update createDrogonProject
cd $createDrogonProjectDir;
git pull;

#  update brew or apt
OS=$(uname -s)
if [  "XDarwin"="X${OS}" ];
then
  # check if brew is installed or install it on install.sh
  brew update;
  brew upgrade;
else
  echo "other OS"
fi
#  update drogon
which drogon_ctl;
if [ $? != 1 ];
then
  cd $drogonDir;
  git pull;
  git submodule update --init;
  mkdir -p build;
  cd build;
  cmake -DCMAKE_BUILD_TYPE=Release ..;
  make && sudo make install;
fi

cp "${$createDrogonProjectDir}${exeName}" "${binDir}";
