#! /usr/bin/env perl
# Advent of Code 2025 Day 9 - Movie Theater - complete solution
# https://adventofcode.com/2025/day/9
# https://gerikson.com/files/AoC2025/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/sum min max any/;
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
my @coords;
my $reds;
for my $line (@input) {
    my ( $x, $y ) =split(/\,/,$line); 
    push @coords, [$x,$y];
    $reds->{$x}{$y}++;
    
}

my @maxarea = (undef,0,0);

# part 1 
for my $i (0 .. $#coords) {
    for my $j (0 ... $#coords) {
        next if $i==$j;

        my $a = area( $coords[$i], $coords[$j]);
        $maxarea[1] = $a if $a>$maxarea[1];
    }
}

# part 2

# we save the cells of the perimiter in 2 different hashrefs, one with x as the first key, one with y 
my $poly;
my $polx;
my @bounds = (1e6,0,1e6,0);
for (my $idx=0; $idx<$#coords; $idx++) {
    my $p1 = $coords[$idx];
    my $p2 = $coords[$idx+1];
    printf("%12s -> %12s: %5d x %5d\n",	   $input[$idx], $input[$idx+1],	   abs($p2->[0] - $p1->[0]),	   abs($p2->[1] - $p1->[1])) if $testing;
    my ( $x1, $x2 ) = (min($p1->[0],$p2->[0]), max($p1->[0],$p2->[0]));
    my ( $y1, $y2 ) = (min($p1->[1],$p2->[1]), max($p1->[1],$p2->[1]));
    for my $x ($x1 .. $x2) {
	for my $y ($y1 .. $y2 ) {
	    $poly->{$x}{$y}++;
	    $polx->{$y}{$x}++;
	}
    }
    $bounds[0] = $x1 if $x1 < $bounds[0];
    $bounds[1] = $x2 if $x2 > $bounds[1];
    $bounds[2] = $y1 if $y1 < $bounds[2];
    $bounds[3] = $y2 if $y2 > $bounds[3];
}
# connect the first and last points in the list
for my $x (min($coords[0][0],$coords[-1][0]) .. max($coords[0][0],$coords[-1][0]) ) {
    for my $y (min($coords[0][1],$coords[-1][1]) .. max($coords[0][1],$coords[-1][1])) {
	$poly->{$x}{$y}++;
	$polx->{$y}{$x}++;
    }
}
printf("%d x %d\n", $bounds[1]-$bounds[0], $bounds[3]-$bounds[2]) if $testing;

for my $i (0..$#coords) {
    # say "=> $i";
  INNER: for my $j (0..$#coords) {
	next if $i == $j;
        # normalize the indexes of the box we are looking at
        my ( $min_x, $max_x ) = (
            min( $coords[$i][0], $coords[$j][0] ),
            max( $coords[$i][0], $coords[$j][0] ));
        my ( $min_y, $max_y ) = (
            min( $coords[$i][1], $coords[$j][1] ),
            max( $coords[$i][1], $coords[$j][1] ));
	
	# look at a box that is one cell smaller along all dimensions as the current one
	# if any cell of the perimiter construct intrudes into this, it's not legal
    
	# check along X
	printf("[%2d,%2d] [%2d,%2d]\n", $min_x, $min_y,$max_x,$max_y) if $testing;
	say "crossings above min_x $min_x: ".join(",", map {sprintf("%2d",$_)} grep {$_>$min_y and $_<$max_y} (sort {$a<=>$b} keys %{$poly->{$min_x+1}})) if $testing;
	say "crossings below max_x $max_x: ".join(",", map {sprintf("%2d",$_)} grep {$_>$min_y and $_<$max_y}(sort {$a<=>$b} keys %{$poly->{$max_x-1}})) if $testing;

	next INNER if grep {$_>$min_y and $_<$max_y} keys %{$poly->{$min_x+1}};
	next INNER if grep {$_>$min_y and $_<$max_y} keys %{$poly->{$max_x-1}};

	# check along Y
	next INNER if grep {$_>$min_x and $_<$max_x} keys %{$polx->{$min_y+1}};
	next INNER if grep {$_>$min_x and $_<$max_x} keys %{$polx->{$max_y-1}};

	my $a = area( $coords[$i], $coords[$j]);
	printf("[%2d] (%2d,%2d) x [%2d] (%2d,%2d): %d\n",
	       $i, @{$coords[$i]}, $j, @{$coords[$j]}, $a) if $testing;
	$maxarea[2] = $a if $a >$maxarea[2];
    }
}
### FINALIZE - tests and run time
is($maxarea[1], 4763040296,"Part 1: ". $maxarea[1]);
is($maxarea[2], 1396494456, "Part 2: ".$maxarea[2]);
done_testing();
say sec_to_hms(tv_interval($start_time));

### SUBS
sub sec_to_hms {
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s/(3600) ), ($s/60) % 60, $s % 60, $s * 1000 );
}

sub area {
    my ($p1,$p2) = @_;
    return ( (1 +abs( $p2->[0] - $p1->[0] )) *
	     (1 +abs( $p2->[1]  -$p1->[1] )));
      
}

###########################################################

=pod

=head3 Day 9: Movie Theater

=encoding utf8

Today was pretty fun! I went down some wrong paths but got to it in the end.

Score: 2

=cut
