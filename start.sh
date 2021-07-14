#!/bin/bash

PORT=30000

open -F http://localhost:$PORT ;
docsify s -p $PORT
