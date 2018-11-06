#!/bin/bash

kubectl create secret generic -n nginx-frontend my-pub-key --from-file pubkey=$HOME/.ssh/id_rsa.pub
