#!/usr/bin/env bash

DATE=$(date +'%Y%m%d%H%M')
cp -rf configs configs-$DATE

if [[ -d gen ]]; then
   rm -rf gen
fi

ROOT=$(pwd)

BUILD_ID=$(date +'%Y-%m-%d-%H%M')
PROJECTS="docs python go java js ruby rust perl net c spec swift dart cli"
for i in $PROJECTS; do
    git clone git@$1.com:$2/$3-$i.git gen/$3-$i
    cd gen/$3-$i
    git checkout -b build/$BUILD_ID
    cd $ROOT
done

SPEC=$4
function generate() {
    BUILD=0
    if [[ -f gen/$2/BUILD ]]; then
        OLD_MINOR=$(cat gen/$2/BUILD | cut -d '.' -f 2)
        OLD_BUILD=$(cat gen/$2/BUILD | cut -d '.' -f 3)
        if [ "$OLD_MINOR" == "$DATE" ]; then
            BUILD=$((OLD_BUILD + 1))
        fi
    fi

    sed -i "s|TIMESTAMP|$DATE|g" configs-$DATE/*.json
    sed -i "s|BUILD|$BUILD|g" configs-$DATE/*.json


    docker run --rm -v "${PWD}:/local:Z" -v "$(readlink -f $SPEC):/tmp/openapi.yml:Z" --user "$(id -u):$(id -g)" openapitools/openapi-generator-cli generate \
        -i  /tmp/openapi.yml \
        -g $1 \
        -o /local/gen/$2 \
        -c /local/configs-$DATE/$1.json \
        -t /local/templates/$1 \
        --api-name-suffix \
        --remove-operation-prefix \
        --api-name-suffix ''

     echo 0.$DATE.$BUILD > gen/$2/BUILD
     sed  -i 's/GIT_USER_ID/umbeluzi/g' **/*/*.md
     sed  -i "s/GIT_REPO_ID/$2/g" **/*/*.md

     cp LICENSE-$4 gen/$2/LICENSE
}

generate java $3-java openapi.yml Apache-2.0
generate rust $3-rust openapi.yml Apache-2.0
generate csharp-netcore $3-net openapi.yml Apache-2.0
generate ruby $3-ruby openapi.yml Apache-2.0
generate python $3-python openapi.yml Apache-2.0
generate php $3-php openapi.yml Apache-2.0
generate javascript $3-js openapi.yml Apache-2.0
generate go $3-go openapi.yml Apache-2.0
generate perl $3-perl openapi.yml Apache-2.0
generate markdown $3-docs openapi.yml Apache-2.0
generate dart $3-dart openapi.yml Apache-2.0
generate swift5 $3-swift openapi.yml Apache-2.0

sed  -r -i 's|json:"(.*)"|json:"\1" yaml:"\1"|g' gen/**/model_*.go

rm -rf configs-$DATE


cd gen/$3cli
openapi-cli-generator init $3
openapi-cli-generator generate $ROOT/openapi.yml
cd $ROOT

PARENT=$(pwd)
for i in $(ls gen); do
    cd gen/$i
    git add :/
    git commit -m "Build $BUILD_ID"
    git push origin build/$BUILD_ID
    cd $PARENT
done
