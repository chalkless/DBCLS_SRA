#!/bin/bash

HOME=/share/work/sra
DIR=/share/data/sra/Submissions/
DIR_META=/share/data/sra_meta/list/

PATH=/share/pkgs/perlbrew/perls/perl-5.14.2/bin:$PATH
PERL5LIB=$HOME:/share/pkgs/perlbrew/perls/perl-5.14.2/lib/site_perl/5.14.2:$PERL5LIB


while getopts sb OPT
do
    case $OPT in 
	s) NOSYNC="TRUE";;
	b) NOBACKUP="TRUE";;
    esac
done

DATE=`/bin/date '+%Y%m%d'`

cd $HOME


echo $PATH > ./log/geo.$DATE.log
echo $PERL5LIB > ./log/geo.$DATE.log


if [ "$NOSYNC" != "TRUE" ]; then
#    RSYNC_PASSWORD="shira@mars.dbcls.jp" rsync -avz --delete --include "*/" --include "*.xml" --exclude "*" anonymous@ftp.ncbi.nlm.nih.gov::sra/Submissions/* $DIR

#    lftp -f ./dramirror.lftp 1> "./log/sra-mirror.$DATE.log" 2> "./log/sra-error.$DATE.log"

#    lftp -e 'mirror --delete --only-newer --verbose /ddbj_database/dra/meta/list/ /share/data/sra_meta/; quit' ftp://ftp.ddbj.nig.ac.jp/ 1> "./log/meta-mirror.$DATE.log" 2> "./log/meta-error.$DATE.log"

    lftp -f ./geomirror.lftp 1> "./log/geo-mirror.$DATE.log" 2> "./log/geo-error.$DATE.log"

#    lftp -e 'mirror --delete --only-newer --verbose /ddbj_database/bioproject/ /share/data/bioproject/ddbj/; quit' ftp://ftp.ddbj.nig.ac.jp/ 1> "./log/biopj-ddbj-mirror.$DATE.log" 2> "./log/biopj-ddbj-error.$DATE.log"

#    lftp -e 'mirror --delete --only-newer --verbose /bioproject/ /share/data/bioproject/ncbi/; quit' ftp://ftp.ncbi.nlm.nih.gov/ 1> "./log/biopj-ncbi-mirror.$DATE.log" 2> "./log/biopj-ncbi-error.$DATE.log"

    # lftp -e 'du -m .' ftp://ftp.ddbj.nig.ac.jp/ddbj_database/ > /share/work/sra/log/du-m
fi

#if [ "$NOBACKUP" != "TRUE" ]; then
#    mysqldump -u sra -pshortread sra > ./dump/sra.mysql.$DATE.dump
#fi

#cp $HOME/taxid/scientificname /tmp
#mysql -u sra -pshortread -b sra < $HOME/sql/init.sql
#PERL5LIB=$HOME $HOME/makedata.pl -r $DIR -m $DIR_META >  $HOME/log/makedata.$DATE.log 2> $HOME/log/makedata.$DATE.err
#PERL5LIB=$HOME $HOME/makerss2.pl > $HOME/log/rss.$DATE.log 2> $HOME/log/rss.$DATE.err
#mysql -u sra -pshortread -b sra < $HOME/sql/fwd.sql

exit 0;

