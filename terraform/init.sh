#!/usr/bin/bash

sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
sudo yum install ansible -y
cd /home/ec2-user/mongodb-ansible
ansible-playbook -b mongo.yml
