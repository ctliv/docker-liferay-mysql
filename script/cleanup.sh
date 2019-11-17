#!/bin/bash

find /var/liferay/logs/ -type f -ctime +15 -delete
find /var/tomcat/logs/ -type f -ctime +15 -delete
