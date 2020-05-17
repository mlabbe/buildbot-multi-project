#!/bin/sh

cd letsencrypt
docker build -t frogtoss/letsencrypt .
cd ..

docker run --rm \
       -p 80:80 \
       -p 443:443 \
       --name letsencrypt \
       -v $(pwd)/mount:/etc/letsencrypt \
       -e "LETSENCRYPT_EMAIL=you@yourdomain.com" \
       -e "LETSENCRYPT_DOMAIN1=www.example.com" \
           frogtoss/letsencrypt install
