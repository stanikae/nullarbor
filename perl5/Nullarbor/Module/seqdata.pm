package Nullarbor::Module::seqdata;
use Moo;
extends 'Nullarbor::Module';

use Data::Dumper;

#...........................................................................................

my $PASS_DEPTH = 50;
my $OK_DEPTH = 25;

#...........................................................................................

sub name {
  return "Sequence data";
}

#...........................................................................................

sub html {
  my($self) = @_;
  my $indir = $self->indir;
  my $ids = $self->isolates;
  
  my @wgs;
  my $first=1;
  for my $id (@$ids) {
    my $v2 = "$indir/$id/yield.tab";
    my $infile = -r $v2 ? $v2 : "$indir/$id/yield.clean.tab";
    my $t = Nullarbor::Tabular::load(-file=>$infile, -sep=>"\t");
    if ($first) {
      # make the headings for the table
      $t->[0][0] = 'Isolate';
      push @wgs, [ map { $_->[0] } @$t ];
      push @{$wgs[-1]}, "Quality";
      $first=0;
    }
    # copy the yield.tab fields across
    $t->[0][1] = $id;
    push @wgs, [ map { $_->[1] } @$t ];
    my $depth = $wgs[-1][-1];
    $depth =~ s/\D+$//; # remove 'x' suffix
    $wgs[-1][-1] = $depth;
    push @{$wgs[-1]}, $self->pass_fail( $depth < $OK_DEPTH ? -1 : $depth < $PASS_DEPTH ? 0 : +1 );
  }

  return $self->table_legend("&ge;${PASS_DEPTH}x ", "&ge;${OK_DEPTH}x", "<${OK_DEPTH}x")
        .$self->matrix_to_html(\@wgs);
}

#...........................................................................................

1;
