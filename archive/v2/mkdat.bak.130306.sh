#!

HOME=/share/work/sra
DIR=/share/data/sra/Submissions/

DATE=`/bin/date '+%Y%m%d'`

cd $HOME

#RSYNC_PASSWORD="shira@mars.dbcls.jp" rsync -avz --delete --include "*/" --include "*.xml" --exclude "*" anonymous@ftp.ncbi.nlm.nih.gov::sra/Submissions/* $DIR

lftp -f ./dramirror.lftp 1> "./log/sra-mirror.$DATE.log" 2> "./log/sra-error.$DATE.log"

lftp -e 'mirror --delete --only-newer --verbose /ddbj_database/dra/meta/list/ /share/data/sra_meta/' ftp://ftp.ddbj.nig.ac.jp/ 1> "./log/meta-mirror.$DATE.log" 2> "./log/meta-error.$DATE.log"

lftp -e 'mirror --delete --only-newer --verbose /ddbj_database/bioproject/ /share/data/bioproject/ddbj/' ftp://ftp.ddbj.nig.ac.jp/ 1> "./log/biopj-ddbj-mirror.$DATE.log" 2> "./log/biopj-ddbj-error.$DATE.log"

lftp -e 'mirror --delete --only-newer --verbose /bioproject/ /share/data/bioproject/ncbi/' ftp://ftp.ncbi.nlm.nih.gov/ 1> "./log/biopj-ncbi-mirror.$DATE.log" 2> "./log/biopj-ncbi-error.$DATE.log"


# lftp -e 'du -m .' ftp://ftp.ddbj.nig.ac.jp/ddbj_database/ > /share/work/sra/log/du-m

mysqldump -u sra -pshortread sra > ./dump/sra.mysql.$DATE.dump

#cp $HOME/taxid/scientificname /tmp
#mysql -u sra -pshortread -b sra < $HOME/sql/init.sql
#PERL5LIB=$HOME $HOME/makedata.pl -r $DIR >  $HOME/log/makedata.$DATE.log 2> $HOME/log/makedata.$DATE.err
#PERL5LIB=$HOME $HOME/makerss2.pl > $HOME/rsslog 2>&1
#mysql -u sra -pshortread -b sra < $HOME/sql/fwd.sql
