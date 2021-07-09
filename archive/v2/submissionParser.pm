#!/usr/bin/perl

use strict;
use DBI;

package submissionParser;

sub new {
    my $pkg = shift;
    bless {
	dbh => shift,
    },$pkg;

}

sub parse {
    my $self = shift;
    my $topdir = shift;

    print "SUBMISSION PARSER : TOPDIR=".$topdir."\n";



    open(FILENAME,"find $topdir -name *.submission.xml -print |") or die;
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

    my ($ra,$date);
    $filename =~ /.*\/(.+).submission.xml/;
    $ra = $1;

    open(IN,$filename) or die;
    while(<IN>) {
	chomp;
	print $_."\n";
	if(/^\s*<SUBMISSION.* submission_date=\"([^\"]*)\".*>$/) {
	    #print $ra." ".$1."\n";
	    $self->insert($ra,$1);
	}
    }
    close(IN);
}

sub insert() {
    my $self = shift;
    my $ra = shift;
    my $submission_date = shift;
    my $dbh = $self->{dbh};

    my $query = "INSERT INTO submissionWK(RA,UPDATE_DATE) values('".$ra."','".$submission_date."');";
    print $query ."\n";
    my $sth = $dbh->prepare($query);

    $sth->execute;

    $sth->finish;



} 

1;
