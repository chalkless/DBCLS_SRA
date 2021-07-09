#!/bin/sh

## DDBJ?のデータベースをHDに落としてきたものを、
## 探索して、SRAとPMIDのペアをMySQLに入力する．

## a.このプログラムと同じディレクトリ内に xml_files という名前のディレクトリが必要です．
## b.このプログラムを使うには、pythonのMySQLdbモジュールをインストールすることが必要です（casperにはしてあります）

##------ parametor
## 今日の日付
today=`date '+%y%m%d'`
## dirname
dirname='/share/data/sra/Submissions/'
dbname='DDBJ'
## 最終更新日のファイル
last_update_file="last_update.txt"
## えらーなど全てのログ
errlog=log/${today}/${today}'.'${dbname}'.log'
##------

if [ ! -d log/${today} ] # if today's dir is not exist, then make new dir
then
	mkdir log/${today}
fi

# nohup に出力される
echo "0.today="${today} > ${errlog}

## 1.dirname以下のファイルのパスを全て拾い、output1に出力する
##(ここで、studyファイルだけ出力するかが未定)
## pubmedが含まれるファイルパスのみ出力
output1=${today}'.'${dbname}'.filenamelst'
echo "1. :"${dirname}"-> all file path list" >> ${errlog}
echo "- "${output1} >> ${errlog}
grep -l -r pubmed ${dirname} > ${output1}

## 2.ファイルのパスが書かれたリストを渡すと、ファイルを読んでSRAID,PMIDらしきもののペアを出力する（重複なし）
output2=${output1}'.PMSRAfromDB'
echo "2. : all file path list -> (PMID,xRxID) pair list" >> ${errlog}
echo "- "${output2} >> ${errlog}
python getPMSRAfromDB.py ${output1} ${output2} ${errlog} >> ${errlog} 2>&1

##　ここまで手に入ったpmidは適当な数字なのかpmidなのかが分かっていないので調べたい
## 3. pmidがmysqlの中にあるかを調べる．
##      ->あれば何もしないでファイルに出力する
##      ->なければ、pubmedに取りに行く．
##          ->あれば文献情報も取る.
##          ->なければerrorlogに出力
##    出力はpmid,文献情報,sraidとする.
##  最後の引数Tは、./xml_files/へ本文ファイルを残さないフラグ、Fにすると本文ファイルが残る．
output3=${output2}'.pmid2sra'
echo "3. : (PMID,xRxID) pair list -> all pmid2xRx and article data " >> ${errlog}
echo "- "${output3} >> ${errlog}
python getUpdatePMD.py ${output2} ${output3} T ${errlog} >> ${errlog} 2>&1

## 4.SRAIDをxRx-> SRAに寄せる．
## SRAのIDがSRXなどになっているものを，SRAに名寄せする．mySQLを使用する. 重複なしで出力する
output4=${output3}'.xrx2xra'
echo "4. : (PMID,xRxID) pair list -> (PMID,xRAID) pair list" >> ${errlog}
echo "- "${output4} >> ${errlog}
echo "- "${output4error} >> ${errlog}
python xrx2xra_formysql.py ${output3} ${output4} ${errlog} >> ${errlog} 2>&1

## 5.これまでのpmidとsraのペアになかったものを出力する．mySQLを使用する．
add_file=${output4}
out_pmid2sra=${output4}'.diff_pmid2sra'
out_article=${output4}'.diff_pmid2sra_article'
echo "5.diff pmid2sra :" >> ${errlog}
echo "- "${out_pmid2sra} >> ${errlog}
echo "- "${out_article} >> ${errlog}
python diff_pmid2sra.py ${add_file} ${out_pmid2sra} ${out_article} >> ${errlog} 2>&1

## 6. output5のpmidとsraIDのペアと${out_article}のpmidの記事情報をMySQLにアップロードする
dir=`pwd`'/'
echo "6.update to MySQL :" >> ${errlog}
echo "- "${out_pmid2sra} >> ${errlog}
python load_file.py ${dir}${out_pmid2sra}  ${dir}${out_article} >> ${errlog} 2>&1

## 7. make file: last-update.txt
## this file is used to show last update day and add IDs in homepage
echo `date '+%Y'/%m/%d` >> ${last_update_file}
echo 'from DDBJ DB' >> ${last_update_file}
cat ${out_pmid2sra} >> ${last_update_file}

echo ${last_update_file} >> ${errlog}
echo "today update done." >> ${errlog}

## 8. move make files to today's dir
if [ ! -d update/${today} ] # if today's dir is not exist, then make new dir
then
	mkdir update/${today}
fi
mv ${today}.* update/${today}

