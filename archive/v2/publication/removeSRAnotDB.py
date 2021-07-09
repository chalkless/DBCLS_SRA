#!/usr/bin/python
# -*- coding: utf-8 -*-

import MySQLdb

##
# pmid2sraのテーブルに入っているもので,
# SRAがstudy2のRAにないものを削除する
# @author i_87, 2011, 8, 30
##

# pmid2sraにある全SRAIDを取得してリストで返す
def getAllSRA():
	try:
		connect = MySQLdb.connect(db="sra", host="127.0.0.1", port=3306, user="sra", passwd="shortread")
		cur = connect.cursor()
		que="select * from pmid2sra;" ## データベースに問い合わせるキュー
		cur.execute(que)
		return cur.fetchall()
		
	finally:
		cur.close()
		connect.close()

# pmid2sraのリストから, SRAIDがstudyに含まれているのか調べる
def removeSRAnotDB(pmid2sra_lst):
	try:
		connect = MySQLdb.connect(db="sra", host="127.0.0.1", port=3306, user="sra", passwd="shortread")
		cur = connect.cursor()
		for pmid2sra in pmid2sra_lst:
			sra_id = pmid2sra[1]  # 削除するか調べるID
			que = "select * from study2 where RA=\"" + str(sra_id) + "\";"  # データベースに問い合わせをするSRA ID
			cur.execute(que)
			result = cur.fetchall()
			if len(result) == 0:
				if len(pmid2sra[0]) > 0:
#					print pmid2sra
					r_que="delete from pmid2sra where pmid=\"" + str(pmid2sra[0]) + "\" and sra_id=\"" + str(pmid2sra[1]) + "\";" # データベースからレコードを削除するキュー
					print r_que
					print cur.execute(r_que)
					connect.commit()
			
	finally:
		cur.close()
		connect.close()

def run():
	pmid2sra_lst = getAllSRA()
	removeSRAnotDB(pmid2sra_lst)

if __name__ == '__main__':
	run()
