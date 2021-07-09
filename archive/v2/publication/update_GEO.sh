#!/bin/sh

# GEOに、SRP IDが登録されているものを

## a.このプログラムと同じディレクトリ内に xml_files という名前のディレクトリが必要です．
## b.このプログラムを使うには、pythonのMySQLdbモジュールをインストールすることが必要です（casperにはしてあります）

##------ parametor
## 今日の日付
today=`date '+%y%m%d'`
## dirname
dbname='GEO'
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

## 1.ESearchでUIDを取得
output1=${today}'.'${dbname}'.UIDlst' 
echo "1. :"${dbname}"-> all uid list" >> ${errlog} 
echo "- "${output1} >> ${errlog} 
python geoESearch.py ${output1} 14 >> ${errlog} 2>&1 # 14日前から今日までのデータを取得
if [ ! -e ${output1} ]; then
	echo "- uid is nothing. done." >> ${errlog} 
	exit 0
fi
	
## 2.EFetchで、UIDを使って、GSE IDをとる
output2=${output1}'.UID2GSE'
echo "2. : uid list -> GSE id list" >> ${errlog}
echo "- "${output2} >> ${errlog}
python geoEFetch.py ${output1} ${output2} >> ${errlog} 2>&1

## 3.ftpのURLをGSE IDから作り、SOFT形式でデータを落とす,
##   中身を読む、データ取得（PMID, GEO, SRA）、落としたGEOのSOFTデータを消す
##   PMIDがSOFT形式のファイルに無い場合 -> marsのSRAのDBを落としてきているところを探しに
##   出力1: (PMIDとGSEと取得したSRA) -> 一番最後にorigに追加するためのもの．ただし，SRAはあるけどPMIDが無いものは，PMIDが-．
##   出力2: (PMIDと取得したSRA) -> getUpdatePMD.pyに渡す．以下は，DDBJからデータを取るときと一緒． 
output3_1=${output2}'.GEO2PMID_PmidSraGeo'
output3_2=${output2}'.GEO2PMID_SraGeo'
echo "3. : GSE id list -> (PMID, SRA, GEO), (SRA, GEO)" >> ${errlog}
echo "- (PMID, SRA, GEO) "${output3_1} >> ${errlog}
echo "- (SRA, GEO) "${output3_2} >> ${errlog}
python getGEO2PMID.py ${output2} ${output3_1} ${output3_2} >> ${errlog} 2>&1

## 以降、output3_1は、1,2列目を、getUpdatePMD.pyに渡す
output3_1_1=${output2}'.GEO2PMID_PmidSra'
echo "3.5 : (PMID, SRA, GEO) -> (PMID, SRA)" >> ${errlog}
echo "- (PMID, SRA) "${output3_1_1} >> ${errlog}
if [ ! -e ${output3_1} ]; then
	echo "- geo id is nothing. done." >> ${errlog}
	exit 0
fi
cut -f1,2 ${output3_1} > ${output3_1_1}

##　output3_1_1で手に入ったpmidは適当な数字なのかpmidなのかが分かっていないので調べたい
## 4. pmidがmysqlの中にあるかを調べる．
##      ->あれば何もしないでファイルに出力する
##      ->なければ、pubmedに取りに行く．
##          ->あれば文献情報も取る.
##          ->なければerrorlogに出力
##    出力はpmid,文献情報,sraidとする.
##  最後の引数Tは、./xml_files/へ本文ファイルを残さないフラグ、Fにすると本文ファイルが残る．
output4=${output3_1_1}'.pmid2sra'
echo "4. : (PMID,xRxID) pair list -> all pmid2xRx and article data " >> ${errlog}
echo "- "${output4} >> ${errlog}
python getUpdatePMD.py ${output3_1_1} ${output4} T ${errlog} >> ${errlog} 2>&1

## 5.SRAIDをxRx-> SRAに寄せる．
## SRAのIDがSRXなどになっているものを，SRAに名寄せする．mySQLを使用する. 重複なしで出力する
output5=${output4}'.xrx2xra'
echo "5. : (PMID,xRxID) pair list -> (PMID,xRAID) pair list" >> ${errlog}
echo "- "${output5} >> ${errlog}
python xrx2xra_formysql.py ${output4} ${output5} ${errlog} >> ${errlog} 2>&1

## 6. output3_1を使って、out_pmid2sraのsra_id_origとマージする(置き換える)
out_pmid2sra_geoorig=${output5}'.geoorig'
echo "6. " >> ${errlog} 
echo "- "${out_pmid2sra_geoorig} >> ${errlog}
python merge_orig.py ${output5} ${output3_1} ${out_pmid2sra_geoorig} >> ${errlog} 2>&1

## 7.これまでのpmidとsraのペアになかったものを出力する．mySQLを使用する．
add_file=${out_pmid2sra_geoorig}
out_pmid2sra=${out_pmid2sra_geoorig}'.diff_pmid2sra'
out_article=${out_pmid2sra_geoorig}'.diff_pmid2sra_article'
echo "7. diff pmid2sra :" >> ${errlog}
echo "- "${out_pmid2sra} >> ${errlog}
echo "- "${out_article} >> ${errlog}
python diff_pmid2sra.py ${add_file} ${out_pmid2sra} ${out_article} >> ${errlog} 2>&1

## 8. output5のpmidとsraIDのペアと${out_article}のpmidの記事情報をMySQLにアップロードする
dir=`pwd`'/'
echo "8.update to MySQL :" >> ${errlog}
echo "- loadfile: "${out_pmid2sra} >> ${errlog}
echo "-         : "${out_article} >> ${errlog}
python load_file.py ${dir}${out_pmid2sra}  ${dir}${out_article} >> ${errlog} 2>&1

## 9. make file: last-update.txt
## this file is used to show last update day and add IDs in homepage
echo `date '+%Y'/%m/%d` >> ${last_update_file}
echo 'from GEO' >> ${last_update_file}
cat ${out_pmid2sra} >> ${last_update_file}

echo ${last_update_file} >> ${errlog}
echo "today update done." >> ${errlog}

## 10. move make files to today's dir
if [ ! -d update/${today} ] # if today's dir is not exist, then make new dir
then
	mkdir update/${today}
fi
mv ${today}.* update/${today}

