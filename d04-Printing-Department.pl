#! /usr/bin/env perl
# Advent of Code 2025 Day 4 - Printing Department - complete solution
# https://adventofcode.com/2025/day/4
# https://gerikson.com/files/AoC2025/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/sum min max/ ;
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
my @dirs = (
    [ -1, 0 ],  [ 1,  0 ], [ 0, -1 ], [ 0, 1 ],
    [ -1, -1 ], [ -1, 1 ], [ 1, -1 ], [ 1, 1 ]
);

my $Map;
my $r = 0;
for my $line (@input) {
    my $c = 0;
    for my $chr ( split( //, $line ) ) {
        $Map->{$r}{$c} = $chr;
        $c++;
    }
    $r++;
}
my $height = max keys %$Map;
my $width  = max keys %{ $Map->{$height} };

my $removed = 0;
my @history;
my $generation = 0;
my ( $min_r, $max_r ) = ( 0, $height );
my ( $min_c, $max_c ) = ( 0, $width );

while (1) {
    my $prev_removed = $removed;

    say "==> $generation" if $generation % 10 ==0;
    my %r_vals;
    my %c_vals;
    for my $r ( $min_r .. $max_r ) {
        for my $c ( $min_c .. $max_c ) {
            no warnings 'uninitialized';

            next unless $Map->{$r}{$c} eq '@';
	    $r_vals{$r}++;
	    $c_vals{$c}++;
            my $neighbors = 0;
            for my $dir (@dirs) {
                if (   $Map->{ $r + $dir->[0] }{ $c + $dir->[1] } eq '@'
                    or $Map->{ $r + $dir->[0] }{ $c + $dir->[1] } eq sprintf( "%d", $generation ) )
                {
                    $neighbors++;
                }
            }
            if ( $neighbors < 4 ) {
                printf( "%1s", $generation ) if $testing;
                $Map->{$r}{$c} = $generation;
                $removed++;
            } else {
                print $Map->{$r}{$c} if $testing;
            }
        }
        print "\n" if $testing;
    }
    printf( "removed: %d\n", $removed - $prev_removed ) if $testing;
    push @history, $removed;
    last if ( $removed - $prev_removed == 0 );
    $generation++;
    ( $min_r, $max_r ) = ( ( min keys %r_vals ), ( max keys %r_vals ) );
    ( $min_c, $max_c ) = ( ( min keys %c_vals ), ( max keys %c_vals ) );
}

### FINALIZE - tests and run time
is( $history[0],  1457, "Part 1: " . $history[0] );
is( $history[-1], 8310, "Part 2: " . $history[-1] );
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

=head3 Day 4: Printing Department

=encoding utf8

A nice easy problem. I have enough data to produce a nice heatmap, should I choose to.

Score: 2


=cut
