#!/bin/bash

HOME=/share/work/sra
DATA=/share/data/taxonomy/

DATE=`/bin/date '+%Y%m%d'`

cd $DATA

tar xzf taxdump.tar.gz
tar xzf taxcat.tar.gz

cd $HOME/taxontree
perl ./ext.node.pl $DATA > taxonomy.node.$DATE.tab
perl ./mk.tree.pl taxonomy.node.$DATE.tab > taxonomy.tree.$DATE.tab

rm taxonomy.tree.tab
ln -s taxonomy.tree.$DATE.tab taxonomy.tree.tab
mysql --local-infile -u sra -pshortread -b sra < taxonomy.tree.sql

mv data/study2.tab data/study2.$DATE.tab
mysql --local-infile -u sra -pshortread -b sra -e 'select * from study2 into outfile "/share/work/sra/taxontree/data/study2.tab";'

mv data/study2wtaxon.tab data/study2wtaxon.$DATA.tab
perl mk.study2wtaxon.pl --taxon taxonomy.tree.tab --study data/study2.tab > data/study2wtaxon.tab

# mysql -u sra -pshortread -b sra < mk.study2wtaxon.sql

mysql --local-infile -u sra -pshortread -b sra -e 'load data local infile "data/study2wtaxon.tab" replace into table study2wtaxon;'


