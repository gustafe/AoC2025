#! /usr/bin/env perl
# Advent of Code 2025 Day 6 - Trash Compactor - part 2 
# https://adventofcode.com/2025/day/6
# https://gerikson.com/files/AoC2025/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/sum product max/;
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
my @ops = split( //, pop @input );
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
my $max_r = max keys %$Map;
my $pos;
$pos->{0} = { op => $ops[0], len => undef };
my $prev = 0;
my $len  = 0;
for ( my $i = 1; $i < $#ops; $i++ ) {
    if ( $ops[$i] eq '+' or $ops[$i] eq '*' ) {
        $pos->{$prev}{len} = $len - 1;
        $pos->{$i}{op}     = $ops[$i];
        $len               = 0;
        $prev              = $i;
    } else {
        $len++;
    }
}
my $last_pos = ( sort { $a <=> $b } keys %$pos )[-1];
$pos->{$last_pos}{len} = scalar(@ops) - $last_pos;

#dump $pos;
my $total;
for my $p ( keys %$pos ) {
    no warnings 'uninitialized';
    my @num;
    my $idx = 0;
    for my $c ( $p .. ( $p + $pos->{$p}{len} ) ) {
        for my $r ( 0 .. $max_r ) {
            $num[$idx] .= $Map->{$r}{$c} if $Map->{$r}{$c} =~ /\d+/;
        }
        $idx++;
    }
    if ( $pos->{$p}{op} eq '+' ) {
        $total += sum(@num);
    } else {
        $total += product(@num);
    }
}
### FINALIZE - tests and run time
is( $total, 10227753257799, "Part 2: $total" );
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

=head3 Day 6: Trash Compactor

=encoding utf8

Holy pythonic code, Batman - significant whitespace! 

This is my list favorite "advanced" AoC problem concept - not hard, just very very fiddly. 

I'm only including part 2 here because part 1 is, imho, trivial.

Score: 2

Leaderboard completion time: 00m00s

=cut
