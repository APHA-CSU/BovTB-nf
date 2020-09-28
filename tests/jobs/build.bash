#!/bin/sh
#
#================================================================
# build.bash
#================================================================
#
#% DESCRIPTION
#%    Builds the nextflow pipeline and pushes to dockerhub


TAG=$1
DOCKER_USER=$2
DOCKER_PASS=$3

LATEST_DOCKERFILE=$(curl https://raw.githubusercontent.com/APHA-CSU/BovTB-nf/master/Dockerfile)

# Pull 
if ! echo $LATEST_DOCKERFILE | cmp ./Dockerfile >/dev/null 2>&1
then
    echo They are the same!
fi



# docker build -t aaronsfishman/bov-tb:$TAG .
# echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
# docker push aaronsfishman/bov-tb:$TAG