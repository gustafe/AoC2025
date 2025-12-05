#! /usr/bin/env perl
# Advent of Code 2025 Day 5 - Cafeteria - complete solution
# https://adventofcode.com/2025/day/5
# https://gerikson.com/files/AoC2025/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use List::Util qw/sum/;
use Data::Dump qw/dump/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
sub sec_to_hms;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my @ranges;
my @candidates;
for my $line (@input) {
    if ( $line =~ /^(\d+)\-(\d+)$/ ) {
        push @ranges, [ $1, $2 ];
    } elsif ( $line =~ /^\d+$/ ) {
        push @candidates, $line;
    } else {

        next;
    }
}
@ranges     = sort { $a->[0] <=> $b->[0] } @ranges;
@candidates = sort { $a <=> $b } @candidates;

my %fresh;    # use a hash to handle double-counting
for my $n (@candidates) {
    for my $range (@ranges) {
        if ( $n >= $range->[0] and $n <= $range->[1] ) {
            $fresh{$n}++;
            next;
        }
    }
}

my @all;
my ( $min, $max ) = @{ shift @ranges };
while (@ranges) {
    my $nrange = shift @ranges;
    if ( $nrange->[0] > $max )
    {    # start new extended range, store the previous one
        push @all, [ $min, $max ];
        ( $min, $max ) = @$nrange;
        next;
    } elsif ( $nrange->[0] >= $min and $nrange->[1] <= $max )
    {    # next range entirely in existing, skip
        next;
    } elsif ( $nrange->[0] >= $min ) {    # extend range
        $max = $nrange->[1];
        next;
    }
}

say "Independent ranges: " . scalar @all;

my $sum;

for my $r (@all) {
    $sum += ( $r->[1] - $r->[0] ) + 1;
}
$sum += ( $max - $min ) + 1;

### FINALIZE - tests and run time
is( scalar keys %fresh, 643,             "Part 1: " . scalar keys %fresh );
is( $sum,               342018167474526, "Part 2: $sum" );
done_testing();
say sec_to_hms(tv_interval($start_time));

### SUBS
sub sec_to_hms {
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s/(3600) ), ($s/60) % 60, $s % 60, $s * 1000 );
}

###########################################################

=pod

=head3 Day 5: Cafeteria

=encoding utf8

Easiest yet, I believe. Had some issues with off-by-one errors but
they were cleared up using testing data.

Score: 2

=cut
