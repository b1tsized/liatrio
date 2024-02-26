#!/bin/bash

while [[ "$(curl -L -s -o /dev/null -w ''%{http_code}'' $1)" != "200" ]]; do sleep 1; done
