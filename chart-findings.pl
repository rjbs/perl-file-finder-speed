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

my $cc = Chart::Clicker->new(width => 640, height => 300, format => 'png');

my @files = qw(1 2 3 4 5 6);

sub sec {
  return [ map {; my ($m, $s) = split /:/, $_; $m * 60 + $s; } @_ ]
}

my %result = (
  FN  => sec(qw(00:00.010 00:00.090 00:00.990 00:07.410 01:21.150 03:46.100)),
  PIR => sec(qw(00:00.090 00:00.600 00:01.540 00:16.360 03:06.080 06:29.440)),
  PCR => sec(qw(00:02.140 00:15.340 00:26.360 02:44.000 07:59.890 13:18.390)),
  FFR => sec(qw(04:12.320 04:17.790 04:08.060 04:11.660 03:45.530 04:12.840)),
);

my $series1 = Chart::Clicker::Data::Series->new(
  name    => 'File::Next',
  keys    => \@files,
  values  => $result{FN},
);
my $series2 = Chart::Clicker::Data::Series->new(
  name    => 'Path::Class::Rule',
  keys    => \@files,
  values  => $result{PCR},
);

my $series3 = Chart::Clicker::Data::Series->new(
  name    => 'Path::Iterator::Rule',
  keys    => \@files,
  values  => $result{PIR},
);

my $series4 = Chart::Clicker::Data::Series->new(
  name    => 'File::Find::Rule',
  keys    => \@files,
  values  => $result{FFR},
);

my $ds = Chart::Clicker::Data::DataSet->new(
  series => [ $series1, $series2, $series3, $series4 ]
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
$defctx->domain_axis->format(sub { "5e$_[0]" });

$defctx->renderer->brush->width(2);

# $cc->legend->font->size(15);
# $cc->legend->font->family('Arno Pro');

$cc->write_output('line.png');

