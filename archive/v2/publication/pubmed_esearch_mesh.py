#!/usr/bin/env /usr/bin/python
# -*- coding: utf-8 -*-

import urllib
import sys
from xml.dom.minidom import parse
from xml.dom.minidom import parseString
from xml.dom import minidom, Node

# ----
# meshtermを渡すと、
# esearchでそのメッシュが登録されている論文が何件あるかを探し、
# Idが返ってくるので、
# その論文のIdを引いて、pubmed idのリストを得る．
# ----

# 引き数の名前のノードをリストに入れて返す
#def parse_xml(tagName,pagedata):
#    lst = []
#    obj = parseString(pagedata)
#    #element_array = obj.getElementsByTagName(tagName)
#    #print element_array
#    for node in obj.getElementsByTagName(tagName):
#        for child in node.childNodes:
#            lst.append(child.wholeText)
#    obj.unlink()
#    return lst

def idNum(meshterm):
    url_forcount="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term="+meshterm+"[mesh]&retmode=xml&rettype=count"
    #print url_forcount
    page = urllib.urlopen(url_forcount)
    pagedata = page.readlines()
    count=0
    for l in pagedata:
        k=l.split("<Count>")
        if len(k) != 1:
            count = k[1].split("</Count>")[0]
            break
    return int(count)

def idLst(meshterm,idnum):
    idlst=[]
    s=0
    e=10
    if idnum%10 == 0:
        c=idnum/10
    else:
        c=int(idnum/10)+1
    for i in range(c):
        url_foridlst="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term="+meshterm+"[mesh]&retmode=xml&rettype=uilist&retstart="+str(s)+"&retmax="+str(e)
        #print url_foridlst
        s=s+e
        page = urllib.urlopen(url_foridlst)
        pagedata = page.readlines()
        for l in pagedata:
            k=l.split("<Id>")
            if len(k)!=1:
                idlst.append(k[1].split("</Id>")[0])
    page.close()
    return idlst
 
def esearch_mesh(meshterm,filename):
    #調べたいメッシュ
    #meshterm="High-Throughput%20Nucleotide%20Sequencing"
    #pmidを出力するファイル名
    #filename="MeSH_High-Throughput%20Nucleotide%20Sequencing.pmidlst.20110331.txt"
    
    # meshを使って、取れるIdの数を知る．
    idnum = idNum(meshterm)
    #print str(idnum)
    # 知ったIdの数を参考に、全てのIdを得る．
    idlst = idLst(meshterm,idnum)
    #print idlst
    #print len(idlst)
    fw = open(filename,"w")
    for id in range(len(idlst)):
        fw.write(str(idlst[id]+"\n"))
    fw.close()
    
def main():
    meshterm = sys.argv[1]
    filename = sys.argv[2]
    esearch_mesh(meshterm,filename)

if __name__ == "__main__":
    main()
