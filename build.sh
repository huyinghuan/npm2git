#!/bin/bash
set -e
VERSION=""
OUTPUT=""
COMMIT=""

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -o|--output)
    OUTPUT="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--commit)
    COMMIT="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters
VERSION="$1"
if [ "$VERSION" == "" ];then
    echo "版本号不能为空"
    exit 1
else
    VERSION=${VERSION}_mb
fi

if git rev-parse -q --verify "refs/tags/$VERSION" >/dev/null; then
    echo "版本号已存在，请使用其他版本号"
    exit 1
fi

if [ "$COMMIT" == "" ];then
    COMMIT="tag verion to ${VERSION}"
fi

if [ "$OUTPUT" == "" ];then
    OUTPUT="dist"
fi

projectName=${PWD##*/}
tempBranchName=build_${projectName}_${VERSION}
currentBranchName=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)

#临时分支存在时 删除临时分支
if [ `git branch --list $tempBranchName` ]; then
    if [ "$currentBranchName" == "$tempBranchName" ]; then
        git reset --hard HEAD
        git checkout master
        echo 当前切换到主分支 master, 如果 master 不是当前开发分支， 请手动切换到开发分支，
    fi
    git branch -D $tempBranchName
fi

echo workspace: $PWD
echo project: $projectName
echo version: $VERSION
echo current branch: $currentBranchName
echo output: $OUTPUT

npm run build
git checkout -b $tempBranchName
echo -e "node_modules\n.*" > .gitignore
for entry in "$PWD"/*
do
  if [ "$entry" != "$PWD/$OUTPUT" ] && [ "$entry" != "$PWD/node_modules" ] && [ "$entry" != "$PWD/.gitignore" ]; then
    rm -rf "$entry"
  fi
done
for f in .[^.]*; do
    if [ "$f" != ".git" ] && [ "$f" != ".gitignore" ];then
        rm -rf "$f"
    fi
done
git add .
git commit -m "$COMMIT"
git tag "$VERSION" -m "$COMMIT"
git checkout $currentBranchName
git checkout .gitignore
git branch -D $tempBranchName
git push --tags
echo ================
echo Tag $VERSION to server finish
echo ================