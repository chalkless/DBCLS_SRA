#!/usr/local/bin/python
# -*- coding: utf-8 -*-
# PubMed ID から, PMC と NGSのIDを抽出する
# input: PMID, 出力ファイル，フラグ（True/False）
# output: PMC ID, SRA ID, SRA ID の前後10文字
# 1. PubMed ID -> xmlファイルを取得
# 2. xml から SRA のIDを抜く
# 3. PMC があったら, PMC の xml を取得
# 4. 3. で 4. をやる
# 5. フラグがTrueだったら、本文ファイルを削除する
# 作成者: i_87, 2011, 3/30
# update: meguu, 2011, 6/22
# update: i_87, 2011, 6/24 error出力を, pmidとfpageが無いことを明記するように変更
# update: meguu 2011, 7/13 error出力するファイル名を引数として受け取るように変更,
#                          errorファイルが上書きになっていることを確認
import sys, urllib, re, os

PMID = sys.argv[1] # PubMed ID
OUT_FILE = sys.argv[2] # 出力するファイル名
removeFlag = sys.argv[3] # フラグ, T/F Tなら取得したxmlファイルを消す

#OUT_ERROR_FILE = OUT_FILE+"_error"
OUT_ERROR_FILE = sys.argv[4]

OUT_NULL = "-"
OUT_SRA_FB = 15 # SRAのIDがあったときに出力する前後x文字
E_URL = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?retmode=xml" # e-fetch からxmlを取得するアドレス
DOWNLOAD_LOG="xml_files/xml_download.log"
PMC_MATCH = "PMC[0-9]+" # PubMedからPMC のIDを抽出するときのサーチする部分
SRA_P = re.compile("[SED]R[APXSR][0-9]+") # SRAのIDを抽出する部分
NOT_USED = "The publisher of this article does not allow downloading of the full text in XML form."	#PMCはあっても,使えない場合

##
# 一つのPMIDが保持する情報を表すクラス
# pmid: PubMedのID
# pmc_id: PMCのID
# title: 論文名
# journal: 掲載論文の情報
# doi: doi
##
class Paper:
	def __init__(self, pmid):
		self.pmid = pmid
		self.pmc_id = self.title = self.doi = OUT_NULL
		self.pmc_use = "false" # PMCが使用できるものかどうか
		self.journal = {"journal" : OUT_NULL, # pmcが乗っているジャーナル名
							   "volume" : OUT_NULL, # ジャーナルのvolume
							   "issue" : OUT_NULL, # ジャーナルのissue
							   "page" : OUT_NULL, # ジャーナルの掲載ページ
							   "date" : {"year" : OUT_NULL, "month" : OUT_NULL, "day" : OUT_NULL},
							   "fpage" : OUT_NULL} # ジャーナルのfpage(スタートページ)
		self.sra_ids = []
	
	# 抽出したSRA以外のpaperの情報をタブ区切りで出力する
	# 出力するのは, OUT_FILE (実行時の第2引数)
	def output_paper(self, fw):
		fw.write(self.pmid + "\t" + self.pmc_id+ "\t" + self.title + "\t"+
			self.journal["journal"] + "\t" + self.journal["volume"] + "\t" + self.journal["issue"] + "\t" + self.journal["page"] + "\t" +
			self.journal["fpage"] + "\t")
		# 日付の出力
		date_out = self.journal["date"]["year"]
		if not self.journal["date"]["month"] == OUT_NULL:
			date_out = date_out + "-" + self.journal["date"]["month"]
			if not self.journal["date"]["day"] == OUT_NULL:
				date_out = date_out + "-" + self.journal["date"]["day"]
		fw.write(date_out +"\t")
		fw.write(self.doi + "\t" + self.pmc_use + "\t")
	
	# SRAの情報を含む全ての情報をタブ区切りで出力する
	def output(self, OUT_FILE):
		fw = open(OUT_FILE, 'a')
		if len(self.sra_ids) > 0: # SRAのIDが一つ以上ある場合
			for sra_id in self.sra_ids:
				self.output_paper(fw)
				fw.write(sra_id[0] + "\t" + sra_id[1] + "\n")
		else: # SRAのIDが一つも無い場合
			self.output_paper(fw)
			fw.write(OUT_NULL + "\t" + OUT_NULL+"\n")
		fw.close()

##
# xml ファイルを e-utils でダウンロードする
# id: 論文のID
# db: ダウンロードするデータベース, pubmedかpmc
##
def downloadXML(id, db, filename):
    url = E_URL + "&db=" + db + "&id=" + id
    urllib.urlretrieve(url, filename)

##
# SRAのIDにマッチする箇所を抽出して, マップに対応付ける
# line: SRAのIDとのマッチを調べる文字列
# sra_ids: SRAのIDをキー, 前後x文字を値とするマップ
##
def getSRAIDs(line, paper):
	search_str = line
	search_str_start = 0
	m = SRA_P.search(search_str)
	while True:
		if m == None:
			break
		m_start = m.start(); m_end = m.end()
		get_sra_id = search_str[m_start:m_end] # 抽出したSRAのID
		get_sra_pb = line[(search_str_start+m_start-OUT_SRA_FB):(search_str_start+m_end+OUT_SRA_FB)] # 抽出したSRAの前後の文字
		paper.sra_ids.append([get_sra_id, get_sra_pb])
		search_str = search_str[m_end:]
		search_str_start += m_end
		m = SRA_P.search(search_str)
	return paper

##
# PubMedのxmlファイルから, PMCのID, Jounal の情報, SRAのIDを返す
##
def getID4PM(filename, paper):
	p_pmc = re.compile("<OtherID Source=\"NLM\">PMC[0-9]+.*</OtherID>")
	p_pmcid = re.compile("PMC[0-9]+")
	f = open(filename, 'r')
	for line in f:
		# PMC_IDを調べる
		p_pmc = re.compile("<OtherID Source=\"NLM\">PMC[0-9]+.*</OtherID>")
		m = p_pmc.search(line)
		if not m == None: # PMCの該当箇所がある場合
			pmc_str = m.group()
			paper.pmc_id = p_pmcid.search(pmc_str).group()[3:] # 抽出したPMCのID
			find_available = pmc_str.find("Available on") # 後日公開予定か調べる, 後日なら, pmc_useを日付にする
			if find_available >=0:
				paper.pmc_use = pmc_str[find_available:-11]
		# 論文のタイトル
		s = line.split("<ArticleTitle>")
		if len(s) > 1:
			paper.title = s[1].split("</ArticleTitle>")[0][:-1]
		# journal の情報を取得する
		if line.find("<Journal>") >= 0:
			for line in f:
				if line.find("</Journal>") >= 0:
					break
				s = line.split("<Title>") # 雑誌名の取得
				if len(s) > 1:
					paper.journal["journal"] = s[1][:-9]
				s = line.split("<Volume>") # volumeの取得
				if len(s) > 1:
					paper.journal["volume"] = s[1][:-10]
				s = line.split("<Issue>")
				if len(s) > 1:
					paper.journal["issue"] = s[1][:-9]
				s = line.split("<Year>") # 雑誌の掲載日を取得
				if len(s) > 1:
					paper.journal["date"]["year"] = s[1][:-8]
				s = line.split("<Month>")
				if len(s) > 1:
					paper.journal["date"]["month"] = s[1][:-9]
				s = line.split("<Day>")
				if len(s) > 1:
					paper.journal["date"]["day"] = s[1][:-7]
		# ページを取得する
		s = line.split("<MedlinePgn>")
		if len(s) > 1:
			paper.journal["page"] = s[1].split("</MedlinePgn>")[0]
		# doiを取得する
		s = line.split("<ArticleId IdType=\"doi\">")
		if len(s) > 1:
			paper.doi = s[1][:-13]
        # SRA_IDの有無を調べる
		paper = getSRAIDs(line[:-1], paper)
	f.close()
	return paper

##
# PMCからfpageを取得する
##
def getFPage(filename, paper):
	article_meta_flag = False # article_metaの中かを調べるフラグ
	for line in open(filename, 'r'):
		search_line = line
		if search_line.find("<article-meta>") >= 0:
			search_line = search_line.split("<article-meta>")[1] # s: <article-meta>の中身
			article_meta_flag = True
		if search_line.find("</article-meta>") >= 0:
			search_line = search_line.split("</article-meta>")[0]
		# article-metaの中の文字列なら, fpageタグを探す
		if article_meta_flag == True:
			if search_line.find("<fpage>") >= 0:	
				return search_line.split("<fpage>")[1].split("</fpage>")[0]
		if line.find("</article-meta>") >= 0:
			article_meta_flag = False
	# fpageが見つからなかったエラーを出力する
	fw = open(OUT_ERROR_FILE, 'a')
	fw.write("PMID:" + paper.pmid + ", not found fpage\n")
	#print "PMID:" + paper.pmid + ", not found fpage"
	fw.close()
	return OUT_NULL

##
# xmlファイルから, SRAのIDを抽出する
##
def getID4PMC(filename, paper):
	paper.pmc_use = "true" # PMCが使えるか判断するフラグ
	paper.journal["fpage"] = getFPage(filename, paper) # fpageを取得する
	for line in open(filename, 'r'):
		# <article-meta>の中のfpageを抽出, 無ければerrorと出力
#		if line.find("<article-meta>") >= 0 and line.find("</article-meta>"): # 1行に<article-meta>が全て含まれている場合
#			s = line.split("<article-meta>")[1].split("</article-meta>")[0]
#			if s.find("<fpage>") >= 0:	
#				if paper.journal["fpage"] == OUT_NULL:
#					paper.journal["fpage"] = s.split("<fpage>")[1].split("</fpage>")[0]
#				else:
#					print "error"
#		elseif line.fine("<article-meta>") >= 0: # <article-meta> の最初のタグだけある場合
#			article_meta_flag = 
			
		# PMCでxmlファイルが取得できない場合には, falseにする
		if line.find(NOT_USED) >= 0:
			paper.pmc_use = NOT_USED
		# SRAでマッチした部分を返す
		paper = getSRAIDs(line[:-1], paper)

##パス先のファイル名が存在すれば、削除する
def removeFile(filename):
	if(os.path.isfile(filename)==True):
		os.remove(filename)
	
##
# 実行
# pmid: 調査するPMID
# out_file: 出力するファイル名, 後ろに追記されていく
##
def run(pmid, out_file, rmflg, err_file):
	RMFLAG = True
	if(rmflg=="F"): # 本文ファイルを残す(Flase)か残さない（True）か．
		RMFLAG=False
	paper = Paper(pmid)
	filename_pm = "xml_files/pubmed" + pmid + ".xml"
	downloadXML(pmid, "pubmed", filename_pm)
	paper = Paper(pmid)
	paper = getID4PM(filename_pm, paper)
    # PMCが有れば, xmlファイルを取得して解析する
	if not paper.pmc_id == OUT_NULL and paper.pmc_use == "false":
		filename_pmc = "xml_files/pmc" + paper.pmc_id + ".xml"
		downloadXML(paper.pmc_id, "pmc", filename_pmc)
		getID4PMC(filename_pmc, paper)
		# filename_pmcがあれば削除する
		if(RMFLAG==True):
			removeFile(filename_pmc)
	# 結果を出力
	paper.output(out_file)
	# filename_pmがあれば削除する
	if(RMFLAG==True):
		removeFile(filename_pm)

	
run(PMID, OUT_FILE, removeFlag,OUT_ERROR_FILE)
