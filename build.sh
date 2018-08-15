#!/bin/bash
set -e
version=$1
if [ "$1" == "" ];then
    echo "版本号不能为空"
    exit 1
else
    version=$1_mb
fi
commit=""
if [ $# ] && [ "$2" == "-m" ] && [ "$3" != "" ];then
    commit="$3"
fi
if [ "$commit" == "" ];then
    commit="tag verion to ${version}"
fi

projectName=${PWD##*/}
tempBranchName=build_${projectName}_${version}
currentBranchName=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
echo version: $version
echo workspace: $PWD
echo project: $projectName
echo current branch: $currentBranchName
npm run build
git checkout -b $tempBranchName
echo -e "node_modules\n.*" > .gitignore
for entry in "$PWD"/*
do
  if [ "$entry" != "$PWD/build" ] && [ "$entry" != "$PWD/node_modules" ] && [ "$entry" != "$PWD/.gitignore" ]; then
    rm -rf "$entry"
  fi
done
for f in .[^.]*; do
    if [ "$f" != ".git" ] && [ "$f" != ".gitignore" ];then
        rm -rf "$f"
    fi
done
git add .
git commit -m "$commit"
git tag "$version" -m "$commit"
git checkout $currentBranchName
git checkout .gitignore
git branch -D $tempBranchName
git push --tags
echo tag to $version finish
