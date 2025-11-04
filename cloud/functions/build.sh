#!/bin/bash

set -ex

poetry config http-basic.gcp oauth2accesstoken "$(gcloud auth application-default print-access-token)"

cd colab_utils
poetry build
poetry publish -r gcp || echo "Colab utils package already published"
cd -

for FUNCTION in ./*; do
  if [ ! -d "$FUNCTION" ]; then
    echo "Function directory $FUNCTION does not exist, skipping..."
    continue
  fi
  if [ "$FUNCTION" == "./colab_utils" ]; then
    continue
  fi
  echo "Building function: $FUNCTION"
  cd "$FUNCTION" 
  poetry lock
  poetry export --without-hashes -f requirements.txt -o requirements.txt
  cd -
done
