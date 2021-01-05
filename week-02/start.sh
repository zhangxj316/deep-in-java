#!/bin/bash

echo 'service is start,please use the command:nc 127.0.0.1 8877'
curPath=$(cd `dirname $0`; pwd)
java -jar netty-demo-1.0.0.jar 8877
