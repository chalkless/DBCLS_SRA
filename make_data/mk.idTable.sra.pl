#!/usr/bin/perl

# mk.idTable.sra.pl
# Nakazato T.
# '10-06-07-Mon.    Ver. 0
# '14-05-02-Fri.    Ver. 0.1    refine


$debug = 1;

my $dir = shift @ARGV;
procdir($dir);


sub procdir {
    my ($dir) = @_;

    chdir($dir);
    my @files = reverse(sort (glob("*")));

    foreach $file (@files) {
	if (-d $file) {
	    procdir($file);
	    chdir("..") or die $!;
	}
	elsif (-f $file) {
	    if ($file =~ /xml$/) {
		$file = /(.RA\d{6}).(.*?).xml/;
		
		$submission = $1;
		$type = $2;

		open (IN, $file) or die $!;

                while (defined ($line_in = <IN>)) {
                    $line_in =~ s/[\r\n]//g;

		    ### extracting self ID

#                   # from Submission
#                   if ($line_in =~ /\<SUBMISSION.*accession="(.RA\d{6})"/) {
#                       $submission = $1;
#                   }

                    # from Study
                    if ($line_in =~ /\<STUDY .*accession="(.RP\d{6})"/) {
                        $study_tmp = $1;
                        push @studies, $study_tmp;
                    }

                    # from Sample
                    if ($line_in =~ /\<SAMPLE .*accession="(.RS\d{6})"/) {
                        $sample_tmp = $1;
                        push @samples, $sample_tmp;
                    }

                    # from Run
                    if ($line_in =~ /\<RUN .*accession="(.RR\d{6})"/) {
                        $run_tmp = $1;
                        push @runs, $run_tmp;
                    }
                    # from Experiment
                    if ($line_in =~ /\<EXPERIMENT .*accession="(.RX\d{6})"/) {
                        $exp_tmp = $1;
                        push @exps, $exp_tmp;                    }

                    # from Analysis
                    if ($line_in =~ /\<ANALYSIS .*accession="(.RZ\d{6})"/) {
                        $analysis_tmp = $1;
                        push @analyses, $analysis_tmp;
                    }


		    ### extracting link ID





		close (IN);
	    }
	}
    }

}















