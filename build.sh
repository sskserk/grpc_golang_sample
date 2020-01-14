#!/usr/bin/env bash
source $(dirname $0)/scripts/routines.sh
set -e

# set params/envs
BASE_DIR=$(base_folder)
BIN_OUTPUT_DIR="$BASE_DIR/bin"
#export GOPATH=$GOPATH:$BASE_DIR

unset GOPATH
export PATH=$PATH:~/go/bin

# echo params
echo
echo "PATH                :" $PATH
echo "Being used GOPATH   :" $GOPATH
echo "Binaries output path:" $BIN_OUTPUT_DIR

# create required paths
mkdir $BIN_OUTPUT_DIR -p

# generate code
protoc --go_out=plugins=grpc:internal/twit *.proto

# format code
echo
echo -n "Format source code..."
for code_path in cmd internal; do
    gofmt -w $code_path
done
echo -e "${GREEN}OK${NOCOLOR}"


# go vet
set +e
echo
echo -n "Run go vet        ..."
echo

RES=0
for top_dir in "cmd" ; do
    DIRS=`find $top_dir/ -type d`
    DIR_PATH_LEN_EXCLUDE=${#top_dir}+1
    echo $top_dir
    for DIR_ELEMENT in $DIRS; do
        PACKAGE=${DIR_ELEMENT:$DIR_PATH_LEN_EXCLUDE}
        
        if [  ${#PACKAGE} -ge 1 ]; then
            OLDP=`pwd`         
            cd $top_dir            
            go vet  $PACKAGE/*.go
            RES_TMP=$?
            if [ $RES_TMP -ne 0 ]; then
                RES=1
            fi
            cd $OLDP            
        fi   
    done
done

if [ $RES -eq 1 ]; then
    echo -e "${RED}FAIL${NOCOLOR}"
    exit 1
fi
echo -e "${GREEN}OK${NOCOLOR}"
set -e


# actual build
echo
echo -n "Actual build      ..."
for cmd in server client; do
    go build -o "$BIN_OUTPUT_DIR/$cmd" "./cmd/$cmd"
done
echo -e "${GREEN}OK${NOCOLOR}"
set +e

