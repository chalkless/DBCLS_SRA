#!/usr/local/bin/python
# -*- coding: utf-8 -*-

# PubMed ID から, PMC と NGSのIDを抽出する
# pmid2sra.py を ファイルから実行するためのもの
# input: PMIDのリストが書かれたファイル, 出力するファイル名，本文ファイルを残すかのフラグ
#  （残さないならT,残すならF）
# output: PMC ID, SRA ID, SRA ID の前後10文字
# 1. PubMed ID -> xmlファイルを取得
# 2. xml から SRA のIDを抜く
# 3. PMC があったら, PMC の xml を取得
# 4. 3. で 4. をやる
# 作成者: i_87, 2011, 4/11
# update: meguu, 2011, 6/22
#         meguu, 2011, 7/13

import sys, time, pmid2sra
SLEEP_INTERVAL = 50
LIST_FILE = sys.argv[1] # PubMedのIDが書かれたファイル
OUT_FILE = sys.argv[2] # 出力するファイル名
removeflag = sys.argv[3] # 本文ファイルを残すかのフラグ,残さないならT,残すならF
OUT_ERROR_FILE = sys.argv[4]

def run():
	fw = open(OUT_FILE, 'w')
	fw.write("PMID\tPMC\tArticle Title\tJournal\tVol\tIssue\tPage\tFPage\tDate\tDoi\tPMC Flag\tSRA ID\tSRA Around\n")
	fw.close()
	times = 0 # pmid2sraを実行した回数, これが50回毎に5秒スリープする
	for line in open(LIST_FILE, "r"):
		times += 1
		if (times % SLEEP_INTERVAL) == 0: # 50回毎にスリープする
			time.sleep(5)
		pmid2sra.run(line[:-1], OUT_FILE, removeflag, OUT_ERROR_FILE)
run()
