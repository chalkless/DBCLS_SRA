#!/usr/bin/perl


use strict;
use DBI;

package experimentParser;

sub new {
    my $pkg = shift;
    bless {
	dbh => shift,
    },$pkg;

}

sub parse {
    my $self = shift;
    my $topdir = shift;

    print "TOPDIR=".$topdir."\n";

    my $count=0;

    open(FILENAME,"find $topdir -name *.experiment.xml -print |") or die;
    while(<FILENAME>) {
	chomp;
#    print $_ ."\n";
	$self->process1file($_);
    }
    close(FILE);
    
    return 1;

}

sub process1file() {
    my $self = shift;
    my $filename = shift;
    print $filename."\n";

    my ($ra,$rx,$title,$platform);
    $ra = "";
    $rx = "";
    $title = "";
    $platform = "";

    $filename =~ /.*\/(.+).experiment.xml/;
    $ra = $1;

    my $mode = "";

    open(IN,$filename) or die;
    while(<IN>) {
	chomp;
	#print $_."\n";

	if($mode eq "TITLE") {
	    if(/^\s*(.*)<\/TITLE>$/) {
		$mode = "";
		#print $1."\n";
		$title .= " ".$1;
		next;
	    } elsif(/^\s*(.*)\s*$/) {
		#print $1."\n";
		$title .= " ".$1;
		next;
	    }
	}

	if(/^\s*<EXPERIMENT .*accession=\"([^\"]*)\"[^>]*>$/) {
	    #print $1."\n";
	    $rx = $1;
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
	    $title = $1;
	    next;
	}

#	if(/^\s*<TITLE\/>\s*$/) {
#	    #print $1."\n";
#	    $count++;
#	    $title = "&lt;NO DATA&gt;";
#	    next;
#	}

	if(/^\s*<INSTRUMENT_MODEL>(.*)<\/INSTRUMENT_MODEL>$/) {
	    #print $1."\n";
	    $platform = $1;
	    next;
	}
	
	if(/^\s*<\/EXPERIMENT>$/) {

	    $self->insert($ra,$rx,$title,$platform);

	    $rx = "";
	    $title = "";
	    $platform = "";
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
    my $title = $dbh->quote(shift);
    my $platform = $dbh->quote(shift);

    my $query = "INSERT INTO experimentWK(RA,RX,TITLE,PLATFORM) values(".$ra.",".$rx.",".$title.",".$platform.");";
    print $query ."\n";
    my $sth = $dbh->prepare($query);

    $sth->execute;

    $sth->finish;




} 


1;
