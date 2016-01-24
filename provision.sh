#!/bin/bash

apt-get update

# install some basics
apt-get -y install vim
apt-get -y install git


# Setup CouchDB
apt-get -y install couchdb

# Allow access from more than just localhost
curl -X PUT http://localhost:5984/_config/httpd/bind_address -d \"0.0.0.0\" -H "Content-Type: application/json"

# Enable CORS
curl -X PUT http://localhost:5984/_config/httpd/enable_cors -d '"true"'
curl -X PUT http://localhost:5984/_config/cors/origins -d '"*"'
curl -X PUT http://localhost:5984/_config/cors/credentials -d '"true"'
curl -X PUT http://localhost:5984/_config/cors/methods -d '"GET, PUT, POST, HEAD, DELETE"'
curl -X PUT http://localhost:5984/_config/cors/headers -d '"accept, authorization, content-type, origin, referer, x-csrf-token"'



