#!/usr/bin/python
# -*- coding: utf-8 -*-

# UIDのリストファイルから, GEOのファイルを取得, SRAのIDをゲットする
# EFetchに100回アクセスするごとに5秒スリープする
# @author, i_87, 7, Dec, 2011

# 引数1: UIDが書かれたファイル名
# 引数2: 出力するファイル名
# Error: ファイルが空だった場合, Errorを出力して終了
# Error: ファイルが無い場合, Errorを出力して終了

import sys, os, urllib, re, time

PRE_URL = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=gds&report=docsum&mode=html"
GSE_ID_RE = "GSE[0-9]+"
SLEEP_PER = 100
SLEEP_TIME = 5

# UIDのリストファイルを読み込んで,
# GSEのリストを取得する
def getFiles(filename):
	gse_list = [] # 取得したGSEIDのリスト
	p_gse = re.compile(GSE_ID_RE) # GSEのIDの正規表現
	
	line_num = 0
	for uid in open(filename, 'r'):
		line_num = line_num + 1
		uid = uid[:-1]
		url = PRE_URL + "&id=" + uid
		geo = None # 取得したGEOのIDを保持
		gse_size = 0
		for line in urllib.urlopen(url):
			line = line[:-1]
			# GSEのIDを取得する
			if (line.startswith("1: GSE")):
				gse_size = gse_size + 1
				m_gse = p_gse.search(line)
				gse = m_gse.group()
				if not (gse in gse_list):
					gse_list.append(gse)
		# 100回連続でファイルを取得したらスリープする
		if (line_num % SLEEP_PER == 0):
			time.sleep(SLEEP_TIME)
		# GEOのIDが見つからなければ, エラーを出力
		if (gse_size == 0):
			sys.stderr.write("Error: Not found GEO ID from UID " + uid + "\n")
		if (gse_size > 1):
			sys.stderr.write("Error: find GEO ID more than 2 from UID " + uid + "\n")
	if (line_num == 0):
		sys.stderr.write(filename + " does not have UID.\n")
		sys.exit()
	
	return gse_list

def output(out_filename, gse_list):
	fw = open(out_filename, 'w')
	for gse in gse_list:
		fw.write(gse + "\n")
	fw.close()

def run(in_filename, out_filename):
	gse_list = getFiles(in_filename)
	output(out_filename, gse_list)

if __name__ == "__main__":
	# 引数チェック
	if not (len(sys.argv) == 3):
		sys.stderr.write("Error: input a UID list file and output file.\n")
		sys.exit()

	# 引数のファイル名のチェック
	in_filename = sys.argv[1]
	out_filename = sys.argv[2]
	if not (os.path.exists(in_filename)):
		sys.stderr.write("Error: not found " + in_filename + "\n")
		sys.exit()
		
	# 実行
	run(in_filename, out_filename)
