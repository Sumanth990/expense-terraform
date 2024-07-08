#!/bin/bash

yum install ansible python3.12-pip -y &>>/opt/userdata.log
pip3.12 install botocore boto3 -y &>>/opt/userdata.log
ansible-pull -i localhost, -U https://github.com/Sumanth990/expense-ansible.git expense.yml -e role_name=${role_name}-e env=${env} &>>/opt/userdata.log