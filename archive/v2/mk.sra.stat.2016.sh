#!/bin/bash

PERLBREW_ROOT=/share/pkgs/perlbrew
source /share/pkgs/perlbrew/etc/bashrc

cd /share/work/sra/

now=`date +%y%m%d%H%M`

echo "mk.stat.pl"
perl mk.sra.stat.2.pl

echo "pre.tab"
for nm in sra.stat.*.pre.tab; do
    cp $nm ${nm%tab}$now.tab
done

echo "type"
cp sra.stat.type.pre.$now.tab sra.stat.type.pre.tab
perl -F"\t" -lane 'if ($F[3] ne "") { print join("\t", $F[0], $F[1], $F[3], $F[2]) } else { print join("\t", $F[0], $F[1], "UNKNOWN", $F[2])}' sra.stat.plat.pre.$now.tab > sra.stat.plat.pre.tab
perl mk.sra.stat.taxon.comp.2.pl sra.stat.taxon.pre.$now.tab > sra.stat.taxon.pre.tab

echo "uniq"
for nm in sra.stat.*.pre.tab; do
    perl -F"\t" -lane 'print join("\t", $F[1], $F[2])' $nm | sort | uniq > ${nm%pre.tab}sort.tab
    perl -F"\t" -lane 'print $F[1]' ${nm%pre.tab}sort.tab | sort | uniq -c | sort -rn > ${nm%pre.tab}uniq.tab
done

head -15 sra.stat.taxon.uniq.tab > sra.stat.taxon.uniq.top.tab
taxoncount=`wc -l sra.stat.taxon.sort.tab`


perl -F"\t" -lane 'print join("\t", $F[3], $F[2])' sra.stat.plat.pre.tab | sort | uniq | perl -F"\t" -lane 'print $F[1]' | sort | uniq -c | sort -rn > sra.stat.plat.exp.uniq.tab

perl -F"\t" -lane 'print join("\t", $F[3], $F[2], $F[4])' sra.stat.taxon.pre.tab | sort | uniq > sra.stat.taxon.sample.sort.tab
perl -F"\t" -lane 'print $F[1]' sra.stat.taxon.sample.sort.tab | sort | uniq -c | sort -rn > sra.stat.taxon.sample.uniq.tab

head -15 sra.stat.taxon.sample.uniq.tab > sra.stat.taxon.sample.uniq.top.tab
taxonsamplecount=`wc -l < sra.stat.taxon.sample.sort.tab`

### Type
perl sort2table.pl sra.stat.type.uniq.tab -url "cgi-bin/studylist.cgi?type=" > sra.stat.type.sort.html
perl sort2json.pl -l type sra.stat.type.uniq.tab > sra.type.latest.json
perl sort2tab.pl -l type sra.stat.type.uniq.tab > sra.type.latest.tab

### Platform (study)
perl sort2table.pl sra.stat.plat.uniq.tab -url "cgi-bin/studylist.cgi?platform=" > sra.stat.plat.sort.html
perl sort2table.pl sra.stat.taxon.uniq.top.tab -url "cgi-bin/studylist.cgi?scientific_name=" -total $taxoncount > sra.stat.taxon.sort.html


perl sort2table.pl sra.stat.plat.exp.uniq.tab -url "cgi-bin/experimentlist.cgi?platform=" > sra.stat.plat.exp.sort.html
perl sort2table.pl sra.stat.taxon.sample.uniq.top.tab -url "cgi-bin/experimentlist.cgi?scientific_name=" -total $taxonsamplecount > sra.stat.taxon.sample.sort.html
perl sort2json.pl -l platform sra.stat.plat.exp.uniq.tab > sra.platform.latest.json
perl sort2tab.pl -l platform sra.stat.plat.exp.uniq.tab > sra.platform.latest.tab
echo $taxonsamplecount
perl sort2json.pl -l taxon -total $taxonsamplecount sra.stat.taxon.sample.uniq.top.tab > sra.taxon.latest.json
perl sort2tab.pl -l taxon -total $taxonsamplecount sra.stat.taxon.sample.uniq.top.tab > sra.taxon.latest.tab

cp *.json /share/srv/www/sra_v2/
cp *.latest.tab /share/srv/www/sra_v2/

perl tmpl2html.pl > index.pre.$now.html
perl taxonDecoration.pl index.pre.$now.html > index.$now.html

if [ -s index.$now.html ];
then
    cp index.$now.html /share/srv/www/sra_v1/index.html
fi

mkdir update_stat/$now
mv *.tab update_stat/$now
mv *.html update_stat/$now
mv *.json update_stat/$now

cp update_stat/$now/index.tmpl.html ./
cp update_stat/$now/taxon.id2name.tab ./

