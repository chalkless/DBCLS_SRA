#!/usr/bin/python
# -*- coding: utf-8 -*-

##
# 新しくDBに追加する候補のファイルで
# 新しく作成したファイルにしかないPMIDとSRAのペアを出力する
# 引数1: 旧ファイル
# 引数2: 新ファイル
# 引数3: 作成するファイル, PMIDとSRAのペアを出力する
# 引数4: 作成するファイル, PMIDに追加するabstやタイトルを追加する
# @author: i_87, 2011, 5/20
# @editor: i_87, 2011, 6/8 以前のファイル読み込み形式から,
#                          DBに問い合わせてpmidとsraの有無を確認する形式に変更する
# update: meguu 2011/7/13 diff出来ていなかったので修正
# @editor: i_87, 2011, 9/26 .pmid2sraのファイルに, 変更前のSRAのIDも出力するよう変更
# @editor: i_87, 2011, 10/19 使用するDBをpmid2sra2に変更する
# @editor: i_87, 2011, 11/25 ファイルのタイトルが "-" なら，
#                            articleに読み込ませるファイルに出力しないようにする
##

import MySQLdb
import sys
import os.path
##
# 新たに追加するファイルを作成する
# ファイル形式は, PMIDとSRAの対応を含め, PMC, Title, ...,
# が保持されているもの
# in_file: 新たに追加するSARが書かれているファイル
# out_pmid2sra: 作成するpmidとsraのIDが書かれたファイル
##
def writeNewFile(in_file, out_pmid2sra, out_article):
	f_pmid2sra = open(out_pmid2sra, 'w')
	f_article = open(out_article, 'w')
	connect = MySQLdb.connect(db="sra", host="127.0.0.1", port=3306, user="sra", passwd="shortread") # DBへの接続確保
	cur = connect.cursor()
	add_pmids = [] # out_articleに出力したpmid集合
	add_pmid2sras = {} # out_pmid2sraに出力したpmidとsraの集合
	
	# 新たに追加したいSRAが書かれているファイルを1行ずつ読み込んで,
	# pmidとsraの有無をDBに問い合わせ, DBに無ければファイルに出力する
	for line in open(in_file, 'r'):
		s = line[:-1].split('\t')
		if(len(s)>=12):
			pmid = s[0]
			sra = s[11]
			sra_orig = s[13]
		else:
			print "error: " +line
			continue
		# pmidが"PMID"と記載されていたら, カラムの説明なので, スキップ
		if pmid == "PMID":
			continue
		# SRAが見つからないPMIDなら, スキップ
		if sra == "-":
			continue
		# pmidが既にDBにある場合, SRAがなければ追加する
		# pmidの確認は, 論文のアブスト情報が乗っている articleにする
		que = "SELECT COUNT(pmid) FROM article WHERE pmid=\"" + pmid + "\""
		cur.execute(que)
		pmid_size = cur.fetchall()[0][0]
		if pmid_size == 0:
			if not pmid in add_pmids: # pmidがDBに無い&ファイルにも出力していない場合
				# pmidのabstなどを追記
				title = s[2]
				journal = s[3]
				vol = s[4]
				issue = s[5]
				page = s[6]
				date = s[8]
				# journal titleがハイフンでなければ, articleファイルに出力
				if not (title == "-"):
					f_article.write(pmid+"\t"+title+"\t"+journal+"\t"+vol+"\t"+issue+"\t"+page+"\t"+date+"\n")
					add_pmids.append(pmid)
		# pmidとsra, sra_origのペアを確認
		que = "SELECT sra_id, sra_id_orig FROM pmid2sra2 WHERE pmid=\"" + pmid + "\""
		cur.execute(que)
		sra_ids = cur.fetchall()
		# sra_ids=(('DRA000169', 'DRX000214'), ('SRA003626', 'SRX001881'), ('SRA008390', 'SRX003892'), ('SRA008390', 'SRX003890')) こんな感じ
		# pmidとsraのペアがDBになく, ファイルにも出力していなければ追記する
		if not (sra, sra_orig) in sra_ids:
			# pmidが初めて出てきたときに, sraをいれる様のリストを作成
			if not add_pmid2sras.has_key(pmid):
				add_pmid2sras[pmid] = []
			if not (sra, sra_orig) in add_pmid2sras[pmid]:
				f_pmid2sra.write(pmid+"\t"+sra +"\t"+sra_orig+"\n")
				add_pmid2sras[pmid].append((sra, sra_orig))
	f_pmid2sra.close()
	f_article.close()

# new_file:
# out_pmid2sra_file: 出力するPMIDとSRAの対応ファイル
# out_pmid_file: 
def main(new_file, out_pmid2sra_file, out_pmid_file):
	if os.path.exists(new_file) == False:
		sys.stderr.write("diff_pmid2sra.py: not found this file.>%s\n"%(new_file))
		sys.exit()
	writeNewFile(new_file, out_pmid2sra_file, out_pmid_file)

if __name__ == "__main__":
    # 引数チェック
    if len(sys.argv) != 4:
        print "error: input [network file name] , [output pmid2sra file name] and [output article file name]."
    else:
        main(sys.argv[1], sys.argv[2], sys.argv[3] )
