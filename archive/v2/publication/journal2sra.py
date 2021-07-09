#!/usr/bin/env /usr/bin/python
# -*- coding: utf-8 -*-
###
# NOT_USED = "The publisher of this article does not allow downloading of the full text in XML form."
# PMCはあっても,使えない場合,ジャーナルを調べて、本文を得る．
# author: meguu
# editor: i_87, 11/4/27
# update: meguu 11/7/13
# editor: i_87, 11/10.19, SRA ID の前後10文字で, 最後が改行の場合に空行が挿入されてしまうエラーを処理
#   (l = l[:-1] # 改行を除く を追記)
# editor: i_87, 11/11.9, journalstの Genome Research を Genome research に変更

import sys
import urllib
import re
import string

# 入力ファイルの書式は以下のような状態を意識している．
# PMID \t PMC \t Article Title \t Journal \t Vol \t Issue \t Page \t fpage \t Doi \t PMC \t Flag \t SRA ID \t SRA Around
# 項目名がflagの列．true以外はjournalを探す．
# 列番号は0から始めて数えてください。　

FLAG_C = 10
Journal_C = 3
Vol_C = 4
Issue_C = 5
Fpage_C = 7
Doi_C = 9
SRA_ID_C = 11
SRA_AROUND_C = 12

SRA_P = re.compile("[SED]R[APXSR][0-9]+") # SRAのIDを抽出する部分

# キー：<journal-title>
# オブジェクト：それに対応する、volumeやfpageなど必要なものと、疑似URLをタプルにしたもの.
# タプルのlen-1で、urlに必要なものがわかる．エラー防止のため、[必要なもの名]という形で疑似urlに埋めた．
# volume,issue,fpage,doi_after_slash
journalst = {
    "Genome research" : ("volume","issue","fpage","http://genome.cshlp.org/content/[volume]/[issue]/[fpage].full") ,
    "Proceedings of the National Academy of Sciences of the United States of America" : ("volume","issue","fpage","http://www.pnas.org/content/[volume]/[issue]/[fpage].full"),
    "Nature" : ("volume","issue","doi_after_slash","http://www.nature.com/nature/journal/v[volume]/n[issue]/full/[doi_after_slash].html"),
    "Science (New York, N.Y.)" : ("volume","issue","fpage","http://www.sciencemag.org/content/[volume]/[issue]/[fpage].full"),
    "Genes &#x00026; Development" : ("volume","issue","fpage","http://genesdev.cshlp.org/content/[volume]/[issue]/[fpage].full"),
    "Nature methods" : ("volume","issue","doi_after_slash","http://www.nature.com/nmeth/journal/v[volume]/n[issue]/full/[doi_after_slash].html"),
    "Nature genetics" : ("volume","issue","doi_after_slash","http://www.nature.com/ng/journal/v[volume]/n[issue]/full/[doi_after_slash].html"),
    "Nature biotechnology" : ("volume","issue","doi_after_slash","http://www.nature.com/nbt/journal/v[volume]/n[issue]/full/[doi_after_slash].html"),
    "Bioinformatics" : ("volume","issue","fpage","http://bioinformatics.oxfordjournals.org/content/[volume]/[issue]/[fpage].full"),
    "The Plant Cell" : ("volume","issue","fpage","http://www.plantcell.org/content/[volume]/[issue]/[fpage].full"),
    "Briefings in Functional Genomics and Proteomics" : ("volume","issue","fpage","http://bfg.oxfordjournals.org/content/[volume]/[issue]/[fpage].full"),
	"Plant physiology" : ("volume", "issue", "fpage", "http://www.plantphysiol.org/content/[volume]/[issue]/[fpage].full")
    }

# urlを開いて、dを更新してoutputする．
def read_journal(d,url,fo,foe):
    #print url
    try:
        page = urllib.urlopen(url)
        pagedata = page.readlines()
        flag = False
        for l in pagedata:
            l = l[:-1] # 改行を除く
            x = SRA_P.findall(l)
            search_index = 0 # l からsraidを探す時の検索範囲
            search_l = l # l の serch_index以降の文字列
            for sraid in x:
                flag=True
                d[SRA_ID_C]=sraid;
                s = search_l.find(sraid) + search_index
                if s != -1 and s < len(l):
                    d[SRA_AROUND_C] = l[(s-15):(s+len(sraid)+15)]
                    search_index = s+len(sraid)
                    search_l = l[search_index:]
                    output(d,fo)
        # ジャーナルの中にもsraらしき番号がなかったら、
        if flag==False:
            d.append(": To read journal article is done, but not found sra IDs.")
            output_notfound(d,foe)
        page.close()
        return
    except IOError:
        d.append(": To get journal article url is done, but maybe not found URL. url="+url)
        output_notfound(d,foe)
        return 

# タブ区切りの一行をsplitして、リスト (=d) にしている．
# d: 0番地から順番に, 入力ファイルをタブ区切りにしたものを保持するリスト
# fo: 更新結果を出力するファイルストリーム
# foe: エラーを出力するファイルストリーム
def get_journal(d,fo,foe):
    # ジャーナル名がなければ、そのまま返す
    if d[Journal_C]=="-":
        d.append(": Not found journal name in input data.")
        output_notfound(d,foe)
        return
    # ジャーナル名が、辞書の中になければ、そのまま返す．
    if journalst.has_key(d[Journal_C]) == False:
        d.append(": Not found journal name in program.")
        output_notfound(d,foe)
        return
    # あればurlに必要なものがl[0:l.len()-1]にはいっているので調べて補完する．
    l = journalst[d[Journal_C]]
    url = l[len(l)-1]
    i=0
    # l.len()-2までが必要なもの．
    while i < len(l)-1:
        if l[i] == "volume":
            if d[Vol_C] != "-":
                url = url.replace("[volume]",d[Vol_C])
            else:
                d.append(": Not found volume in input data.")
                output_notfound(d,foe)
                return
        elif l[i] == "issue":
            if d[Issue_C] != "-":
                url = url.replace("[issue]",d[Issue_C])
            else:
                d.append(": Not found issue in input data.")
                output_notfound(d,foe)
                return
        elif l[i] == "fpage":
            if d[Fpage_C] != "-":
                url = url.replace("[fpage]",d[Fpage_C])
            else:
                d.append(": Not found fpage in input data.")
                output_notfound(d,foe)
                return
        elif l[i] == "doi_after_slash":
            if d[Doi_C] != "-":
                url = url.replace("[doi_after_slash]",d[Doi_C].split("/")[1])
            else:
                d.append(": Not found doi_after_slash in input data.")
                output_notfound(d,foe)
                return
        else:
            d.append("error: not_found this key:"+l[i])
            output_notfound(d,foe)
            return
        #print l[i]
        #print url
        i=i+1
    #print url
    # ここまででその論文のurlが出来ているので．
    read_journal(d,url,fo,foe)

def output(line,fo):
    #print string.join(line,"\t")
    fo.write("\t".join(line)+"\n")

def output_notfound(line,foe):
    #print "notfound"
    #print string.join(line,"\t")
    foe.write("\t".join(line)+"\n")

##
# pmidlstfile: pmid2sraで作成したファイル
# outputfile: 結果を出力するファイル
##
def main(pmidlstfile,outputfile,output_errorfile):
    f=open(pmidlstfile,"r")
    fo=open(outputfile,"w")
    #output_errorfile=outputfile+".error"
    foe=open(output_errorfile,"a")
    #output_notsrafile=outputfile+".notsra" # journalは見たけれども,SRAが見つからなかったものたち
    #fon = open(output_notsrafile, "w")
    l=0
    flag_c=0
    try:
        for line in f:
            d = line[:-1].split("\t")
            if (l==0):
                # 一行目は、項目名なので、そのまま出力
                output(d,fo)
                l=l+1
            else:
                # FLAG_C列の文字列がtrueだったらそのまま出力．
                if(d[FLAG_C]=="true"):
                    output(d,fo)
                else:
                    get_journal(d,fo,foe)
    finally:
        f.close()
        fo.close()
        foe.close()

if __name__ == '__main__':
    main(sys.argv[1],sys.argv[2],sys.argv[3])
