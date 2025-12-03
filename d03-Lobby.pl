#! /usr/bin/env perl
# Advent of Code 2025 Day 3 - Lobby - complete solution
# https://adventofcode.com/2025/day/3
# https://gerikson.com/files/AoC2025/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use List::Util qw/sum max first/;
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

sub joltage {
    my ( $n, @batteries ) = @_;
    if ( $n == 1 ) {
        return max @batteries;
    }
    $n = $n - 1;
    my $m = max @batteries[ 0 .. $#batteries - $n ];

    # find index of first occurrence of the max value
    my $first_m = first { $batteries[$_] == $m } 0 .. $#batteries - $n;
    return $m * 10**$n
        + joltage( $n, @batteries[ $first_m + 1 .. $#batteries ] );

}
my @ans = ( undef, 0, 0 );

for my $line (@input) {
    my @bank = split( //, $line );

    # part 1
    my ( $max, $try ) = ( 0, 0 );

    for ( my $i = 0; $i < $#bank; $i++ ) {
        for ( my $j = $#bank; $j > $i; $j-- ) {
            $try = $bank[$i] . $bank[$j];
            if ( $try > $max ) {
                $max = $try;
            }
        }
    }
    $ans[1] += $max;

    #    say joltage(12, @bank);
    $ans[2] += joltage( 12, @bank );
}

### FINALIZE - tests and run time
is( $ans[1], 16946,           "Part 1: $ans[1]" );
is( $ans[2], 168627047606506, "Part 2: $ans[2]" );
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

=head3 Day 3: Lobby

=encoding utf8

Naive straightforward solution for part 1, recursive for part 2.

Score: 2

=cut
