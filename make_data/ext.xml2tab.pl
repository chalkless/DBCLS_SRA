#!/usr/bin/perl

# ext.xml2tab.pl
# Nakazato T.
# '17-12-18-Mon.    Ver. 0.1
# '18-04-26-Thu.    Ver. 0.2
# '18-07-19-Thu.    Ver. 0.3

my ($dir, $date) = @ARGV;

$date = "9999-99-99" if $date eq "";


my $file_meta = "/share/data/sra_meta/Metadata/SRA_Accessions.tab";
open (META, $file_meta) or die $!;
while (defined ($line_meta = <META>)) {
    $line_meta =~ s/[\r\n]//g;

    @ele = split(/\t/, $line_meta);

    if ($ele[0] =~ /.RP\d+/) {
	my $id_study = $ele[0];
	my $update   = $ele[3];
	my $publish  = $ele[4];

	$update  =~ s/T\d{2}:\d{2}:\d{2}Z//;
	$publish =~ s/T\d{2}:\d{2}:\d{2}Z//;

	$id2date{$id_study} = $update;
	$id2publish{$id_study} = $publish;
    }
    elsif ($ele[0] =~ /.RX\d+/) {
	my $id_exp = $ele[0];
	my $publish  = $ele[4];
	my $id_study = $ele[12];

	$publish =~ s/T\d{2}:\d{2}:\d{2}Z//;

	$exp2study{$id_exp} = $id_study;
	$exp2publish{$id_exp} = $publish;
    }
}
close (META);


open(OUTSTUDY,  ">sra.study.out.tab") or die $!;
open(OUTEXP,    ">sra.exp.out.tab") or die $!;
open(OUTSAMPLE, ">sra.sample.out.tab") or die $!;
procdir($dir);
close(OUTSAMPLE);
close(OUTEXP);
close(OUTSTUDY);



sub procdir {
    my ($dir) = @_;

    chdir($dir);
    my @files = reverse(sort (glob("*")));
    foreach $file (@files) {
	if (-d $file) {
	    procdir($file);
	    chdir ("..") or die $!;
	}
	elsif (-f $file) {
	    if ($file =~ /study.xml/) {
		parseStudy($file);
	    }
	    elsif ($file =~ /experiment.xml/) {
		parseExp($file);
	    }
	    elsif ($file =~ /sample.xml/) {
		parseSample($file);
	    }
	}
    }
}


sub parseStudy {
    my ($file) = @_;

    my ($ra, $rp, $title, $type) = ("", "", "", "");

    $file =~ /([DES]RA\d+).study.xml/;
    $ra = $1;

    open (STUDY, $file) or die $!;
    while (defined ($line_study = <STUDY>)) {
	$line_study =~ s/[\r\n]//g;

	if (($line_study =~ /<RELATED_STUDIES>/) .. ($line_study =~ /<\/RELATED_STUDIES>/)) {
	    next;
	}
	elsif ($line_study =~ /^.*<STUDY_TITLE>(.*)<\/STUDY_TITLE>.*$/){
	    $title = $1;
	}
	elsif (($line_study =~ /<STUDY_TITLE>/) .. ($line_study =~ /<\/STUDY_TITLE>/)) {
	    $title_tmp .= " ".$line_study." ";
	    $title_tmp =~ s/^\s+//;
	    $title_tmp =~ s/\s+$//;
	    $title_tmp =~ s/\s+/ /;
	    $title_tmp =~ s/<(\/|)STUDY_TITLE>//g;
	    $title = $title_tmp;
	}
        elsif($line_study =~ /<STUDY .*accession=\"([DES]RP\d+)\".*>/) {
            $rp = $1;
	}
	elsif($line_study =~ /<STUDY_TYPE .*existing_study_type=\"([^"]*)\".*>/) {
	    $type = $1;
	}
	elsif($line_study =~ /<\/STUDY>/) {
	    my $update  = $id2date{$rp};
	    my $publish = $id2publish{$rp};
	    print join("\t", $publish, $date)."\n" if $debug == 2;
	   

	    print OUTSTUDY join("\t", $ra, $rp, $title, $type, $update)."\n" if $date gt $publish;

	    $rx = "";
	    $title = "";
	    $type = "";
	    $update = "";
	}
	
    }
    close(STUDY);
    $ra = "";
}

sub parseExp {
    my ($file) = @_;

    my ($ra, $rx, $title, $platform) = ("", "", "", "");

    $file =~ /([DES]RA\d+).experiment.xml/;
    $ra = $1;


    open(EXP, $file) or dir $!;
    while (defined ($line_exp = <EXP>)) {
	$line_exp =~ s/[\r\n]//g;

        if($line_exp =~ /^\s*<TITLE>(.*)<\/TITLE>\s*$/) {
            $title = $1;
        }
	elsif (($line_exp =~ /<TITLE>/) .. ($line_exp =~ /<\/TITLE>/)) {
	    $title .= " ".$line_exp." ";
	}
        elsif($line_exp =~ /<EXPERIMENT .*accession=\"([DES]RX\d+)\".*>/) {
            $rx = $1;

	    $rp = $exp2study{$rx};
	}
        elsif($line_exp =~ /<INSTRUMENT_MODEL>(.*)<\/INSTRUMENT_MODEL>/) {
            $platform = $1;
        }
	elsif($line_exp =~ /<\/EXPERIMENT>/) {

	    my $publish = $exp2publish{$rx};

	    $title =~ s/<(\/|)TITLE>//g;
	    $title =~ s/\t/\s/g;
	    $title =~ s/^\s+//;
	    $title =~ s/\s+$//;
	    $title =~ s/\s+/ /g;

	    print OUTEXP join("\t", $ra, $rp, $rx, $title, $platform)."\n" if $date gt $publish;

	    $rp = "";
	    $rx = "";
	    $title = "";
	    $platform = "";
	}
    }
    close(EXP);

    $ra = "";
}

sub parseSample {
    my ($file) = @_;

    my ($ra, $rs, $name, $title, $desc, $taxon_id) = ("", "", "", "", "", "");

    $file =~ /([DES]RA\d+).sample.xml/;
    $ra = $1;

    open (SAMPLE, $file) or die $!;
    while (defined ($line_sample = <SAMPLE>)) {
	$line_sample =~ s/[\r\n]//;

        if($line_sample =~ /^\s*<TITLE>(.*)<\/TITLE>\s*$/) {
            $title = $1;
        }
	elsif (($line_sample =~ /<TITLE>/) .. ($line_sample =~ /<\/TITLE>/)) {
	    $title_tmp .= " ".$line_sample." ";
	    $title_tmp =~ s/^\s+//;
	    $title_tmp =~ s/\s+$//;
	    $title_tmp =~ s/\s+/ /;
	    $title_tmp =~ s/<(\/|)TITLE>//g;
	    $title = $title_tmp;
	}
        elsif($line_sample =~ /^\s*<DESCRIPTION>(.*)<\/DESCRIPTION>\s*$/) {
            $desc = $1;
        }
	elsif (($line_sample =~ /<DESCRIPTION>/) .. ($line_sample =~ /<\/DESCRIPTION>/)) {
	    $desc_tmp .= " ".$line_sample." ";
	    $desc_tmp =~ s/^\s+//;
	    $desc_tmp =~ s/\s+$//;
	    $desc_tmp =~ s/\s+/ /;
	    $desc_tmp =~ s/<(\/|)TITLE>//g;
	    $desc = $desc_tmp;
	}
	elsif ($line_sample =~ /<SAMPLE .*accession=\"([DES]RS\d+)\".*>/) {
	    $rs = $1;
	}
	elsif ($line_sample =~ /<TAXON_ID>(.*)<\/TAXON_ID>/) {
	    $taxon_id = $1;
	}
	elsif ($line_sample =~ /<SCIENTIFIC_NAME>(.*)<\/SCIENTIFIC_NAME>/) {
	    $name = $1;
	}
	elsif ($line_sample =~ /<\/SAMPLE>/) {
	    print OUTSAMPLE join("\t", $ra, $rs, $name, $title, $desc, $taxon_id)."\n";
	    
	    ($rs, $name, $title, $desc, $taxon_id) = ("", "", "", "", "");
	}
    }
    close (SAMPLE);

    $ra = "";
}
