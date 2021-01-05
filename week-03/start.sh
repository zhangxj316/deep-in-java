#!/bin/bash
#

port=9090

echo "service is start,Please use a browser to access the address:http://127.0.0.1/${port}/file/showAll"

curPath=$(cd `dirname $0`; pwd)

java -jar demo-1.0.0.1.jar --server.port=${port}


