#!/bin/bash

sudo yum update -y
sudo yum install -y telnet
sudo yum -y install emacs
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user