#!/usr/bin/python
# -*- coding: utf-8 -*-
import MySQLdb
import sys

# このプログラムを使うには、MySQLdbをインストールすることが必要です
# 引数 [1] pmid2srafile, [2] outputfile用の名前, [3] outputfileのうち、エラー出力用の名前
# pmid2srafileには，DBに新しく入れるPMID,SRAIDがタブ区切り,ヘッダーなしで入っている
# このSRAIDを，xRAの形になるよう名寄せ？する．
# outputは，その名寄せしたpmidとSRAidのペアを、重複無いように出力する
# @author: meguu

# pmid2sraには[[pmid,sraid,False],[pmid,sraid,False],...]の形でデータを持っているので、　
# 各リストの[1]を名寄せして書き換える．書き換えられたら,Trueに変更する
# MySQLのsra databeseのstudy_exp,exp_runを使う

# @editor: i_87, 29, June, 2011,
#          入力ファイルを, pmidとSRAのペアから, pmid, PMC, journal, ..., SRA 全てに変更する
#          出力も, SRAの部分だけ変更し, それ以外は全て出力するようにする
# @update meguu: 11/7/13 エラーログを上書き保存に．
# @editor: i_87, 26, Sept., 2011,
#          寄せる前のSRA IDを消さずにファイルに追記する


def useMySQL_set(cur,que,srAsraidlst,pmid2sra): # pmidsra = [pmid,sraid,False,line]
    cur.execute(que)
    RAids = cur.fetchall() # RAids = (('SRA000220',),)
    for RAid in RAids:
        srAsraidlst.append(RAid[0])
    if(len(srAsraidlst)>0):
        pmid2sra[1]=list(set(srAsraidlst))
        pmid2sra[2]=True

def useMySQL_RX(RXids,cur,srAsraidlst,pmid2sra):
    for RXid in RXids:
        que="select RP from study_exp where RX=\""+RXid[0]+"\""
        cur.execute(que)
        RPids = cur.fetchall() # (('SRP000220',),)
        for RPid in RPids:
            que="select RA from study2 where RP=\""+RPid[0]+"\""
            cur.execute(que)
            RAids = cur.fetchall()
            for RAid in RAids:
                srAsraidlst.append(RAid[0])
    if(len(srAsraidlst)>0):
        pmid2sra[1]=list(set(srAsraidlst))
        pmid2sra[2]=True

def useMySQL(pmid2sras): # pmidsras = [[pmid,sraid,False, line],..]
    try:
        connect = MySQLdb.connect(db="sra", host="127.0.0.1", port=3306, user="sra", passwd="shortread")
        cur = connect.cursor()
        for pmid2sra in pmid2sras:
            sraid=pmid2sra[1]
            srAsraidlst=[]
            if(len(sraid)<3):
                continue;
            if(sraid[1:3]=="RA"):
                que="select RA from study2 where RA=\""+sraid+"\""###study2
                useMySQL_set(cur,que,srAsraidlst,pmid2sra)
            elif(sraid[1:3]=="RP"):
                que="select RA from study2 where RP=\""+sraid+"\""###study2
                useMySQL_set(cur,que,srAsraidlst,pmid2sra)
            elif(sraid[1:3]=="RX"):
                #que="select distinct A.RA , A.RP, B.RX from study2 A join study_exp B on (A.RP = B.RP) where RX = \""+sraid+"\""
                RXids=((sraid,),)
                useMySQL_RX(RXids,cur,srAsraidlst,pmid2sra)
            elif(sraid[1:3]=="RR"):
                que="select RX from exp_run where RR=\""+sraid+"\""
                cur.execute(que)
                RXids = cur.fetchall()
                useMySQL_RX(RXids,cur,srAsraidlst,pmid2sra)
            elif(sraid[1:3]=="RS"):
                que="select RX from exp_sample where RS=\""+sraid+"\""
                cur.execute(que)
                RXids = cur.fetchall()
                useMySQL_RX(RXids,cur,srAsraidlst,pmid2sra)
            else:
                continue
    finally:
        cur.close()
        connect.close()
    return pmid2sras

# pmid2sraファイルを読み込む
def load(pmid2srafile):
    pmid2sras=[]
    fr = open(pmid2srafile,"r")
    try:
        for l in fr:
            col=l[:-1].split("\t")
            if(len(col)>0):
                pmid2sras.append([col[0],col[11],False, l[:-1]])
    finally:
        fr.close()
    return pmid2sras

# output
# pmidsras = [[pmid,sraid,False, line],..]
def pmid2sraOutPut(pmid2sras,outputfilename,outputerrname): 
    olst=[]
    oerrlst=[]
    for pmid2sra in pmid2sras:
        if(pmid2sra[2]==True):
            for sraid in pmid2sra[1]:             # pmid2sra[1]はsrAIDのリスト
                s_line=pmid2sra[3].split("\t")
                s = ""
                for j in range(0, 11):
                    s = s + s_line[j] + "\t"
                s = s + sraid + "\t"
#                for j in range(12, len(s_line)):
				# 行の一番最後にタブ or スペースが入っているものがあったので, カラム数を直接入力(前後x文字を取ったときの問題)
                s = s + s_line[12] + "\t" # SRAを取ってきた近辺を出力
                s = s + s_line[11]  # sra_origを追記する
                olst.append(s+"\n")
        else:
            # 以下エラー出力用：多くは、xRx->xRAに変換できなかったもの
            oerrlst.append(pmid2sra[0]+"\t"+pmid2sra[1]+"\t:Not found this sra_id.\n") 
    try:
        
        fw = open(outputfilename,"w")
        fwerr = open(outputerrname,"a")
        fw.writelines(olst)
        #fw.write("\n".join(list(set(olst))))
        #fw.write("\n")
        fwerr.writelines(oerrlst)
        #fwerr.write("\n".join(list(set(oerrlst))))
        #fwerr.write("\n")
    finally:
        fw.close()
        fwerr.close()

def main(pmid2srafile,outputfilename,outputerrname):
    pmid2sras = load(pmid2srafile)
    useMySQL(pmid2sras)
    pmid2sraOutPut(pmid2sras,outputfilename,outputerrname)
    
if __name__ == '__main__':
    args = sys.argv
    if len(args) != 4:
        sys.stdout.write("input err: [pmid2srafile] [output] [outputerr]")
    else:
        pmid2srafile=sys.argv[1]
        output=sys.argv[2]
        outputerr=sys.argv[3]
        main(pmid2srafile,output,outputerr)
