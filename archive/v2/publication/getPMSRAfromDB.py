#!/usr/bin/env /usr/bin/python
# -*- coding: utf-8 -*-

import sys
import os
import os.path
import re

# 渡されたファイルを全て読んで、PMIDとSRAIDらしきペアを出力する
# 引数
# 1. ファイルのパスのリスト
# 2. PMIDとSRAIDのリスト
# auther: meguu 2011/6/24

PM_MATCH = re.compile("\d{5,}") # pubmed のIDを抽出するときの探索条件(数字がならんでいる)
PMKEY_MATCH = "pubmed"
PMKEY_MATCH_ENTREZLINK = "<ENTREZ_LINK>"
PMKEY_MATCH_CLOSE_ENTREZLINK = "</ENTREZ_LINK>"
PMKEY_MATCH_XREFLINK = "<XREF_LINK>"
PMKEY_MATCH_CLOSE_XREFLINK = "</XREF_LINK>"
PMKEY_MATCH_PROBESET = "<PROBE_SET>"
PMKEY_MATCH_CLOSE_PROBESET = "</PROBE_SET>"

PMKEY_MATCH_DBTAG = "<DB>pubmed</DB>"
PMKEY_MATCH_ID = "<ID>"

PMKEY2_EXPERIMENTLINK = "<URL_LINK>"
PMKEY2_EXPERIMENTLINK_TOJI = "</URL_LINK>"

# 現在探せるpmid
# (1)
# <ENTREZ_LINK>
#    <DB>pubmed</DB>
#    <ID>21317186</ID>
# </ENTREZ_LINK>
## /opt/data/sra2/Submissions/SRA036/SRA036885/SRA036885.sample.xml
#
# (2)
# <EXPERIMENT_LINK>
#        <URL_LINK>
#          <LABEL>Lee et al. 2006</LABEL>
#          <URL>http://www.ncbi.nlm.nih.gov/pubmed/17406303</URL>
#        </URL_LINK>
#      </EXPERIMENT_LINK>
## /opt/data/sra2/Submissions/SRA024/SRA024982/SRA024982.experiment.xml
#
# (3)
# <XREF_LINK>
#        <DB>pubmed</DB>
#        <ID>19181841</ID>
# </XREF_LINK>
# /opt/data/sra2/Submissions/SRA027/SRA027320/SRA027320.experiment.xml
# /opt/data/sra2/Submissions/SRA027/SRA027320/SRA027320.run.xml
# /opt/data/sra2/Submissions/SRA027/SRA027320/SRA027320.sample.xml
##
# (4)
# <PROBE_SET>
#        <DB>pubmed</DB>
#        <ID>17916733 </ID>
# </PROBE_SET>

# filelstfileを開いて、ファイルの中身をリストにして返す
def openfilelst(filelstfile):
    filelst=[]
    fo = open(filelstfile,"r")
    for line in fo:
        filelst.append(line[:-1])
    return filelst

# fileを開いて、pmidを探す
def readFile(file, errorfilename):
    p = []
    f = open(file, 'r')
    if(os.path.isfile(file)==False):
        fe = open(errorfilename,"a")
        fe.write("error: file is not found. :"+file+"\n")
        fe.close()
        return p
    xx = file.split("/") # sra_idを得る
    sraid = xx[len(xx)-1].split(".")[0] # sra_idを得る

    
    entrezlink_FLAG=False # ENTREZ_LINK　タグの中に入っていらTrue,入っていなかったらFalse
    db_pubmed_FLAG = False # ENTREZ_LINK　タグで,DBがpubmedならTrue, それ以外ならFalse
    linen = f.readline()
    #exp_FLAG=False # EXPERIMENT_LINK タグの中に入っていたらTrue,入っていなかったらFalse
    while linen:
#    for linen in f:
        line = linen[:-1].strip()
        # lineの中に"pubmed"があったら, urlとする
        if line.find(PMKEY_MATCH) >= 0: #PMKEY_MATCH = "pubmed"
                pmidlst = PM_MATCH.findall(line)
                for pmid in pmidlst:
                    p.append((pmid,sraid))
        # <ENTREZ_LINK>が来たら,</ENTREZ_LINK>の行が現れるまで<DB>と<pubmed>を取得する
        if line.find(PMKEY_MATCH_ENTREZLINK) >= 0 or line.find(PMKEY_MATCH_XREFLINK) >= 0 or line.find(PMKEY_MATCH_PROBESET) >= 0: #PMKEY_MATCH_ENTREZLINK = "<ENTREZ_LINK>"
            while linen:
	            # <DB>pubmed<DB>だったら,entrezlink_FLAGタグをTrueにする
                if line.find(PMKEY_MATCH_DBTAG) >= 0: # PMKEY_MATCH_DBTAG = <DB>pubmed<DB>
                    db_pubmed_FLAG = True
			    # <ID>xxxx</ID>なら, pubmedのIDの可能性があるもの
                if db_pubmed_FLAG == True:
                    pmidlst = PM_MATCH.findall(line)
                    for pmid in pmidlst:
                        p.append((pmid,sraid))
                # </ENTREZ_LINK>が来たらIDサーチをストップ
                if line.find(PMKEY_MATCH_CLOSE_ENTREZLINK) >= 0 or line.find(PMKEY_MATCH_CLOSE_XREFLINK) >= 0 or line.find(PMKEY_MATCH_CLOSE_PROBESET) >= 0:
                    db_pubmed_FLAG = False
                    break
                linen = f.readline()
                line = linen[:-1].strip()
        linen = f.readline()
    if db_pubmed_FLAG == True:
        fe = open(errorfilename,"a")
        fe.write("error: This file doesn't close tags. :"+file+"\n")
        fe.close()
        return []
    if p == []:
        fe = open(errorfilename,"a")
        fe.write("error: This file doesn't have any pmids. :"+file+"\n")
        fe.close()
    return p

# SRAとpmidのリストを重複無く出力する
def output(allPMSRAid,filename):
    all = set(allPMSRAid)
    fo = open(filename,"w")
    for p in all:
        fo.write(p[0]+"\t"+p[1]+"\n")
    fo.close()

# 引数1:ファイルパスの入っているファイル名
# 引数2:出力ファイル名
def main(filelstfile, outputfilename, errorfilename):
    #filelstfile = sys.argv[1]
    #outputfilename = sys.argv[2]
    #errorfilename = sys.argv[3]
    if os.path.exists(filelstfile)==False:
        sys.stderr.write("error: not found:"+file)
        sys.exit()
    allPMSRAid = [] # 重複していてもいいので、このリストに見つけたpmid,sraペアを保存
    filelst = openfilelst(filelstfile) #読むべき全てのファイル＝filelst
    for file in filelst:
        p = readFile(file,errorfilename)
        setp = set(p)
        for i in setp:
            allPMSRAid.append(i)
    output(allPMSRAid,outputfilename)

if __name__ == "__main__":
    args = sys.argv
    if len(args)!=4:
        sys.stderr.write("error: input [pmidlstfile] [outputfilename] [errlogfilename].")
    else:
        main(sys.argv[1], sys.argv[2], sys.argv[3])

