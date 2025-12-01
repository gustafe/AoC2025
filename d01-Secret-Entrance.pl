#! /usr/bin/env perl
# Advent of Code 2025 Day 1 - Secret Entrance - complete solution
# https://adventofcode.com/2025/day/1
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
my $part2 = $ARGV[0] // 0;
printf( "==> running part %d...\n", $part2 ? 2 : 1 );
my @ins;
for my $line (@input) {
    if ( $line =~ m/(L|R)(\d+)/ ) {
        my ( $dir, $clicks ) = ( $1, $2 );
        push @ins, { dir => $dir, clicks => $clicks };
    } else {

        die "unknown input line: $line";
    }

}

my $pos          = 50;
my $total_passes = 0;
while (@ins) {
    my $in = shift @ins;
    say join( ' ', '==>', $in->{dir}, $in->{clicks} ) if $testing;
    my $npos
        = $in->{dir} eq 'L'
        ? $pos - ( $in->{clicks} ) % 100
        : $pos + ( $in->{clicks} ) % 100;
    my $turns = int( $in->{clicks} / 100 );
    say "* > $npos" if $testing;
    if ( $npos == 0 or $npos == 100 ) {
        $total_passes++;
        $pos = 0;
    } elsif ( $npos < 0 ) {
        $total_passes++ if ( $pos != 0 and $part2 );
        $pos = 100 + $npos;

    } elsif ( $npos > 100 ) {
        $total_passes++ if ( $pos != 0 and $part2 );
        $pos = ( $npos - 100 );

    } else {
        $pos = $npos;
    }
    $total_passes += $turns if $part2;
    say "**> $pos, passes: $total_passes" if $testing;
}

### FINALIZE - tests and run time
if ($part2) {
    is( $total_passes, 5892, "Part 2: $total_passes" );
} else {
    is( $total_passes, 1029, "Part 1: $total_passes" );
}

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

=head3 Day 1: Secret Entrance

=encoding utf8

We've gone over to 12 problems instead of 25, so it's to be expected
that the first day's difficulty has ramped up a bit compared to day 1
on previous years.

A problem like this practically invites off-by-one errors, and sure
enough, that's what I got. Luckily the test input covered most of the
corner cases.

Score: 2

=cut
