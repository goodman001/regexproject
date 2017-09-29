#!/usr/bin/perl -w
# written by andrewt@cse.unsw.edu.au as a COMP2041 lecture example
# Count the number of lines on standard input.



while (1){
last if eof STDIN;
push @lines, scalar <STDIN>;
}
$line_count = @lines;
print "$line_count lines \n";
