#! /usr/bin/env sh
docker rm -f i2p-zero-build
docker run -td --name i2p-zero-build --rm ubuntu
docker exec -ti i2p-zero-build bash -c '
  apt-get update && 
  apt-get -y install git wget zip unzip && 
  git clone https://github.com/i2p-zero/i2p-zero.git && 
  cd i2p-zero && bash bin/build-all-and-zip.sh'
docker cp i2p-zero-build:/i2p-zero/dist-zip ./
docker container stop i2p-zero-build
