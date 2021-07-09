#!/usr/bin/perl

# mk.idTable.sra.3.pl
# Nakazato T.
# '10-06-07-Mon.    Ver. 0


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
	    chdir ("..") or die $!;
	}
	elsif (-f $file) {
	    if ($file =~ /xml$/) {
		$file =~ /(.RA\d{6}).(.*?).xml/;

		$submission = $1;
		$type = $2;

		open (IN, $file) or die $!;
		while (defined ($line_in = <IN>)) {
		    $line_in =~ s/[\r\n]//g;

#                   # from Submission
#		    if ($line_in =~ /\<SUBMISSION.*accession="(.RA\d{6})"/) {
#			$submission = $1;
#		    }

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
			push @exps, $exp_tmp;
		    }

		    # from Analysis
		    if ($line_in =~ /\<ANALYSIS .*accession="(.RZ\d{6})"/) {
			$analysis_tmp = $1;
			push @analyses, $analysis_tmp;
		    }

		    
		    if ($line_in =~ /\<EXPERIMENT_REF .*accession="(.RX\d{6})"/) {
			$exp_ref_tmp = $1;
			push @exps_ref, $exp_ref_tmp;
		    }
		    elsif ($line_in =~ /\<SAMPLE_DESCRIPTOR .*accession="(.RS\d{6})"/) {
			$sample_ref_tmp = $1;
			push @samples_ref, $sample_ref_tmp;
		    }

		    if ($line_in =~ /\<STUDY_REF .*accession="(.RP\d{6})"/) {
			$study_ref_tmp = $1;
			push @studies_ref, $study_ref_tmp;
		    }

		    if ($line_in =~ /\<TARGET .*accession="(.RX\d{6})"/) {
			$exp_ref_tmp = $1;
			push @exps_ref, $exp_ref_tmp;
		    }

		    if ($line_in =~ /\<\/(STUDY|EXPERIMENT|RUN|SAMPLE|ANALYSIS)\>/) {
			$study_out = join("\|", @studies);
			$exp_out = join("\|", @exps);
			$run_out = join("\|", @runs);
			$sample_out = join("\|", @samples);
			$analysis_out = join("\|", @analyses);

			$study_ref_out = join("\|", @studies_ref);
			$exp_ref_out = join("\|", @exps_ref);
			$sample_ref_out = join("\|", @samples_ref);

			$study_out = "-" if $study_out eq "";
			$exp_out = "-" if $exp_out eq "";
			$run_out = "-" if $run_out eq "";
			$analysis_out = "-" if $analysis_out eq "";
			$sample_out = "-" if $sample_out eq "";
			$study_ref_out = "-" if $study_ref_out eq "";
			$exp_ref_out = "-" if $exp_ref_out eq "";
			$sample_ref_out = "-" if $sample_ref_out eq "";

#			print $line_in."\n";
			print join("\t", $submission, $study_out, $exp_out, $run_out, $sample_out, $analysis_out, $study_ref_out, $exp_ref_out, $sample_ref_out)."\n";

			undef @studies;
			undef @exps;
			undef @runs;
			undef @samples;
			undef @analyses;
			undef @studies_ref;
			undef @exps_ref;
			undef @samples_ref;
		    }
		}
		close (IN);
	    }
	}


    }

}


