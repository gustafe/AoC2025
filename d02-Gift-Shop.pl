#! /usr/bin/env perl
# Advent of Code 2025 Day 2 - Gift Shop - complete solution
# https://adventofcode.com/2025/day/2
# https://gerikson.com/files/AoC2025/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/sum all/;
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

my @ranges = split( /,/, $input[0] );
my $sum;         # part 1
my %invalids;    # part 2
for my $range (@ranges) {
    my ( $start, $end ) = split( /\-/, $range );
    for my $code ( $start ... $end ) {
        my %hist;
        for my $d ( split( //, $code ) ) {
            $hist{$d}++;
        }
        next unless all { $_ > 1 } values %hist;    # no singleton characters
        my $len = length($code);

        # part 1 codes
        if ( $len % 2 == 0 ) {
            my $first  = substr( $code, 0,        $len / 2 );
            my $second = substr( $code, $len / 2, $len / 2 );
            if ( $second eq $first ) {
                say $code if $testing;
                $sum += $code;

                # also add them for part 2
                $invalids{$code}++;
            }
        }

        # new rules

        if ( scalar keys %hist == 1 ) {    # one repeated character
            say $code if $testing;
            $invalids{$code}++;
            next;
        }

        # split by segments, and compare these
        for my $segment ( 2 ... int( $len / 2 ) ) {
            next unless $len % $segment == 0;
            my @parts;
            for ( my $idx = 0; $idx <= $len - $segment; $idx += $segment ) {
                push @parts, substr( $code, $idx, $segment );
            }

            # compare all parts to the first
            my $first = $parts[0];
            if ( all { $_ eq $first } @parts ) {
                say $code if $testing;
                $invalids{$code}++;
            }
            $invalids{$code}++ if all { $_ eq $first } @parts;

        }
    }
}
my $part2 = sum keys %invalids;

### FINALIZE - tests and run time
is( $sum,   53420042388, "Part 1: $sum" );
is( $part2, 69553832684, "Part 2: $part2" );
done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS
sub sec_to_hms {
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s/(3600) ), ($s/60) % 60, $s % 60, $s * 1000 );
}

###########################################################

=pod

=head3 Day 2: Gift Shop

=encoding utf8

It was faster solving this by thinking about than trying to find a
regex online to solve it.

Score: 2



=cut
