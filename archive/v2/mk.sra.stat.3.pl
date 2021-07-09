#!/usr/bin/perl

# mk.sra.stat.3.pl
# Nakazato T.
# '18-04-26-Thu.    Ver.0.1

$debug = 1;

open (STUDY_IN, "sra.study.out.tab") or die $!;
open (STUDY_OUT, ">sra.stat.type.pre.tab") or die $!;

while (defined ($line_study = <STUDY_IN>)) {
    $line_study =~ s/[\r\n]//g;

    @ele_study = split(/\t/, $line_study);

    print STUDY_OUT join("\t", $ele_study[0], $ele_study[1], $ele_study[3])."\n";
}

close (STUDY_OUT);
close (STUDY_IN);

open (EXP_IN, "sra.exp.out.tab") or die $!;
open (EXP_OUT, ">sra.stat.plat.pre.tab") or die $!;

while (defined ($line_exp = <EXP_IN>)) {
    $line_exp =~ s/[\r\n]//g;

    @ele_exp = split(/\t/, $line_exp);
    splice(@ele_exp, 3,1);

    print EXP_OUT join("\t", @ele_exp)."\n"; 
}

close (EXP_OUT);
close (EXP_IN);


