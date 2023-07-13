#!/usr/local/bin/perl
use warnings;
use strict;
use Getopt::Long; 

use lib '.';
use PerlPluMA;
use PerlIO;

my ($inputfilename1,$inputfilename2 ,$outputfilename, $base,$col, $delim,$delim2,$printdelim, $printCols,$headerRowFile1,$headerRowFile2,$headerRowFile1toPrint,$term); 
my %params;

sub input {
  %params = PerlIO::readParameters(@_[0]);
$inputfilename1=PerlPluMA::prefix."/".$params{"inputfile"};
$inputfilename2=PerlPluMA::prefix."/".$params{"database"};
#$outputfilename=$;
#$col=$ARGV[2];
$delim=$params{"delim1"};
$delim2=$params{"delim2"};
$printdelim=$params{"printdelim"};
$headerRowFile1=$params{"headerRowFile1"};
$headerRowFile2=$params{"headerRowFile2"};
$headerRowFile1toPrint=$params{"headerRowFile1toPrint"};
}

sub run {}

sub output {
$outputfilename = @_[0];
#if(@ARGV<6){
#	die "Usage: perl GetTaxonomyforOTUIDs.pl biom_tsv_file GreenGenesfile outputfilename delim1 delim2 printdelim headerRowFile1 headerRowFile2 headerRowFile1toPrint(delims:tab/comma/semicolon/space/pipe)\n";
#}
# perl GetTaxonomyforOTUIDs.pl otu_table_Georgetown_complete.biom.txt gg_13_8_99.gg.tax Casero_Cheema.results.biom.txt tab tab tab 2 0 2
# perl GetTaxonomyforOTUIDs.pl test.biom.txt gg_13_8_99.gg.tax output.txt tab tab tab 2 0 2

#GetOptions( 'input=s' => \$inputfilename ,
#	   'output=s' => \$outputfilename,
#	   'col=i'=>\$col,
#	   'delimiter=s'=> \$delim,
#	   'hasHeader=i'=> \$hasHeader);
#
#print "Unprocessed by Getopt::Long\n" if $ARGV[0]; foreach (@ARGV) { print "$_\n"; }
#if ($ARGV[0]) {exit()};


open (INFILE1, $inputfilename1 )|| die "Can't open $inputfilename1 \n";
open (INFILE2, $inputfilename2 )|| die "Can't open $inputfilename2 \n";

open (OUTFILE, ">$outputfilename")|| die "Can't open $outputfilename\n";

print "Delims: $delim, $delim2, $printdelim\n";

$delim=mydelim($delim,0);
$delim2=mydelim($delim2,0);
$printdelim=mydelim($printdelim,1);
print "Delims: $delim, $delim2, $printdelim\n";

$col=$col;

my $ct=0;
my $termct=0;


my @lines = <INFILE2>;# Taxonomy
splice @lines, 0, $headerRowFile2; # remove header
close (INFILE2);


my %hash;
my $extractCol=1;
my @tokens;

while (<INFILE1>) { #Biom File with OTU ID
	if($ct<$headerRowFile1){
		if($ct == $headerRowFile1toPrint){
			
			print OUTFILE $_;
		}
                else {
		}
		$ct++;
		next;
	}
	else{
		@tokens=split(/$delim/,$_);
		my $OTUID1=$tokens[0]; # OTU ID
		splice @tokens, 0, 1; # remove first col
		#$OTUID =~ s/^\s+|\s+$//g;# trim left right
		my $row=0;
		for (@lines) { # Taxonomy
			$row++;
			my @tokens2=split(/$delim2/,$_);
			my $OTUID2=$tokens2[0];
			my $term2=$tokens2[$extractCol]; # Bacteria term
			if($OTUID1 eq $OTUID2){

				$termct++;
				chomp $term2;
				print "Matched $OTUID1 at row $ct\n";
				print OUTFILE $term2.$printdelim;
				print OUTFILE join($printdelim, @tokens) ;

			
			}
		}

		$ct++;
	}


}

$ct--;
print "count $ct\n";
print "term count $termct\n";
close (INFILE1);

close (OUTFILE);
}

 sub mydelim {
my($delim1, $opt) = @_;
my $printdelim1;
if($delim1 eq "tab"){
	$delim1='\t';
	$printdelim1="\t";
}
elsif($delim1 eq "comma"){
	$delim1='\,';
	$printdelim1=",";
}
elsif($delim1 eq "semicolon"){
	$delim1='\;';
	$printdelim1=";";
}
elsif($delim1 eq "pipe"){
	$delim1='\|';
	$printdelim1="\|";
}
elsif($delim1 eq "space"){
	$delim1=" ";
	$printdelim1=$delim;
}else{
	$delim1="-";#detect flag
}
if($opt==1){
	$delim1=$printdelim1;
}

return $delim1;

}

