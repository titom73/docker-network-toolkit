#!/bin/sh

curl -d @webhook-message.json -H 'Content-Type: application/json' http://localhost:8282/receiver