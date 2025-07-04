#! /bin/sh -

# Variables
dir="$(dirname $0)";
script="$dir/$(basename $0)";
binDir="$dir/bin";
installer="installer.sh";
exeName="$(expr $script : '.*/\(.*\)\..*')";
todaysDate="$(date +%m%d%Y)";
private="false";
user="$(whoami)";
optDir="/opt";
# Disclaimer
printf "WARNING:\n";
printf "This software is in beta, subject to change and prone to errors.\n";

# updateSoftware
cp bin/createDrogonProjectUpdater.sh ~/bin/;
cd ~/bin;
./createDrogonProjectUpdater.sh
# Get arguments:
# I personally enjoy doing this first. That being said if you are
# using functions or need to refer to variables not yet assigned
# you can get into a lot of trouble it is recomended to do this
# at the end of the shell script.
#
# Note:
# if the option has an argument add a ':' after the option.
while getopts :hl:n:p OPT; do
  case "X$OPT" in
    "Xh"|"X+h")
      cat <<EOF
Use this script to create a new Drogon project.
You can learn more about Drogon here:
https://drogon.docsforge.com/master/overview/

-h
    Display this usage.

-n [(cammelCase name of software)]
    Use this option to specifie the name of the software.   
-p
    Use this option to make the repository private.

NOTE:
This script has only been tested on Mac OS X.

BUGS:
This software is in beta stage and it is subject to change and prone to errors.

EOF
      exit 0;
      ;;
    "Xn"|"X+n")
      softwareName="$OPTARG";
      ;;

    "Xp"|"X+p")
      private=true;
      ;;
    *)
      printf "usage: %s [-hp] [-n (cammelCase program name)]\n" "$exeName" >&2;
      exit 2;
  esac
done
shift $(expr $OPTIND - 1)
OPTIND=1

which drogon_ctl;
# $? exit status of previous command
if [ $? != 0 ];
then
  # Install Drogon
  chmod u+x ${binDir}/${installer};
  sh ${binDir}/${installer}
fi


if [ -z "$softwareName" ];
then
  # prompt for repo dir
  printf "Enter softwareName(i.e rubbish, bestSoftware etc.): ";
  read softwareName;
fi


#  TODO git@github.com:albaropereyra22/$softwareName.git;
if [ -z "$gitServer" ];
then
  printf "Enter git server name(i.e git@github.com, al@server.com etc.): ";
  read gitServer;
fi

if [ -z "$ghUserName" ]
then
  printf "Enter GitHub User Name(i.e albaropereyra22, opt etc.): ";
  read ghUserName;
fi

remoteGitRepo="${gitServer:=git@github.com}:${ghUsername:=albaropereyra22}/${softwareName}.git";
repoDir="${optDir}/${softwareName}";

# Create repo on Github
gitDir="${repoDir}/.git/";
cd $optDir;
if [ $private ];
then
  gh repo create "$softwareName" --private;
else
  gh repo create "$softwareName" --public;
fi
drogon_ctl create project $softwareName;
cd $repoDir;
# This can probably be cleaner with find.
mkdir -p build;
cd build;
cmake -DCMAKE_BUILD_TYPE=Release ..;
make;
./$softwareName&
cd ..;
git init;
git add .;
git commit -m "first commit";
git branch -M main;
git remote add origin $remoteGitRepo;
git push -u origin main;
