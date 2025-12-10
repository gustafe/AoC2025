#! /usr/bin/env perl
# Advent of Code 2025 Day 10 - Factory - part 1
# https://adventofcode.com/2025/day/10
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
my $Data;
my $id=1;
for my $line (@input) {
    say $line if $testing;
    my @elems= split(/\s+/, $line);
    my $lights= shift @elems;
    my $joltages= pop @elems;
    my @lights = split(//, $lights);
    shift @lights;
    pop @lights;
    $Data->{$id}{lights} = [@lights];
    $joltages = substr($joltages,1);
    $joltages= substr($joltages, 0,-1);
    my @joltages = split(//,$joltages);
    shift @joltages; pop @joltages;
    $Data->{$id}{joltages}= [@joltages];
    my @buttons;
    for my $el (@elems) {
	my $b= substr( $el, 1);
	$b= substr($b ,0,-1);
	push @{$Data->{$id}{buttons}}, [split(/\,/, $b)]
    }

    $id++;
}
my $sum;
for my $id (keys %$Data) {
    my $target =0;
    my @lights=  @{$Data->{$id}{lights}};
    for (my $i=0;$i<=$#lights;$i++) {
	$target |= (1<<$i) if $lights[$i] eq '#'
    }
    printf("t: %06b\n" , $target) if $testing;
    my @buttons;
    for my $b (@{$Data->{$id}{buttons}}) {
	my $v = 0;
	for my $i (@$b) {
	    $v |= (1<<$i);
	}
	push @buttons, $v;
    }
    if ($testing) {
	for my $btn (@buttons) {
	    printf("   %06b\n", $btn);
	}
    }

    # queue items: # of pushes, current button, state of buttons pressed, current value
    my @queue = ( [0,0,0, 0] );
    my $seen;
    $seen->{0}++;
    my $shortest;
    LOOP: while (@queue) {
	  my ($pushes, $curr, $state, $val ) = @{shift @queue};

	  # toggle  buttons
	  for my $i (0..$#buttons) {
	      $state ^= (1<<$i);
	      next if $seen->{$state};
	      $seen->{$state}++;
	      my $nval = $val ^ $buttons[$i];
	      if ($nval == $target) {
		  $shortest = $pushes +1 ;
		  last LOOP;
	      }
	      push @queue, [$pushes+1, $i, $state, $val ^ $buttons[$i]];
	  }
      }
    $sum += $shortest;
}
say $sum;
### FINALIZE - tests and run time
is($sum, 479, "Part 1: $sum");
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

=head3 Day 10: Factory, part 1

=encoding utf8

I was really proud of solving part 1 without any help or hints, but
part 2 seems to be requiring some CS stuff I've never heard of, so
I'll be putting that in the back burner.

Score: 1

=cut
