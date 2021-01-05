#!/bin/bash

pid=$(ps -ef | grep 'demo' | grep -v grep | awk '{print $2}')

kill -9 $pid || echo 无服务