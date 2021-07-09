#!/usr/bin/python
# -*- coding: utf-8 -*-

# GEOのIDのリストファイルから, ftp経由でSoft形式のファイルを取得
# @author, i_87, 7, Dec, 2011

# 引数1: GEOのIDが書かれたファイル
# 引数2: PMID, GEO, SRA を出力するファイル名. 一番最後に, origに追加するためのもの
# 引数3: PMID, SRA を出力するファイル名. こちらがこの先, getUpdatePMD.py 以下に渡されて行く

# Error: ファイルが空だった場合, Errorを出力して終了
# Error: ファイルが無い場合, Errorを出力して終了

# update: 2012/2/3 meguu getIDsの中をエラーを取れるように改造

import sys, os, urllib, re, gzip
import os.path, time

SLEEP_PER = 100 # ftpでこの回数アクセスするごとにsleepする
SLEEP_TIME = 5 # ftpでsleepする秒数
OUT_PER = 5 # この件数出力するごとにファイルに出力する

PRE_URL = "ftp://ftp.ncbi.nih.gov/pub/geo/DATA/SOFT/by_series/"
PMID_LINE_START = "!Series_pubmed_id"
SRA_LINE_START = "!Series_relation"
PMID_RE = "[0-9]+"
SRA_ID_RE = "[SED]R[APXSR][0-9]+"

NOT_FOUND = "-"
DOWNLOAD_FILES_DIR = "./soft_files/" # ダウンロードした SOFT ファイルを置くディレクトリ

# ファイルを読み込んで, GEO ID のリストを返す
def readInFile(in_filename):
	geo_ids_list = []
	line_num = 0
	fo = open(in_filename, 'r')
	line = fo.readline()
	while line: #for line in open(in_filename, 'r'):
		line_num = line_num + 1
		line = line[:-1]
		geo_ids_list.append(line)
		line = fo.readline()
	fo.close()
	if (line_num == 0):
		sys.stderr.write(in_filename + " does not have GSE ID.\n")
		sys.exit()
	return geo_ids_list

# GEOのIDから, ftp経由でSoft形式のファイルを取得する
# ダウンロードした解凍前のファイルのパスを返す
def getSOFTFile(geo_id):
	url = PRE_URL + geo_id + "/" + geo_id + "_family.soft.gz"
#	print url
	gz_file_path = DOWNLOAD_FILES_DIR + geo_id + "_family.soft.gz"
	try:
		urllib.urlretrieve(url, gz_file_path)
		# gzを展開する
		#file_path = gz_file_path[:-3]
		#dat = gzip.open(gz_file_path).read()
		#open(file_path, "wb").write(dat)
		# gzファイルを消す
		#if (os.path.exists(in_filename)):
		#	os.remove(gz_file_path)
		#return file_path
		return gz_file_path
	except IOError, e:
		sys.stderr.write("Error: " + url + " cannot found.\n")
		return None

# gzで固められたsoft形式のファイルを受け取り，解凍しつつ，ファイルの中身からpmid, sraidを抜き出す
def getIDs(gz_file_name):
	pmid = [] # 取得したPubMed IDを保存
	sra_ids = [] # 取得したSRA IDを保存
	# 正規表現をコンパイル
	p_pmid = re.compile(PMID_RE)
	p_sra = re.compile(SRA_ID_RE)
	try:
		#file_path = gz_file_path[:-3]
		#dat = gzip.open(gz_file_name).read()
		#open(file_path, "wb").write(dat)
		# gzファイルを消す
		#if (os.path.exists(in_filename)):
		#	os.remove(gz_file_path)
		#return file_path
		#print gz_file_name # for debug
		fo = gzip.open(gz_file_name) #fo = open(file_name,'r')
		line = fo.readline()
		while line: #for line in open(file_name, 'r'):
			line = line[:-1]
			# PMIDが記載されている行なら, 正規表現で文字列取得
			if (line.startswith(PMID_LINE_START)):
				#			print line
				for m in p_pmid.finditer(line):
					add_pmid = m.group(0)
					if not add_pmid in pmid:
						pmid.append(m.group(0))
				# SRAのIDが記載されている行なら, 正規表現で文字列取得
			if (line.startswith(SRA_LINE_START)):
				#			print line
				for m in p_sra.finditer(line):
					add_sra_id = m.group(0)
					if not add_sra_id in sra_ids:
						sra_ids.append(m.group(0))
			line = fo.readline()
		fo.close()
		return pmid, sra_ids
	except:
		sys.stderr.write("getGEO2PMID.py: getIDs(): input file error: %s\n"%(gz_file_name))
		fo.close()
		return pmid, sra_ids

def outlst(lst, outfile):
	fo = open(outfile, 'a')
	for out_str_lst in lst:
		out = ""
		for out_str in out_str_lst:
			out = out + out_str + "\t"
		out = out[:-1]
		fo.write(out + "\n")
	fo.close()

# GEOのID が書かれたリストから,
# ftp経由でSoft形式のファイルを取得,
# PMIDとSRAのIDを取得する
# geo_ids_list: GEOのIDが書かれたファイル
# out_pmid2geo: 出力するファイル, 
# out_pmid2sra: 
def getPMID2GEO2SRA(geo_ids_list, out_pmid2sra2geo, out_sra2geo):
#	geo2pmid_sra = [] # GEOのIDとPMID, SRA IDを保存するリスト
#	fo_pmid2sra2geo = open(out_pmid2sra2geo, 'w')
#	fo_sra2geo = open(out_sra2geo, 'w')
	pmid2sra2geo_lst = [] # PMIDとGEOとSRA_IDを保存するリスト
	sra2geo_lst = [] # SRAとGEOのIDを保存するリスト
	get_size = 0
	for geo_id in geo_ids_list:
		get_size = get_size + 1
		gz_file_name = getSOFTFile(geo_id) # GEOからSOFT形式のファイルを取得する
		# ファイル取得がうまくいっていたら, SRAとPMIDを探す
		if not ( gz_file_name == None ):
			if os.path.exists(gz_file_name) == False:
				sys.stderr.write("getGEO2PMID.py: not found this file.>%s\n"%(gz_file_name))
				sys.exit()
			pmids, sra_ids = getIDs(gz_file_name) #解凍前のファイルを渡す
#			print pmids
#			print sra_ids
			# 結果をファイルに出力する
			# PMIDがあるものは, output1に出力
			if (len(pmids) > 0):
				for pmid in pmids:
#					print pmid
					# PMIDがあるものは, output1に出力
					for sra_id in sra_ids:
						pmid2sra2geo_lst.append([pmid, sra_id, geo_id])
						if (len(pmid2sra2geo_lst) > OUT_PER): # 100件発見したら出力する
							outlst(pmid2sra2geo_lst, out_pmid2sra2geo)
#							print pmid2sra2geo_lst
							pmid2sra2geo_lst = []
#						fo_pmid2sra2geo = open(out_pmid2sra2geo, 'a')
#						fo_pmid2sra2geo.write(pmid + "\t" + sra_id + "\t" + geo_id+"\n")
#						fo_pmid2sra2geo.close()
#						print pmid + "\t" + sra_id + "\t" + geo_id
			# PMIDがなく,sraがあるものはoutput2に出力
			else:
				for sra_id in sra_ids:
					sra2geo_lst.append([sra_id, geo_id])
					if (len(sra2geo_lst) > OUT_PER):
#						print sra2geo_lst
						outlst(sra2geo_lst, out_sra2geo)
						sra2geo_lst = []
#					fo_sra2geo = open(out_sra2geo, 'a')
#					fo_sra2geo.write(sra_id + "\t" + geo_id+"\n")
#					fo_sra2geo.close()
#					print sra_id + "\t" + geo_id
			# PMIDが複数存在したら, 複数ある旨をWarningで記載
			if (len(pmids) > 1):
				sys.stderr.write("Warning: Some PMIDs are found from " + geo_id + "\n")
			# ftpで取得したファイルを消す
			os.remove(gz_file_name)
		# 100回連続でファイルを取得したらスリープする
		if (get_size % SLEEP_PER == 0):
			#print "wait ..."###debug
			time.sleep(SLEEP_TIME)
	# 最後にリストの残りをoutputする
	outlst(pmid2sra2geo_lst, out_pmid2sra2geo)
	outlst(sra2geo_lst, out_sra2geo)
#	fo_pmid2sra2geo.close()
#	fo_sra2geo.close()

def run(in_filename, out_pmid2sra2geo, out_sra2geo):
#	print "read file ..."
	geo_ids_list = readInFile(in_filename)
#	print "get pmid and sra ..."
	getPMID2GEO2SRA(geo_ids_list, out_pmid2sra2geo, out_sra2geo)


if __name__ == "__main__":
	# 引数チェック
	if not (len(sys.argv) == 4):
		sys.stderr.write("Error: input a UID list file, output_file1 output_file2.\n")
		sys.exit()

	# 引数のファイル名のチェック
	in_filename = sys.argv[1]
	out_pmid2sra2geo = sys.argv[2]
	out_sra2geo = sys.argv[3]
	if not (os.path.exists(in_filename)):
		sys.stderr.write("Error: not found " + in_filename + "\n")
		sys.exit()

	# soft_filesディレクトリがなければ新規作成
	if not (os.path.exists(DOWNLOAD_FILES_DIR)):
		os.mkdir(DOWNLOAD_FILES_DIR)

	# outputファイルがすでにあったら消去
	if os.path.exists(out_pmid2sra2geo):
		os.remove(out_pmid2sra2geo)
	if os.path.exists(out_sra2geo):
		os.remove(out_sra2geo)
		
	# 実行
	run(in_filename, out_pmid2sra2geo, out_sra2geo)
