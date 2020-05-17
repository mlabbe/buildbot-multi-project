#!/bin/bash

# this assumes init.sh was already run, which is necessary to create
# frogtoss/letsencrypt docker image

docker run --rm \
       -p 80:80 \
       -p 443:443 \
       --name letsencrypt \
       -v $(pwd)/mount:/etc/letsencrypt \
       -e "LETSENCRYPT_EMAIL=you@yourdomain.com" \
       -e "LETSENCRYPT_DOMAIN1=www.example.com" \
           frogtoss/letsencrypt renewal

