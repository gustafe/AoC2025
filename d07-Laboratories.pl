#! /usr/bin/env perl
# Advent of Code 2025 Day 7 - Laboratories - complete solution
# https://adventofcode.com/2025/day/7
# https://gerikson.com/files/AoC2025/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use List::Util qw/sum max all/;
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
my $Map;
my $r = 0;
my ( $start_r, $start_c ) = ( 0, undef );
for my $line (@input) {
    my $c = 0;
    for my $chr ( split( //, $line ) ) {
        if ( $chr eq 'S' ) {
            $start_r = $r;
            $start_c = $c;
        }
        $Map->{$r}{$c} = $chr;
        $c++;
    }
    $r++;
}
my $height = max keys %$Map;
my $width  = max keys %{ $Map->{$height} };

my $paths;
my $splits;
my @beamcount;
$beamcount[$start_c] = 1;
$paths->{1}{$start_c}++;
for my $r ( $start_r + 1 .. $height ) {
    no warnings 'uninitialized';

    # part 1
    for my $pc ( sort { $a <=> $b } keys %{ $paths->{$r} } ) {
        if ( $Map->{ $r + 1 }{$pc} eq '.' ) { $paths->{ $r + 1 }{$pc}++ }
        elsif ( $Map->{ $r + 1 }{$pc} eq '^' ) {
            $paths->{ $r + 1 }{ $pc - 1 }++;
            $paths->{ $r + 1 }{ $pc + 1 }++;
            $splits++;
        }
    }

    # part 2
    for my $c ( sort { $a <=> $b } keys %{ $Map->{$r} } ) {
        if ( $Map->{$r}{$c} eq '^' ) {
            $beamcount[ $c + 1 ] += $beamcount[$c];
            $beamcount[ $c - 1 ] += $beamcount[$c];
            $beamcount[$c] = 0;
        }
    }
}

#say $splits;
my $sum_paths = sum @beamcount;

### FINALIZE - tests and run time
is( $splits,    1594,           "Part 1: $splits" );
is( $sum_paths, 15650261281478, "Part 2: $sum_paths" );
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

=head3 Day 7: Laboratories

=encoding utf8

Not my best work, but it's not been my best day either. 

Score: 2

=cut
