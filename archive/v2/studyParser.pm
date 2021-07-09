#!/usr/bin/perl


use strict;
use DBI;

package studyParser;

sub new {
    my $pkg = shift;
    bless {
	dbh => shift,
    },$pkg;

}


sub parse {
    my $self = shift;
    my $topdir = shift;

    print "StuDY PARSER:TOPDIR=".$topdir."\n";

    open(FILENAME,"find $topdir -name *.study.xml -print |") or die;
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
    print $filename."\n";

    my ($ra,$rp,$title,$type,$date);
    $ra = "";
    $rp = "";
    $title = "";
    $type = "";

    $filename =~ /.*\/(.+).study.xml/;
    $ra = $1;

    my $mode = "";

    open(IN,$filename) or die;
    while(<IN>) {
	chomp;
	#print $_."\n";

	if(/^(.*)<RELATED_STUDIES>$/) {
	    $mode = "RELATED_STUDIES";
	}
	if(/^(.*)<\/RELATED_STUDIES>$/) {
	    $mode = "";
	}
	if ($mode eq "RELATED_STUDIES") {
	    next;
	}

	if ($mode eq "STUDY_TITLE") {
	    print "MODE IN\n";
	    if(/^(.*)<\/STUDY_TITLE>$/) {
		#print $1."\n";
		$title .= " ".$1;
		$mode = "";
	    } elsif(/^\s*(\S.*)\s*$/) {
		$title .= " ".$1;
	    }
	    next;
	}

	if(/^\s*<STUDY .*accession=\"([^\"]*)\"[^>]*>$/) {
	    #print $1."\n";
	    $rp = $1;
	    next;
	}

	if(/^\s*<STUDY_TITLE>(.*)<\/STUDY_TITLE>$/) {
	    #print $1."\n";
	    print "TEST:".$1."\n";
	    $title = $1;
	    next;
	}

	if(/^\s*<STUDY_TITLE>(.*)\s*$/) {
	    $mode = "STUDY_TITLE";
	    #print $1."\n";
	    print "TEST:".$1."\n";
	    $title = $1;
	    next;
	}
	
	if(/^\s*<STUDY_TYPE .*existing_study_type=\"([^\"]*)\"[^\/]*\/>$/) {
	    #print $1."\n";
	    $type = $1;
	    next;
	}

	if(/^\s*<\/STUDY>$/) {
	    print "**********************MATCH='".$_."'".$filename."********************\n";
	    $date = $self->getDate($rp,$ra);	    
	    $self->insert($ra,$rp,$title,$type,$date);

	    $rp = "";
	    $title = "";
	    $type = "";
	    next;
	}

    }
    close(IN);
}

sub getDate() {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $rp = shift;
    my $ra = shift;
    my $query = "SELECT MAX(submissionWK.UPDATE_DATE) as last FROM study_sampleWK,sampleWK,submissionWK WHERE study_sampleWK.RP='".$rp."' and study_sampleWK.RS = sampleWK.RS and sampleWK.RA = submissionWK.RA;";
    print $query."\n";
    my $sth = $dbh->prepare($query);
    $sth->execute();

    my $ret = $sth->fetchrow_hashref();

#    while(my $ref = $sth->fetchrow_hashref()) {
#	print $ref->{'last'}."\n";
#    }
    
    $sth->finish;

    print $ret->{'last'}."\n";

    if ($ret->{'last'} == undef) {
	my $query = "SELECT UPDATE_DATE as last FROM submissionWK WHERE RA='".$ra."';";
	print $query."\n";
	my $sth = $dbh->prepare($query);
	$sth->execute();

	$ret = $sth->fetchrow_hashref();
    
	$sth->finish;

	print "DEFAULT:".$ret->{'last'}."\n";

    }

    return $ret->{'last'};

}



sub insert {

    my $self = shift;
    my $dbh = $self->{dbh};
    my $ra = $dbh->quote(shift);
    my $rp = $dbh->quote(shift);
    my $title = $dbh->quote(shift);
    my $type = $dbh->quote(shift);
    my $date = $dbh->quote(shift);

    eval {
	my $query = "INSERT INTO studyWK(RA,RP,STUDY_TITLE,STUDY_TYPE,UPDATE_DATE) values(".$ra.",".$rp.",".$title.",".$type.",".$date.");";
	print $query ."\n";
	my $sth = $dbh->prepare($query);
	
	$sth->execute;
	
	$sth->finish;
    };

    if($@) {
	print "ERROR:$@\n";
    }



} 

1;
