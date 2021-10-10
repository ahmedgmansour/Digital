#!/bin/bash

# usage: ./minio-upload my-bucket my-file.zip minio-host.com access_key secret

bucket=$1
file=$2
minio_host=$3
access_key=$4
secret=$5

host=${S3_HOST:-$minio_host}
s3_key=${S3_KEY:-$access_key}
s3_secret=${S3_SECRET:-$secret}

base_file=`basename ${file}`
resource="/${bucket}/${base_file}"
content_type="application/octet-stream"
date=`date -R`
_signature="PUT\n\n${content_type}\n${date}\n${resource}"
signature=`echo -en ${_signature} | openssl sha1 -hmac ${s3_secret} -binary | base64`

# change to https

curl -v -X PUT -T "${file}" \
          -H "Host: $host" \
          -H "Date: ${date}" \
          -H "Content-Type: ${content_type}" \
          -H "Authorization: AWS ${s3_key}:${signature}" \
          http://$host${resource}
