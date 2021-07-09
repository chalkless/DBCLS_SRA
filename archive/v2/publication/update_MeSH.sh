#!/bin/sh

## pubmedの特定のメッシュタームを見に行って、更新までやる．

## a.このプログラムと同じディレクトリ内に xml_files という名前のディレクトリが必要です．
## b.このプログラムを使うには、pythonのMySQLdbモジュールをインストールすることが必要です（casperにはしてあります）

# @editor: i_87, 24, June, 2011, make lastup file and move to today's dir

##------ parametor
## 今日の日付
today=`date '+%y%m%d'`
## メッシュ
mesh="High-Throughput%20Nucleotide%20Sequencing"
## 最終更新日のファイル
last_update_file="last_update.txt"
## えらーなど全てのログ
errlog=log/${today}/${today}'.'${mesh}'.log'
##------

if [ ! -d log/${today} ] # if today's dir is not exist, then make new dir
then
        mkdir log/${today}
fi

## errorlog に出力される
echo "0.today="${today} >> ${errlog}

## 1.MeSHタームを見に行って，pmidをとってくる
output1=${today}'.'${mesh}'.pmidlst'
echo "1.MeSH term -> pmid List :" >> ${errlog}
echo "- "${output1} >> ${errlog}
python pubmed_esearch_mesh.py ${mesh} ${output1} >> ${errlog} 2>&1

## 2.pubmedのIDのリストを渡すと，PubMed,PMCから取れるものは全てとってくる.. pmid2sra.pyが同じディレクトリ内に必要
##  最後の引数Tは、./xml_files/へ本文ファイルを残さないフラグ、Fにすると本文ファイルが残る．
output2=${output1}'.pmid2sra'
echo "2.pmid List -> all puid2sra and article data :" >> ${errlog}
echo "- "${output2} >> ${errlog}
python pmid2sra_list.py ${output1} ${output2} T ${errlog} >> ${errlog} 2>&1

## 3.PMCで本文が取れなかったものは、journalサイトにとりにいく．
output3=${output2}'.journal2sra'
echo "3.access to journal Sites :" >> ${errlog}
echo "- "${output3} >>  ${errlog}
python journal2sra.py ${output2} ${output3} ${errlog} >> ${errlog} 2>&1

## 4. SRAのIDがSRXなどになっているものを，SRAに名寄せする．mySQLを使用する
output4=${output3}'.xrx2xra'
echo "4.[SRA ID] xRx -> SRA : " >> ${errlog}
echo "- "${output4} >> ${errlog}
python xrx2xra_formysql.py ${output3} ${output4} ${errlog} >> ${errlog} 2>&1

## 5.これまでのpmidとsraのペアになかったものを出力する．mySQLを使用する．
add_file=${output4}
out_pmid2sra=${output4}'.diff_pmid2sra'
out_article=${output4}'.diff_pmid2sra_article'
echo "4.diff pmid2sra :" >> ${errlog}
echo "- "${out_pmid2sra} >> ${errlog}
echo "- "${out_article} >> ${errlog}
python diff_pmid2sra.py ${add_file} ${out_pmid2sra} ${out_article} >> ${errlog} 2>&1

## 6. output5のpmidとsraIDのペアと${out_article}のpmidの記事情報をMySQLにアップロードする
dir=`pwd`'/'
echo "6.update to MySQL :" >> ${errlog}
echo "- "${out_pmid2sra} >> ${errlog}
echo "- "${out_article} >> ${errlog}
python load_file.py ${dir}${out_pmid2sra} ${dir}${out_article} >> ${errlog} 2>&1

## 7. make file: last-update.txt
## this file is used to show last update day and add IDs in homepage
echo `date '+%Y'/%m/%d` > ${last_update_file}
echo 'from MeSH (pubmed)' >> ${last_update_file}
cat ${out_pmid2sra} >> ${last_update_file}

echo ${last_update_file} >> ${errlog}
echo "today update done." >> ${errlog}

## 8. move make files to today's dir
if [ ! -d update/${today} ] # if today's dir is not exist, then make new dir
then
	mkdir update/${today}
fi
mv ${today}.* update/${today}
