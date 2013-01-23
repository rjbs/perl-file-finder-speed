#!/usr/bin/perl
use strict;

use Chart::Clicker;
use Chart::Clicker::Context;
use Chart::Clicker::Data::DataSet;
use Chart::Clicker::Data::Marker;
use Chart::Clicker::Data::Series;
use Geometry::Primitive::Rectangle;
use Graphics::Color::RGB;
use Geometry::Primitive::Circle;
use List::AllUtils qw(max sum);

my $cc = Chart::Clicker->new(width => 720, height => 300, format => 'png');

my @files = qw(0 1 2 3 4 5 6);

sub sec {
  return map {; my ($m, $s) = split /:/, $_; $m * 60 + $s; } @_
}

my %name_for = (
  FN   => 'File::Next',
  PIR  => 'Path::Iterator::Rule',
  PCR  => 'Path::Class::Rule',
  FF   => 'File::Find',
  FFR  => 'File::Find::Rule',
  FFO  => 'File::Find::Object',
  FFI  => 'File::Find::Iterator',
);

my %finding;

{
  my $results_fn = $ARGV[0] || 'results.txt';
  open my $fh, '<', $results_fn or die "can't read $results_fn: $!";

  my %result;

  while (my $line = <$fh>) {
    my ($t, $c, $x) = split /\s*-\s*/, $line;

    $result{ $c }{ $x } ||= [];
    push @{ $result{ $c }{ $x } }, sec($t);
  }

  for my $c (keys %result) {
    for my $x (sort keys %{ $result{$c} }) {
      my @measurements = @{ $result{$c}{$x} };
      my $avg = sum(@measurements) / @measurements;
      push @{ $finding{$c} }, $avg;
    }
  }
}

my @series;
my $CCDS = 'Chart::Clicker::Data::Series';
push @series, map {; $CCDS->new( keys => \@files, %$_ ) }
              map {; { name => $name_for{$_}, values => $finding{$_} } }
              grep { $finding{$_} && @files == @{ $finding{$_} } }
              qw( FF FN PCR PIR FFR FFO FFI );

my $ds = Chart::Clicker::Data::DataSet->new(
  series => \@series,
);

$cc->title->text('Finder Slowness');
$cc->title->padding->bottom(5);
$cc->add_to_datasets($ds);

my $defctx = $cc->get_context('default');

$defctx->range_axis->label("Time\N{U+00A0}Taken");
$defctx->range_axis->format(sub {
  my $m = int($_[0] / 60);
  my $s = $_[0] - $m * 60;
  return sprintf '%u:%05.2f', $m, $s;
});

$defctx->domain_axis->label('Stop after n files');
$defctx->domain_axis->tick_values([ 1 .. 6 ]);
$defctx->domain_axis->format(sub { "1e$_[0]" });

$defctx->renderer->brush->width(2);

$cc->write_output('line.png');

