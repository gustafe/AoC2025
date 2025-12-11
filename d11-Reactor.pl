#! /usr/bin/env perl
# Advent of Code 2025 Day 11 - Reactor - part 1 
# https://adventofcode.com/2025/day/11
# https://gerikson.com/files/AoC2025/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use List::Util qw/sum/;
use Data::Dump qw/dump/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
use Graph;
use Graph::Directed;
use Memoize;
sub sec_to_hms;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my @input;
my $file = $testing ? 'test2.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $Map;
my $graph = Graph::Directed->new;
for my $line (@input) {
    my ( $curr, $targets ) = split( /:\ /, $line );
    for my $t ( split( /\s+/, $targets ) ) {
        $Map->{$curr}{$t}++;
        $graph->add_edge( $curr, $t );
    }
}
dump $Map if $testing;

# use Graph module's built in All paths shortest path algo to find part 1.

my $apsp = $graph->APSP_Floyd_Warshall();

my @paths1 = $apsp->all_paths( 'you', 'out' );

my $part1 = scalar @paths1;

### Part 2 - recursive solution with memoization
#   credit: /u/musifter https://www.reddit.com/r/adventofcode/comments/1pjp1rm/2025_day_11_solutions/ntg7iuy/
memoize('path_count');

my $part2 = path_count('svr')->[2];

### FINALIZE - tests and run time
is( $part1, 668,             "Part 1: $part1" );
is( $part2, 294310962265680, "Part 2: $part2" );
done_testing();
say sec_to_hms(tv_interval($start_time));

### SUBS
sub sec_to_hms {
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s/(3600) ), ($s/60) % 60, $s % 60, $s * 1000 );
}

sub path_count {
    my $node = shift @_;
    my @ret  = (0);
    return ( [1] ) if $node eq 'out';

    my $special = int( $node eq 'fft' or $node eq 'dac' );
    for my $target ( keys %{ $Map->{$node} } ) {
        my @res = @{ path_count($target) };
        for my $idx ( 0 .. $#res ) {
            $ret[ $idx + $special ] += $res[$idx];
        }
    }
    return \@ret;

}

###########################################################

=pod

=head3 Day 11: Reactor

=encoding utf8

For part 1, I got the answer easily using the Graph module,
previously seen in day 8. However, trying to use it in part 2 gave me
an OOM, so obviously there's something hinky going on with the new
paths...

I took a look at the subreddit and found a solution that was more in
line with my original intuition about using recursion. Credit in
source!

Score: 1

=cut
