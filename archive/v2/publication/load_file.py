#!/usr/bin/python
# -*- coding: utf-8 -*-
import MySQLdb
import sys
import os.path

#
# input: pmid2sra, article file
# or
# input : pmid2sra
# pmid2sra のデータのみをupdateすることもできる
# ファイルの順番を間違えると違うデータベースに入れられるので注意
# update : meguu 11.7.13

### mySQLの接続のための設定
dbname="sra"
hostip="127.0.0.1"
portnum=3306
pas="shortread"
usrname="sra"

### mySQLの中のテーブル名
# 項目の、pmid, sra_id, sra_id_orig が入っている.  (pmid. sra_id)ペア に重複はありうる．
pmid2sra_table="pmid2sra2"
# pmidをキーに、文献情報が入っている
article_table="article"
# sra_idをキーに、実験DB情報が入っている
study2_table="study2"
# (pmid. sra_id)ペア に重複はない、sra_id_origはカンマ区切りで入っている
view_table="view_all"

# ファイルの中身が一行以上あるか確かめる 一行以上あれば1を返し，空なら0を返す．
def check_file(filename):
    count = 0
    if(os.path.isfile(filename)==False):
        sys.stdout.write("load_file.py: not found this file.\n"+filename+"\n")
        return count
    try:
        fr = open(filename,"r")
        for l in fr:
            count += 1
            if(count==1):
                fr.close()
                return count
        if count == 0:
            sys.stdout.write("load_file.py: no data :"+filename+"\n")
    finally:
        fr.close()
        return count

# もしsra_id_origを""で入れているとき、ここで、新しく更新される(pmid, sra_id)のsra_id_origが""ならば、そのレコードを消さねばならない．
# delete from pmid2sra2 where pmid = pmid and sra_id = sra_id and sra_id_orig = ""; ??
def deleteEmpty(pmid2srafile):
    try:
        connect = MySQLdb.connect(db=dbname, host=hostip, port=portnum, user=usrname, passwd=pas)
        cur = connect.cursor()
        fo = open(pmid2srafile, "r")
        line = fo.readline()
        while line :
            cols = line.split("\t") # cols = 0.pmid, 1.sra_id, 2.sra_id_orig
            pmid = cols[0]
            sra_id = cols[1]
            sra_id_orig = cols[2]
            cur.execute("DELETE FROM "+pmid2sra_table+" WHERE pmid=\""+pmid+"\" and sra_id=\""+sra_id+"\" and sra_id_orig=\"\" ;")
            connect.commit()
            line = fo.readline()
        fo.close()
        cur.close()
        connect.close()
    except:
        print "error: cannot liad data in MuSQL database.[] pmid2sra_data"

    
# pmid2sra tableにpmid2srafileの中身のデータを入れる
def load_pmid2sra(pmid2srafile):
    ######　もしsra_id_origを""で入れているとき、ここで、新しく更新される(pmid, sra_id)のsra_id_origが""ならば、そのレコードを消さねばならない．
    deleteEmpty(pmid2srafile) #######??
    try:
        connect = MySQLdb.connect(db=dbname, host=hostip, port=portnum, user=usrname, passwd=pas)
        cur = connect.cursor()    
        cur.execute("LOAD DATA INFILE '"+pmid2srafile+"' REPLACE INTO TABLE "+pmid2sra_table+" FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';")
        connect.commit()
        cur.close()
        connect.close()
    except:
        print "error: cannot load data in MySQL database. [pmid2sra_data]"

# article tableにarticlefileの中身のデータを入れる
def load_article(articlefile):
    try:
        connect = MySQLdb.connect(db=dbname, host=hostip, port=portnum, user=usrname, passwd=pas)
        cur = connect.cursor()
        cur.execute("LOAD DATA INFILE '"+articlefile+"' REPLACE INTO TABLE "+article_table+" FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';")
        connect.commit()
        cur.close()
        connect.close()
    except:
        print "error: cannot load data in MySQL database. [article_data]"
        #results = connect.info()
        #print results

def pmid2srasappend(pmid, sra_id, sra_id_orig, pmid2sras):
    if pmid2sras == []:
        pmid2sras.append((pmid, sra_id, [sra_id_orig]))
        return pmid2sras
    else:
        for i in range(len(pmid2sras)):
            if pmid2sras[i][0] == pmid:
                if pmid2sras[i][1] == sra_id:
                    if sra_id_orig in pmid2sras[i][2]:
                        return pmid2sras
                    else:
                        pmid2sras[i][2].append(sra_id_orig)
                        return pmid2sras
        pmid2sras.append((pmid, sra_id, [sra_id_orig]))
        return pmid2sras

# pmid2srafileを開いて中身をリストに入れて返す
# pmid2sras = [[pmid, sra_id, [sra_id_orig, ...]]. ....]
def openpmid2srafile(pmid2srafile):
    pmid2sras = []
    try:
        fo = open(pmid2srafile, "r")
        line = fo.readline()
        while line:
            cols = line[:-1].split("\t")
            if len(cols) == 3:
                pmid2sras = pmid2srasappend(cols[0], cols[1], cols[2], pmid2sras)
            else:
                sys.stdout.write("error?: load_file.py > openpmid2srafile(): pmid2srafile don't have 3 columns.\n")            
            line = fo.readline()
        fo.close()
        # ここで、pmidとsraidが同じセットがあれば、sra_id_origをlistにする
    finally:
        return pmid2sras


# rowsとsra_id_origlstの和集合を返す
def retSra_id_orig(sra_id_origlst, rows):
    for row in rows:
        if row == "": #######もしsra_id_origを""で入れているとき,これでok
            continue
        if row[0] in sra_id_origlst:
            continue
        sra_id_origlst.append(row[0])
    return sra_id_origlst

# return: article_title, journal, vol, issue, page, date
def selectArticle(pmid, dd, cur):
    try:
        cur.execute("SELECT title, journal, vol, issue, page, date FROM "+article_table+" WHERE pmid=\""+pmid+"\";")
        rows = cur.fetchall()
        if len(rows) != 1: # 論文のデータは一種類だけ入っているはずなので、複数あるとおかしい
            sys.stdout.write("warning: load_file.py:retViewSet...in "+article_table+" table, not uniq pmid="+pmid+".\n")
            #return False, dd, cur

        dd["article_title"]=rows[0][0]
        dd["journal"]=rows[0][1]
        dd["vol"]=rows[0][2]
        dd["issue"]=rows[0][3]
        dd["page"]=rows[0][4]
        dd["date"]=rows[0][5]
        return True, dd, cur
    except:
        print "error: cannot read data in MySQL database.:"+article_table
        return False, dd, cur

# return : sra_title, taxon_id, platform, study_type
def selectStudy2(sra_id, dd, cur):
    try:
        cur.execute("SELECT STUDY_TITLE, TAXON_ID, PLATFORM, STUDY_TYPE FROM "+study2_table+" WHERE RA=\""+sra_id+"\";")
        rows = cur.fetchall()
        if len(rows) != 1: # データは一種類だけ入っているはずなので、複数あるとおかしい
            sys.stdout.write("warning: load_file.py:retViewSet...in "+study2_table+" table, not uniq RA="+sra_id+".\n")
        dd["sra_title"]=rows[0][0]
        dd["taxon_id"]=str(rows[0][1])
        dd["platform"]=rows[0][2]
        dd["study_type"]=rows[0][3]
        return True, dd, cur
    except:
        print "error: cannot read data in MySQL database.:"+study2_table
        return False, dd, cur

# (pmid, sraid)のペアがpmid2sra tableにあるかを調べる
def selectSra_id_orig(pmid, sra_id, sra_id_origlst, dd, cur):
    try:
        cur.execute("SELECT sra_id_orig FROM "+pmid2sra_table+" WHERE pmid=\"" + pmid + "\" and sra_id=\"" + sra_id + "\";")
        rows = cur.fetchall()
        if len(rows) == 0:
            sys.stdout.write("error: load_file.py:retViewSet...not found (pmid, sra)pair. pmid="+pmid+", sra_id="+sra_id+".\n")
            return False, dd, cur
        else:
            sra_id_origlst = retSra_id_orig(sra_id_origlst, rows)
            dd["pmid"]=pmid
            dd["sra_id"]=sra_id
            idlst = ", ".join(sra_id_origlst)
            dd["sra_id_orig"]=idlst
            return True, dd, cur
    except:
        print "error: cannot read data in MySQL database.:"+pmid2sra_table
        return False, dd, cur

def checkdd(dd):
    l = ["pmid", "sra_id","article_title","journal", "vol", "issue", "page", "date", "sra_id_orig", "sra_id", "sra_title", "taxon_id", "platform", "study_type"]
    for ky in l:
        if dd.has_key(ky) == False:
            sys.stdout.write("err: load_file.py:dd dont have key:"+ky+"\n")
            return False
    return True
    
# view_tableを見て、insertするかupdateするかを決める
def insertOrupload(dd, cur, connect):
    try:
        if(checkdd(dd)==False):
            return cur
        cur.execute("SELECT sra_id FROM "+view_table+" WHERE pmid=\"" + dd["pmid"] + "\" and sra_id=\"" + dd["sra_id"] + "\";")
        rows = cur.fetchall()
        if len(rows) == 0: # insertする
            que = "insert into "+view_table+" values (\""+ dd["pmid"] + "\", \""+ dd["article_title"] + "\", \""+dd["journal"]+ "\", \""+dd["vol"]+ "\", \""+dd["issue"]+ "\", \""+dd["page"]+ "\", \""+dd["date"]+ "\",\""+dd["sra_id_orig"]+"\",\""+dd["sra_id"]+"\", \""+dd["sra_title"]+ "\", \""+dd["taxon_id"]+ "\", \""+dd["platform"]+ "\", \""+dd["study_type"]+ "\");"
            cur.execute(que)
            connect.commit()
        elif len(rows) == 1: # update する
            que = "UPDATE " +view_table+ " SET article_title=\""+dd["article_title"]+ "\", journal=\""+dd["journal"]+ "\", vol=\""+dd["vol"]+ "\", issue=\""+dd["issue"]+ "\", page=\""+dd["page"]+ "\", date=\""+dd["date"]+ "\", sra_id_orig=\""+dd["sra_id_orig"] +"\", sra_title=\""+dd["sra_title"]+ "\", taxon_id=\""+dd["taxon_id"]+ "\", platform=\""+dd["platform"]+ "\", study_type=\""+dd["study_type"]+ "\" WHERE pmid=\""+dd["pmid"]+"\" and sra_id=\""+dd["sra_id"]+"\";"
            cur.execute(que)
            connect.commit()
        else: # pmid,sra_idが同じものが2セット以上あるとおかしい
            sys.stdout.write("error: load_file.py:insertOrupload(): ")
        return cur, connect
    except:
        print "error: cannot insert/upload data in MySQL database.:"+view_table
        return cur, connect

    
#connect = MySQLdb.connect(db="sra", host="127.0.0.1", port=3306, user="sra", passwd="shortread")
# この関数に来るまでに、(pmid,sra_id,sra_id_orig)は、pmid2sra_tableには入っていて、 view_tableには入っていない.
# pmid2sra2([[pmid,sraid, sra_id_orig],...])をみて、view用テーブルの更新に必要なデータセット(dict)を作ってupdate or insert
def updateViewSet(pmid2sras):
    try:
        #print "db="+dbname+", host="+hostip+", port="+str(portnum)+", user="+usrname+", passwd="+pas
        #connect = MySQLdb.connect(db="sra", host="127.0.0.1", port=3306, user="sra", passwd="shortread")
        connect = MySQLdb.connect(db=dbname, host=hostip, port=portnum, user=usrname, passwd=pas)        
        cur = connect.cursor()
        for pmid2sra in pmid2sras:
            dd = {}
            # (pmid, sraid)のペアがpmid2sra tableにあるかを調べる
            #pmid=pmid2sra[0], sra_id=pmid2sra[1] , sra_id_origlst=pmid2sra[2] # これだけリストの中に入っている [id, id , ...]
            flg, dd, cur = selectSra_id_orig(pmid2sra[0], pmid2sra[1], pmid2sra[2], dd, cur)
            if flg == False:
                continue
            # pmidから、article_tableを引いて、文献情報を得る            
            flg1, dd, cur= selectArticle(pmid2sra[0], dd,cur)
            if flg1 == False:
                continue
            # sra_idから、study2_tableを引いて、実験DBの情報を得る
            flg2, dd, cur = selectStudy2(pmid2sra[1], dd, cur)
            if flg2 == False:
                continue
            # view_tableを見て、insertするかupdateするかを決める
            cur, connect = insertOrupload(dd, cur, connect)
        cur.close()
        connect.close()
    except:
        print "error: cannot read data in MySQL database."

# この関数に来るまでに、pmid2srafileの中身の(pmid,sra_id,sra_id_orig)は、pmid2sra_tableには入っていて、 view_tableには入っていない.
def load_viewtable(pmid2srafile):
    pmid2sras = openpmid2srafile(pmid2srafile)
    if pmid2sras == []:
        return
    updateViewSet(pmid2sras)
    
def main(pmid2srafile, articlefile):
    if(check_file(articlefile)!=0):# ファイルの中に一行以上あれば、loadを実行
        load_article(articlefile)
        
    if(check_file(pmid2srafile)!=0):# ファイルの中に一行以上あれば、loadを実行
        load_pmid2sra(pmid2srafile)
        load_viewtable(pmid2srafile) # load_articleをやってからやったほうがいい

def main2(pmid2srafile):
    if(check_file(pmid2srafile)!=0):
        load_pmid2sra(pmid2srafile)
        load_viewtable(pmid2srafile)
    
if __name__ == '__main__':
    if(len(sys.argv)==3):
        pmid2srafile=sys.argv[1]
        articlefile=sys.argv[2]
        main(pmid2srafile,articlefile)
        
    elif(len(sys.argv)==2):
        pmid2srafile=sys.argv[1]
        main2(pmid2srafile)
        
    else:
        print "error: input file "
