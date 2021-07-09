   #!/usr/local/bin/python
# -*- coding: utf-8 -*-

# ESearchを使って、TERMのクエリを投げて、すべてのUIDリストを出力する
# 入力は、出力のファイル名
# エラーは標準出力

# 2011/12/7 meguu
# update 2012/2/2 meguu reldate=を追加

import sys, urllib, re
import datetime

# query
EsearchURL="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=gds&term="
TERM="(expression+profiling+by+high+throughput+sequencing[DataSet+Type]+OR+genome+binding/occupancy+profiling+by+high+throughput+sequencing[DataSet+Type]+OR+genome+variation+profiling+by+high+throughput+sequencing[DataSet+Type]+OR+methylation+profiling+by+high+throughput+sequencing[DataSet+Type]+OR+non+coding+rna+profiling+by+high+throughput+sequencing[DataSet+Type])"
EURL = EsearchURL+TERM

# 月か日かで，一桁の時，前に0をつけた文字列を返す　2月->02
def getDateStr(md):
    if len(str(md)) == 1:
        return "0"+str(md)
    elif len(str(md)) == 2:
        return str(md)
    else:
        sys.stderr.write("getESearch.py: getDateStr: this date is wrong.> %s.\n"%(str(md)))
        sys.exit()
    
# ESearchを使って，reldate(ex:14)日前から今日までの増分を取る
def getData(reldate):
    uidlist = []
    retstart=0
    retmax = 30
    flg=True
    try:
        maxdate = datetime.date.today() # 今日の日付を取得
        mindate = maxdate - datetime.timedelta(reldate) # (reldate)日前の日付を取得．reldateはint
        todayYMD = str(maxdate.year)+"/"+getDateStr(maxdate.month)+"/"+getDateStr(maxdate.day) # 2012/02/02 
        minYMD = str(mindate.year)+"/"+getDateStr(mindate.month)+"/"+getDateStr(mindate.day)
        dEURL = EURL+"+AND+"+minYMD+":"+todayYMD+"[PDAT]" #urlに，探索する日付情報を付与
        url = dEURL + "&retstart="+str(retstart)+"&retmax="+str(retmax)+"&usehistory=y"
        print url
        uo = urllib.urlopen(url)
        line = uo.readline()
        while line:
            l = line[:-1].lstrip() #タブや空白を消す
            if l.startswith("<Id>"):
                id = l.replace("<Id>","").replace("</Id>","")
                #print id ###debug
                flg=False
                uidlist.append(id)
            line = uo.readline()
            if line == "":
                if flg == False:
                    retstart = retstart + retmax
                    flg = True
                    url = dEURL+"&retstart="+str(retstart)+"&retmax="+str(retmax)+"&usehistory=y"
                    uo = urllib.urlopen(url)
                    line = uo.readline()
        uo.close()
        return uidlist
    except:
        sys.stderr.write("getEsearch.py> error..getData()\n")

# uidlistを受け取ったら、outputfileに出力する
def uidoutput(uidlist, outputfile):
    try:
        sys.stdout.write("geoEsearch.py> Uid %d count.\n"%(len(uidlist))) ###debug
        fo = open(outputfile, "w")
        for uid in uidlist:
            fo.write(uid+"\n")
        fo.close()
    except:
        sys.stderr.write("getEsearch.py> error..uidoutput()\n")

def main(outputfile, reldate):
    # すべての件数分uidを得る
    uidlist = getData(reldate)
    # ファイル出力
    if uidlist != []:
        uidoutput(uidlist, outputfile)
    else:
        sys.stdout.write("geoEsearch.py> UID is None.\n")
        
if __name__ == '__main__':
    args = sys.argv
    if len(args) != 3:
        sys.stderr.write("please input [outputfile name] [reldate(int)].\n")
    else:
        if args[2].isdigit():
            main(args[1], int(args[2]))
        else:
            sys.stderr.write("please input [outputfile name] [reldate(int)].\n")
