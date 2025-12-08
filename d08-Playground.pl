#! /usr/bin/env perl
# Advent of Code 2025 Day 8 - Playground - complete solution
# https://adventofcode.com/2025/day/8
# https://gerikson.com/files/AoC2025/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use List::Util qw/sum product max/;
use Data::Dump qw/dump/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
use Graph::Undirected;
sub sec_to_hms;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my @ans;
my $points;
my $id = 1;
for my $line (@input) {
    $points->{$id} = [ split( /,/, $line ) ];
    $id++;
}

my $distances;
my $seen;
print "counting distances....";
for my $i ( sort { $a <=> $b } keys %$points ) {
    for my $j ( sort { $a <=> $b } keys %$points ) {
        next if $i == $j;
        next if $seen->{$j}{$i};
        my $d = distance( $points->{$i}, $points->{$j} );

        $distances->{$d} = [ $i, $j ];
        $seen->{$i}{$j}++;
    }
}
printf( " done after %.3f s\n", tv_interval($start_time) );
print "adding circuits...";
my $circuits = Graph::Undirected->new();
my $graph_p1 = Graph::Undirected->new();
my $count    = 0;
my $LIMIT    = $testing ? 9 : 999;
for my $d ( sort { $a <=> $b } keys %$distances ) {

    my ( $id1, $id2 ) = sort map { $distances->{$d}[$_] } ( 0, 1 );
    printf(
        "[%2d] %12s <-> [%2d] %12s - %.3f\n",
        $id1, join( ',', @{ $points->{$id1} } ),
        $id2, join( ',', @{ $points->{$id2} } ), $d
    ) if $testing;
    $circuits->add_weighted_edge( $id1, $id2, $d );
    if ( $count == $LIMIT ) {
        $graph_p1 = $circuits->copy();  # we should be fine with a shallow copy here
    }
    $count++;
}
printf( " done after %.3f s\n", tv_interval($start_time) );

# part 1
my @cc    = $graph_p1->connected_components();
my @sizes = map { scalar @{$_} } @cc;
$ans[1] = product( ( sort { $b <=> $a } @sizes )[ 0 .. 2 ] );

#dump $circuits;
print "calculating MST...";
my $mst = $circuits->MST_Kruskal;
printf( " done after %.3f s\n", tv_interval($start_time) );
my @weights;

for my $u ( sort { $a <=> $b } $mst->vertices ) {
    for my $v ( sort { $a <=> $b } $mst->vertices ) {
        next if $u == $v;
        if ( $mst->has_edge( $u, $v ) ) {
            push @weights, [ $circuits->get_edge_weight( $u, $v ), $u, $v ];
        }
    }
}
my $line = 0;

for my $v ( sort { $b->[0] <=> $a->[0] } @weights ) {
    last if $line > 0;
    printf(
        "%.3f %2d %s %2d %s = %d\n",  $v->[0],
	   $v->[1],        join( ",", @{ $points->{ $v->[1] } } ),
	   $v->[2],        join( ",", @{ $points->{ $v->[2] } } ),
	   $points->{ $v->[1] }[0] * $points->{ $v->[2] }[0]
    );
    $ans[2] = $points->{ $v->[1] }[0] * $points->{ $v->[2] }[0];
    $line++;
}

### FINALIZE - tests and run time
is( $ans[1], 67488,      "Part 1: " . $ans[1] );
is( $ans[2], 3767453340, 'Part 2: ' . $ans[2] );
done_testing();
say sec_to_hms(tv_interval($start_time));

### SUBS
sub sec_to_hms {
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s/(3600) ), ($s/60) % 60, $s % 60, $s * 1000 );
}

sub distance {
    my ( $p1, $p2 ) = @_;
    return        sqrt( ( $p2->[0] - $p1->[0] )**2
			+ ( $p2->[1] - $p1->[1] )**2
			+ ( $p2->[2] - $p1->[2] )**2 );
}

###########################################################

=pod

=head3 Day 8: Playground

=encoding utf8

Finally we're getting into the harder problems... maybe I will regret
saying that.

Anyway, after doing my best trying to implement a graph from first
principles, I remember the L<Graph
module|https://metacpan.org/dist/Graph/view/lib/Graph.pod>
exists. Some dicking around in the documentation got me what I needed.

This code barely finishes on my $5 VPS, but running on a Real
Computer(tm) gives the answers in about 15s.

Score: 2

=cut
