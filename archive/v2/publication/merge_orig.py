#!/usr/bin/python
# -*- coding: utf-8 -*-

# meguu 
import sys, os.path
## 7. output3_1を使って、out_pmid2sraのsra_id_origとマージする(置き換える)
#out_pmid2sra_geoorig=${out_pmid2sra}'.geoorig'
#echo "7. " >> ${errlog} 
#echo "- "${out_pmid2sra_geoorig} >> ${errlog}
#python merge_orig.py ${output3_2} ${out_pmid2sra} ${out_pmid2sra_geoorig} >> ${errlog}

BSIZE=1024*1024*500
Wlst = []
Wlen = 100
Outputfile = "a.out"

# pmidsrageolistファイルを開く
# (pmid, sra) をキーとした、dictionaryを作って返す．要素は、[geo]
def makePRGdic(pmidsrageolist):
    prgdic = {}
    fo = open(pmidsrageolist, "r")
    lines = fo.readlines(BSIZE)
    while lines:
        for line in lines:
            cols = line[:-1].split("\t")
            if len(cols) != 3:
                print pmidsrageolist
                sys.stderr.write("makePRGdic: this line is something wrong.>%s\n"%(line))
                sys.exit()
            # 0.pmid, 1.sra, 2.geo
            k = (cols[0], cols[1])
            if k in prgdic:
                prgdic[k].append(cols[2])
            else:
                prgdic[k]= [cols[2]]
        lines = fo.readlines(BSIZE)
    fo.close()
    return prgdic

def fileoutput():
    fo = open(Outputfile, "a")
    fo.writelines(Wlst)
    del Wlst[:]
    fo.close()

# pmid2srafileを開いて、sra_id_origを、prgdicのキーとして引いて、geo idと置き換え, outputファイルに出力する
def merge_orig2geo(pmid2srafile, prgdic, output):
    fo = open(pmid2srafile, "r")
    lines = fo.readlines(BSIZE)
    while lines:
        for line in lines:
            cols = line[:-1].split("\t")
            if len(cols) != 14:
                sys.stderr.write("merge_orig2geo: this line is something wrong.>%s\n"%(line))
            # pmid, sra_id_orig
            k2 = (cols[0], cols[13])
            Wlst.append(line) # 元の行も出力
            # マージして出力
            if k2 in prgdic:
                for geoid in prgdic[k2]:
                    cols[13] = geoid
                    s = "\t".join(cols)
                    Wlst.append(s+"\n")
            if len(Wlst) > Wlen:
                fileoutput()
        lines = fo.readlines(BSIZE)
    fo.close()
    if Wlst != []:
        fileoutput()
    

def main(pmid2srafile,pmidsrageolist,output):
    global Outputfile
    Outputfile=output
    # ファイルが存在するかを調べる
    if os.path.exists(pmid2srafile) == False:
        sys.stderr.write("not found this file.>%s\n"%(pmid2srafile))
        sys.exit()
    if os.path.exists(pmidsrageolist) == False:
        sys.stderr.write("not found this file.>%s\n"%(pmidsrageolist))
        sys.exit()
    # pmidsrageolistを読んで、キーが(pmid,sra)、要素が[geo]のdictionalyを返す
    prgdic = makePRGdic(pmidsrageolist)
    # pmid2srafileを開いて、sra_id_origを、prgdicのキーとして引いて、geo idと置き換え, outputファイルに出力する
    merge_orig2geo(pmid2srafile, prgdic, output)


if __name__ == '__main__':
    args = sys.argv
    if len(args) != 4:
        sys.stdout.write("input err: [pmid2srafile] [GEO2PMID_PmidSraGeolist] [outputfile]\n")
    else:
        pmid2srafile=sys.argv[1]
        pmidsrageolist=sys.argv[2]
        output=sys.argv[3]
        main(pmid2srafile,pmidsrageolist,output)
