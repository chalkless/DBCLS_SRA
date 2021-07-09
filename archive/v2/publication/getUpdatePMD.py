#!/usr/bin/env /usr/bin/python
# -*- coding: utf-8 -*-

import MySQLdb
import sys
import pmid2sra
import os
import urllib

##　ここまで手に入ったpmidは適当な数字なのかpmidなのかが分かっていないので調べたい
## 3. pmidがmysqlの中にあるかを調べる
##      ->あれば何もしないでファイルに出力する
##      ->なければ、pubmedに取りに行く．
##          ->あれば文献情報も取る.
#####変更    ->なければerrorlogに出力
##          ->なければ、文献情報をOUT_NULLにして、(pmid,sra_id)を出力
##    出力はpmid,文献情報,sraidとする.
##  最後の引数Tは、./xml_files/へ本文ファイルを残さないフラグ、Fにすると本文ファイルが残る．

# 入力：pmid候補とxRxIDのペアリスト, TorF
# 出力：上記の処理をしたpmid,文献情報,sraidのリスト
#    pmidxrxListfile = sys.argv[1] # pmid候補とxRxIDのペアリストファイル
#    out_pmid2xrx = sys,argv[2] # 上記の処理をしたpmid,文献情報,xrxidのリスト
#    out_error = sys.argv[3] # エラー出力用ファイル名  

# [0]PMID \t [1]PMC \t [2]Article Title \t [3]Journal \t [4]Vol \t [5]Issue \t [6]Page \t [7]fpage \t [8]date \t [9]Doi \t [10]Flag \t [11]SRA ID \t [12]SRA Around
            
OUT_NULL = "-"
outputpmidxrxList = [] # mysqlの中にpmidが存在しなかったもの（pmidは少なくとも存在すると分かっている）
errorpmidxrxList = [] # pmidがPubMedにも存在しなかったpmid,sraリスト（エラー出力用）

E_URL = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?retmode=xml" # e-fetch からxmlを取得するアドレス

dbname="sra"
hostname="127.0.0.1"
portid=3306
username="sra"
pas="shortread"
#### connect で使う MySQLdb.connect(db="sra", host="127.0.0.1", port=3306, user="sra", passwd="shortread")

pmid2sra_table="pmid2sra2"
article_table="article"

# mysqlの中にpmidとsraのペアが存在するかを調べる
# ペアが存在すればリストから外す，無ければリストに残す
def mysqlDontHaveThem(pmidxrxList):
    pmidxrxNOTmysql = []
    try:
        connect = MySQLdb.connect(db=dbname, host=hostname, port=portid, user=username, passwd=pas)
        cur = connect.cursor()
        for pmidxrx in pmidxrxList:
            flg = True
            pmid = pmidxrx[0]
            sra = pmidxrx[1]
            # (pmid, sra_id_orig)が存在するようなものは更新しない
            que = "SELECT sra_id_orig FROM "+pmid2sra_table+" WHERE pmid=\"" + pmid + "\""
            cur.execute(que)
            rows = cur.fetchall()
            if(len(rows)==0):# pmidがpmid2sraテーブルに含まれていない
                pmidxrxNOTmysql.append(pmidxrx) # リストに残す
                continue
            # 以降、pmidが少なくともmysqlに存在すると分かっているものは、
            for row in rows:
                if(row[0]==sra):# pmidもsraもpmid2sraにあれば
                    flg = False
                    break # 何もしない（リストから外す）
            if flg == True: # flg==Falseのときは、pmidとsraが既にpmid2sra2に入っている
                # articleにpmidの情報が入っているかを一応調べておく
                cur.execute("SELECT * FROM "+article_table+" WHERE pmid=\"" + pmid + "\"")
                rows = cur.fetchall()
                #print rows
                if(len(rows)==0):# pmidがpmid2sraテーブルに含まれていない
                    pmidxrxNOTmysql.append(pmidxrx) # リストに残す
                    continue
                # articleは,もう入っているはずなのでOUT_NULLで代用して保存
                # [0]PMID \t [1]PMC \t [2]Article Title \t [3]Journal \t [4]Vol \t [5]Issue \t [6]Page \t [7]fpage \t [8]date \t [9]Doi \t [10]Flag \t [11]SRA ID \t [12]SRA Around
                article = []
                article.append(pmid) #[0]
                article.append(OUT_NULL) #[1]PMC
                article.append(OUT_NULL) #[2]Title
                article.append(OUT_NULL) #[3]Journal
                article.append(OUT_NULL) #[4]Vol
                article.append(OUT_NULL) #[5]Issue
                article.append(OUT_NULL) #[6]Page
                article.append(OUT_NULL) #[7]fpage
                article.append(OUT_NULL) #[8]date
                article.append(OUT_NULL) #[9]Doi
                article.append(OUT_NULL) #[10]Flag
                article.append(sra) #[11]SRA
                article.append(OUT_NULL) #[12]SRA Around
                outputpmidxrxList.append(article) #pmidが存在してRSAとのペアがないので、後で出力する    
    finally:
        cur.close()
        connect.close()
    return pmidxrxNOTmysql


# pmidがPUBMEDにあるかを調べたい.無ければ、ERRORが帰ってくるので、false,そうでなければTrue
# E_URL = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?retmode=xml" # e-fetch からxmlを取得するアドレス
def fileExist(pmid,filename):
    flag = True
    url = E_URL + "&db=pubmed&id=" + pmid
    urllib.urlretrieve(url, filename)
    for line in open(filename,"r"):
        # ファイルの中に以下の文言があれば、idは存在しない．(!=-1)=flagはFalseのまま
        if(line.find("<ERROR>Empty id list - nothing todo</ERROR>")!=-1):
            return False
    return flag

##パス先のファイル名が存在すれば、削除する
def removeFile(filename):
    if(os.path.isfile(filename)==True):
        os.remove(filename)
        
# pubmedにpmidがあるので文献情報を取る.
## 文献情報を得る..得られたら、outputpmidxrxList
##   得られなければerrorpmidxrxListへ保存　
def searchPMID(pmidxrx,filename,deleteFile):
    pmid = pmidxrx[0]
    sra = pmidxrx[1]
    paper = pmid2sra.Paper(pmid)       
    #downloadXML(pmid, "pubmed", filename) # 既にダウンロードはしてある
    paper = pmid2sra.getID4PM(filename, paper)
    # PMCが有れば, xmlファイルを取得して解析する
    if not paper.pmc_id == OUT_NULL and paper.pmc_use == "false":
        filename = "xml_files/pmc" + paper.pmc_id + ".xml"
        pmid2sra.downloadXML(paper.pmc_id, "pmc", filename)
        pmid2sra.getID4PMC(filename, paper)
        if(deleteFile!='F'):
            removeFile(filename)
    #ここまででpmの文献情報が得られているはず
    #paperの中身を、pmidneedarticleに入力
    # 0.PMID \t 1.PMC \t 2,Article Title \t 3.Journal \t 4.Vol \t 5.Issue \t 6.Page \t 7.fpage \t 8.Date \t 9.Doi \t 10.Flag \t 11.SRA ID \t 12.SRA Around
        article = []
        article.append(paper.pmid)
        article.append(paper.pmc_id)
        article.append(paper.title)
        article.append(paper.journal["journal"])
        article.append(paper.journal["volume"])
        article.append(paper.journal["issue"])
        article.append(paper.journal["page"])
        article.append(paper.journal["fpage"])
        
        # 日付の出力
        date_out = paper.journal["date"]["year"]
        if not paper.journal["date"]["month"] == OUT_NULL:
            date_out = date_out + "-" + paper.journal["date"]["month"]
            if not paper.journal["date"]["day"] == OUT_NULL:
                date_out = date_out + "-" + paper.journal["date"]["day"]
        article.append(date_out)
        article.append(paper.doi)
        article.append(paper.pmc_use) #Flag
        article.append(sra)
        article.append(OUT_NULL)#SRA Around
        outputpmidxrxList.append(article)
    else:
        # これをすることで、文献情報のない、データが入ることになるかも。-> ならないようにした
        errorpmidxrxList.append([pmidxrx[0],pmidxrx[1],": error: cannot find PMC."])
        # 日付の出力
        date_out = paper.journal["date"]["year"]
        if not paper.journal["date"]["month"] == OUT_NULL:
            date_out = date_out + "-" + paper.journal["date"]["month"]
            if not paper.journal["date"]["day"] == OUT_NULL:
                date_out = date_out + "-" + paper.journal["date"]["day"]
        article = [pmid, paper.pmc_id,
                   paper.title,
                   paper.journal["journal"],
                   paper.journal["volume"],
                   paper.journal["issue"],
                   paper.journal["page"],
                   paper.journal["fpage"],
                   date_out,
                   paper.doi,
                   paper.pmc_use,
                   sra, OUT_NULL]
        outputpmidxrxList.append(article)

         
def openfile(pmidxrxListfile):
    f = open(pmidxrxListfile,'r')
    line = f.readline()
    pmidxrx = []
    while line:
        cols = line[:-1].split("\t")
        pmidxrx.append((cols[0],cols[1]))
        line = f.readline()
    f.close()
    return pmidxrx

def output(out_pmid2xrx_filename):
    f = open(out_pmid2xrx_filename,"w")
    for pmidxrxart in outputpmidxrxList:
        line = '\t'.join(pmidxrxart)
        f.write(line+"\n")
    f.close()
    
def output_error(out_error_filename):
    f = open(out_error_filename,"a")
    for pmidxrxerr in errorpmidxrxList:
        line = '\t'.join(pmidxrxerr)
        f.write(line+"\n")
    f.close()
                                
## 3. pmidがmysqlの中にあるかを調べる．
##      ->あれば何もしないでファイルに出力する
##      ->なければ、pubmedに取りに行く．
##          ->あれば文献情報も取る.
##          ->なければerrorlogに出力
##    出力はpmid,文献情報,sraidとする.
##  最後の引数Tは、./xml_files/へ本文ファイルを残さないフラグ、Fにすると本文ファイルが残る
def main():
    args = sys.argv
    if len(args) != 5:
        sys.stdout.write("input: [pmidxrxListfile] [out_pmid2xrx_filename] [deleteFile(T/F)] [out_error_filename].\n")
        sys.exit()    
    pmidxrxListfile = sys.argv[1] # pmid候補とxRxIDのペアリストファイル
    out_pmid2xrx_filename = sys.argv[2] # 出力用ファイル名：上記の処理をしたpmid,文献情報,xrxidのリスト
    deleteFile = sys.argv[3] # TorF というか　Fじゃなかったらファイルは消される。
    out_error_filename = sys.argv[4] # エラー出力用ファイル名  
    
    # pmidsraListfileが存在しなければ何もしない．
    if(os.path.isfile(pmidxrxListfile)==False):
        sys.stdout.write("not found:"+pmidxrxListfile+"\n")
        return
    
    # ファイルを開いて、pmidstaListに全部の(pmid,sra)候補を入れる
    pmidxrxlst = openfile(pmidxrxListfile)
    
    # pmidがmysqlの中にあるかを調べる．
    # ->out_pmidsraListに入れてpmidxrxlstから消す
    # 返ってくるのは、pmidがmysqlの中に無いpmidxrx
    pmidxrxlstnotDB = mysqlDontHaveThem(pmidxrxlst)
    
    # pubmedにpmidがあるかを見に行く．
    #   ->あれば文献情報も取る.
    #   ->なければerrorlogに出力
    #    出力はpmid,文献情報,sraidとする.
    for pmidxrx in pmidxrxlstnotDB:
        pmid = pmidxrx[0]
        filename = "xml_files/pubmed" + pmid + ".xml"
        if fileExist(pmid,filename) == True:
            # 文献情報を得る..得られたら、outputpmidxrxList
            #   得られなければerrorpmidxrxListへ保存　
            searchPMID(pmidxrx,filename,deleteFile)
            if(deleteFile!='F'):
                removeFile(filename)
        else:
            errorpmidxrxList.append([pmidxrx[0],pmidxrx[1],": error: cannot find pmid in PubMed."])

    output(out_pmid2xrx_filename)
    output_error(out_error_filename)
    
if __name__ == "__main__":
    main()

