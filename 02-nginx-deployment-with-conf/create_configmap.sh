#!/bin/bash

kubectl create configmap nginx-conf-name --from-file nginx-conf=nginxconf -n nginx-frontend
