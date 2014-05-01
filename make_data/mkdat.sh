#!/bin/bash


###
### Settings
###

HOME=/share/work/sra
DIR=/share/data/sra/Submissions/
DIR_META=/share/data/sra_meta/list/

PATH=
# PERL5LIB=


while getopts sb OPT
do
    case $OPT in
	s) NOSYNC="TRUE";;
	b) NOBACKUP="TRUE";;
    esac
done

DATE=`/bin/date '+%Y%m%d'`

cd $HOME

# echo $PATH >> ./log/tmp.$DATE.log
# echo $PERL5LIB >> ./log/tmp.$DATE.log


###
### Download Data
###

if [ "$NOSYNC" != "TRUE" ]; then

    lftp -f ./dramirror.lftp 1>> "./log/sra-mirror.$DATE.log" 2>> "./log/sra-error.$DATE.log"

    lftp -e 'mirror --delete --only-newer --verbose /ddbj_database/dra/meta/list/ /share/data/sra_meta/"; quit' ftp://ftp.ddbj.nig.ac.jp/ 1>> "./log/meta-mirror.$DATE.log" 2>> "./log/meta-error.$DATE.log"

    lftp -e 'mirror --delete --only-newer --verbose /ddbj_database/bioproject/ /share/data/bioproject/ddbj/; quit' ftp://ftp.ddbj.nig.ac.jp/ 1>> "./log/biopj-ddbj-mirror.$DATE.log" 2>> "./log/biopj-ddbj-error.$DATE.log"

    lftp -e 'mirror --delete --only-newer --verbose /bioproject/ /share/data/bioproject/ncbi/; quit' ftp://ftp.ncbi.nlm.nih.gov/ 1>> "./log/biopj-ncbi-mirror.$DATE.log" 2>> "./log/biopj-ncbi-error.$DATE.log"

fi


###
### Backup
###

if [ "$NOBACKUP" != "TRUE" ]; then
    mysqldump -u sra -p password sra > ./dump/sra.mysql.$DATE.dump
fi


###
### Arrange Data
###

$HOME/makedata.pl -r $DIR -m $DIR_META > $HOME/log/makedata.$DATE.log 2>> $HOME/log/makedata.$DATE.err

exit 0;




