#!/bin/bash

HOME=/share/work/sra
DATE=`/bin/date '+%Y%m%d'`

cd $HOME

mysqldump -u sra -pshortread -q -t sra study2 article study2wtaxon sum_exp sum_run view_all > transfer/mysql.sra.$DATE.dump

scp -qpi /home/sra/.ssh/dbcls-sra-aws-tokyo.pem transfer/mysql.sra.$DATE.dump ec2-user@52.193.26.230:~/transfer/
