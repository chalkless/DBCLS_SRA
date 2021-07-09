#!/bin/bash

DATE=`/bin/date '+%y%m%d'`

root_log=/share/work/sra/publication/log/$DATE
log=sra2pub.$DATE.log
err=sra2pub.$DATE.err

mkdir $root_log

date >> $root_log$log

cd /share/work/sra/publication

bash update_MeSH.sh >> $root_log$log 2>> $root_log$err

bash update_SRADB.sh >> $root_log$log 2>> $root_log$err

bash update_GEO.sh >> $root_log$log 2>> $root_log$err
