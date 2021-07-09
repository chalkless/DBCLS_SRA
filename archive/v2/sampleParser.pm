#!/usr/bin/perl


use strict;
use DBI;

package sampleParser;

sub new {
    my $pkg = shift;
    bless {
	dbh => shift,
    },$pkg;

}

sub parse {
    my $self = shift;
    my $topdir = shift;

    print "SAMPLE PARSER:TOPDIR=".$topdir."\n";

    open(FILENAME,"find $topdir -name *.sample.xml -print |") or die;
    while(<FILENAME>) {
	chomp;
#    print $_ ."\n";
	$self->process1file($_);
    }
    close(FILE);
    return 1;
}

sub process1file {
    my $self = shift;
    my $filename = shift;
    #print $filename."\n";

    my ($ra,$rs,$commonname,$title,$description,$taxon_id);
    $ra = undef;
    $rs = undef;
    $commonname = undef;
    $title = undef;
    $description = undef;
    $taxon_id = undef;

    my $mode = "";
    $filename =~ /.*\/(.+).sample.xml/;
    $ra = $1;

    open(IN,$filename) or die;
    while(<IN>) {
	chomp;
	#print $_."\n";

#	if(/^\s*<TITLE\/>\s*$/) {
#	    #print $1."\n";
#	    $title = "&lt;NO TITLE&gt;";
#	    print $ra."\n";
#	    next;
#	}

#	if(/^\s*<DESCRIPTION\/>\s*$/) {
#	    #print $1."\n";
#	    $description = "&lt;NO DESCRIPTION&gt;";
#	    #print $ra."\n";
#	    next;
#	}

	if($mode eq "TITLE") {
	    if(/^\s*(.*)<\/TITLE>$/) {
		#print $1."\n";
		$title .= " ".$1;
		$mode = "";
		next;
	    } elsif(/^\s*(.*)\s*$/) {
		$title .= " ".$1;
	    }
	    next;
	}

	if($mode eq "DESCRIPTION") {
	    if(/^\s*(.*)<\/DESCRIPTION>$/) {
		#print $1."\n";
		$description .= " ".$1;
		$mode = "";
		next;
	    } elsif(/^\s*(.*)\s*$/) {
		$description .= " ".$1;
	    }
	    next;
	}

	if(/^\s*<SAMPLE .*accession=\"([^\"]*)\"[^>]*>$/) {
	    #print $1."\n";
	    $rs = $1;

	    next;
	}

	if(/^\s*<COMMON_NAME>\s*\"?(.*)\"?\s*<\/COMMON_NAME>$/) {
	    #print $1."\n";
	    $commonname = $1;

	    next;
	}

#	if(/^\s*<TAXON_ID/) {
#	    print $_."\n";
#	}

	if(/^\s*<TAXON_ID>(.*)<\/TAXON_ID>$/) {
	    #print $1."\n";
	    $taxon_id = $1;

	    next;
	}

	if(/^\s*<TITLE>(.*)<\/TITLE>\s*$/) {
	    #print $1."\n";
	    $title = $1;

	    next;
	}

	if(/^\s*<TITLE>(.*)\s*$/) {
	    $mode = "TITLE";
	    #print $1."\n";
	    $title .= $1;

	    next;
	}

	if(/^\s*<DESCRIPTION>(.*)<\/DESCRIPTION>\s*$/) {
	    #print $1."\n";
	    $description = $1;

	    next;
	}

	if(/^\s*<DESCRIPTION>(.*)\s*$/) {
	    $mode = "DESCRIPTION";
	    #print $1."\n";
	    $description .= $1;

	    next;
	}
	
	if(/^\s*<\/SAMPLE>$/) {

#	    if(not defined($title) and not defined($description)) {
#		print $ra.":".$rs."\n";
#	    }

	    $self->insert($ra,$rs,$commonname,$title,$description,$taxon_id);

	    $rs = undef;
	    $commonname = undef;
	    $title = undef;
	    $description = undef;
	    $taxon_id = undef;

	    next;
	}

    }
    close(IN);
}

sub insert() {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $ra = $dbh->quote(shift);
    my $rx = $dbh->quote(shift);
    my $commonname = $dbh->quote(shift);
    my $title = $dbh->quote(shift);
    my $description = $dbh->quote(shift);
    my $taxon_id = $dbh->quote(shift);


    my $query = "INSERT INTO sampleWK(RA,RS,COMMON_NAME,TITLE,DESCRIPTION,TAXON_ID) values(".$ra.",".$rx.",".$commonname.",".$title.",".$description.",".$taxon_id.");";
    print $query ."\n";
    my $sth = $dbh->prepare($query);

    $sth->execute;

    $sth->finish;





} 

1;
