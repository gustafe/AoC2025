#!/usr/bin/perl
use strict;
use warnings;
my $year = 2025;
my $day = shift @ARGV;
my $title ;
if (@ARGV) {
    $title = join(' ',@ARGV);
} else {
    $title = '<TITLE>';
}


die "what day is this: $day ?" unless ( $day =~ m/\d+/ and ( $day >= 1 and $day <= 25 ));
my $marker = sprintf("d%02d",$day);
my $filename =$title =~ s/\s+/\-/gr;
print join('-', "$marker", "$filename.pl"),"\n";
my $marker_1 = $marker.'_1'; my $marker_2 = $marker.'_2';
my $aoc_link = "https://adventofcode.com/$year/day/$day";
my $aoc_tag = "aoc-$marker";
my $blog_link = "https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-$year.html";
my $output =qq{
# Advent of Code $year Day $day - $title - part 1 / part 2 / complete solution
# $aoc_link
# https://gerikson.com/files/AoC$year/UNLICENSE
###########################################################

###########################################################

=pod

=head3 Day $day: $title

=encoding utf8

Score: 2

Leaderboard completion time: 00m00s

=cut
};

print $output;


