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

REPO=aaronsfishman/bov-tb
LATEST_DOCKERFILE_URL="https://raw.githubusercontent.com/APHA-CSU/BovTB-nf/master/Dockerfile"
ENDPOINT=$REPO:$TAG

# Login
echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

# Build image if it differs from master 
if ! curl $LATEST_DOCKERFILE_URL | cmp ./Dockerfile >/dev/null 2>&1; then
    docker build -t $ENDPOINT .
else
    docker tag $REPO:latest $ENDPOINT
fi

# Push
docker push $ENDPOINT