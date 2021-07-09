#!/usr/bin/perl

use strict;
use DBI;

package relationParser;

sub new {
    print "RELATION PARSER\n";
    my $pkg = shift;
    bless {
	dbh => shift,
    },$pkg;

}


sub parse {
    my $self = shift;
    my $filename = shift;

    my %studyexp;
    my %studysample;
    my %expsample;
    my %exprun;
    
    open(IN,$filename) or die;
    while(<IN>) {
	chomp;
	my @line = split("\t",$_);
	
#    print $line[5]."\n";
	
#    next;
	
	#Study:Exp
	
	if($line[1] ne "-" and $line[2] ne "-") {
	    my $index =  $line[0].":".$line[1].":".$line[2];
	    $studyexp{$index} = 1;
	    print $index."\n";
	}
	
	#Study:Exp_ref
	if($line[1] ne "-" and $line[7] ne "-") {
	    my $index =  $line[0].":".$line[1].":".$line[7];
	    $studyexp{$index} = 1;
	    print $index."\n";
	}
	
	
	#Study_ref:Exp
	if($line[6] ne "-" and $line[2] ne "-") {
	    my $index =  $line[0].":".$line[6].":".$line[2];
	    $studyexp{$index} = 1;
	    print $index."\n";
	}
	
	#Study_ref:Exp_ref
	if($line[6] ne "-" and $line[7] ne "-") {
	    my $index =  $line[0].":".$line[6].":".$line[7];
	    $studyexp{$index} = 1;
	    print $index."\n";
	}
	
	
	##########################################
	
	#Study:Sample
	if($line[1] ne "-" and $line[4] ne "-") {
	    my $index =  $line[0].":".$line[1].":".$line[4];
	    $studysample{$index} = 1;
	    print $index."\n";
	}
	
    #Study:Sample_ref
	if($line[1] ne "-" and $line[8] ne "-") {
	    my $index =  $line[0].":".$line[1].":".$line[8];
	    $studysample{$index} = 1;
	    print $index."\n";
	}
	
	
	#Study_ref:Sample
	if($line[6] ne "-" and $line[4] ne "-") {
	    my $index =  $line[0].":".$line[6].":".$line[4];
	    $studysample{$index} = 1;
	    print $index."\n";
	}
	
	#Study_ref:Sample_ref
	if($line[6] ne "-" and $line[8] ne "-") {
	    my $index =  $line[0].":".$line[6].":".$line[8];
	    $studysample{$index} = 1;
	    print $index."\n";
	}
	
	
	##########################################
	
    #Exp:Sample
	if($line[2] ne "-" and $line[4] ne "-") {
	    my $index =  $line[0].":".$line[2].":".$line[4];
	    $expsample{$index} = 1;
	    print $index."\n";
	}

	#Exp:Sample_ref
	if($line[2] ne "-" and $line[8] ne "-") {
	    my $index =  $line[0].":".$line[2].":".$line[8];
	    $expsample{$index} = 1;
	    print $index."\n";
	}
	
	#Exp_ref:Sample
	if($line[7] ne "-" and $line[4] ne "-") {
	    my $index =  $line[0].":".$line[7].":".$line[4];
	    $expsample{$index} = 1;
	    print $index."\n";
	}
	
	#Exp_ref:Sample_ref
	if($line[7] ne "-" and $line[8] ne "-") {
	    my $index =  $line[0].":".$line[7].":".$line[8];
	    $expsample{$index} = 1;
	    print $index."\n";
	}
	
	##########################################
	
	#Exp:Run
	if($line[2] ne "-" and $line[3] ne "-") {
	    my $index =  $line[0].":".$line[2].":".$line[3];
	    $exprun{$index} = 1;
	    print $index."\n";
	}
	
	#Exp_ref:Run
	if($line[7] ne "-" and $line[3] ne "-") {
	    my $index =  $line[0].":".$line[7].":".$line[3];
	    $exprun{$index} = 1;
	    print $index."\n";
	}
	
    }
    close(IN);
    
    $self->insertStudyExp(\%studyexp);
    $self->insertStudySample(\%studysample);
    $self->insertExpSample(\%expsample);
    $self->insertExpRun(\%exprun);
}

sub insertStudyExp() {
    my $self = shift;
    my $ref = shift;
    my $dbh = $self->{dbh};

    foreach my $i (sort keys %{$ref}) {
	my ($a,$b,$c) = split(":",$i);
	$a = $dbh->quote($a);
	$b = $dbh->quote($b);
	$c = $dbh->quote($c);

	my $query = "INSERT INTO study_expWK(RA,RP,RX) VALUES(".$a.",".$b.",".$c.");";
	print $query."\n";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	$sth->finish;
    }

}

sub insertStudySample() {
    my $self = shift;
    my $ref = shift;
    my $dbh = $self->{dbh};

    foreach my $i (sort keys %{$ref}) {
	my ($a,$b,$c) = split(":",$i);
	$a = $dbh->quote($a);
	$b = $dbh->quote($b);
	$c = $dbh->quote($c);

	my $query = "INSERT INTO study_sampleWK(RA,RP,RS) VALUES(".$a.",".$b.",".$c.");";
	print $query."\n";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	$sth->finish;
    }

}


sub insertExpSample() {
    my $self = shift;
    my $ref = shift;
    my $dbh = $self->{dbh};


    foreach my $i (sort keys %{$ref}) {
	my ($a,$b,$c) = split(":",$i);
	$a = $dbh->quote($a);
	$b = $dbh->quote($b);
	$c = $dbh->quote($c);

	my $query = "INSERT INTO exp_sampleWK(RA,RX,RS) VALUES(".$a.",".$b.",".$c.");";
	print $query."\n";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	$sth->finish;
    }

}

sub insertExpRun() {
    my $self = shift;
    my $ref = shift;
    my $dbh = $self->{dbh};

    foreach my $i (sort keys %{$ref}) {
	my ($a,$b,$c) = split(":",$i);
	$a = $dbh->quote($a);
	$b = $dbh->quote($b);
	$c = $dbh->quote($c);

	my $query = "INSERT INTO exp_runWK(RA,RX,RR) VALUES(".$a.",".$b.",".$c.");";
	print $query."\n";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	$sth->finish;
    }

}

1;
