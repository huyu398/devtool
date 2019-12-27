#!/bin/sh

docker run \
    --shm-size 4gb \
    --mount type=bind,src=/home/$USER/,dst=/root \
    --workdir /root \
    --name dt \
    --rm -it devtool
