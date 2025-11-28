#! /usr/bin/env perl
use Modern::Perl '2015';
use Pod::Markdown;
use Data::Dump qw/dump/;
###
use utf8;

my %opts = ( output_encoding => 'UTF-8', );

my $dir    = '.';
my $readme = "$dir/README.md";
opendir( D, $dir ) or die "can't open directory: $!";
my @files = grep { ( !/^\./ ) and
		     -f "$dir/$_" and
		     ( $_ =~ m/^d.*\.pl$/ ) }  readdir(D);
closedir D;
#say join( ',', @files );

my $md_string;
my @entries;
my $score_sum;
my %metadata;

open( my $out_fh, ">", $readme ) or die "can't open $readme for writing: $!";
my %days;
for my $f ( sort { $b cmp $a } @files ) {

    my $str;
    open( my $in_fh, '<:encoding(UTF-8)', "$dir/$f" )
        or die "can't open $dir/$f for reading: $!";

    my ( $day, $title ) = $f =~ m/^d(\d+)\-(.*)/;
    $days{$day}++ if $day<=25;
    $title =~ s/\.pl$//;
    $title =~ s/\-/\ /g;

    ( $metadata{$day}->{title} ) = $title;

    my $parser = Pod::Markdown->new(%opts);
    $parser->output_string($str);
    $parser->parse_file($in_fh);
    my $has_score;
    if ( $str =~ m/^Score\:.*(\d+)/m ) {
        $score_sum += $1;
	$has_score++;
    }

    if ( $str =~ m/completion time: (.*)$/ ) {
        my $time_tag = $1;
        $metadata{$day}->{time_tag} = $time_tag;
        my $seconds = 0;

        if ( $time_tag =~ m/(\d+)h(\d+)m(\d+)s/ ) {
            $seconds = 60 * 60 * $1;
            $seconds += 60 * $2;
            $seconds += $3;

        } elsif ( $time_tag =~ m/(\d+)m(\d+)s/ ) {

            $seconds = 60 * $1;
            $seconds += $2;

        }

	$metadata{$day}->{seconds} = $seconds;
    }

    push @entries, $str;

    close $in_fh;
}


if ( $metadata{31} ) {
    $metadata{31}->{seconds} = 0;
}
say dump \%metadata;

# shift the top entry, it's metadata/notes 
my $top = shift @entries;

say $out_fh $top;

say $out_fh "Running score: $score_sum / "
    . ( scalar(keys %days) ) * 2 . "\n";


for my $e (@entries) {
    say $out_fh $e;
}

say $out_fh "### Puzzles by difficulty  (leaderboard completion times)\n";

my $count = 1;
for my $day ( sort { $metadata{$b}->{seconds} <=> $metadata{$a}->{seconds} }
    keys %metadata )
{
    next unless defined $metadata{$day}->{time_tag};

    #    next if $count>3;
    say $out_fh
        "1. Day $day - $metadata{$day}->{title}: $metadata{$day}->{time_tag}";
    $count++;
}
say $out_fh '';


close $out_fh;

sub get_handle {
    my ( $path, $op, $default ) = @_;
    ( !defined($path) || $path eq '-' ) ? $default : do {
        open( my $fh, $op, $path )
            or die "Failed to open '$path': $!\n";
        $fh;
    };
}
