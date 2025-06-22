#!/usr/bin/env raku
use lib 'lib';
use JSON::Fast;
use JSON::ToCSV;
use Getopt::Long;

my $input     = '';
my $output    = 'output.csv';
my $use-dot   = False;
my $with-types = True;
my @filters;

GetOptions(
  'input=s'      => \$input,
  'output=s'     => \$output,
  'dot'          => \$use-dot,
  'underscore'   => sub { $use-dot = False },
  'no-types'     => sub { $with-types = False },
  'filter=s%'    => -> %f { @filters = %f.keys }
);

unless $input {
  say q:to/END/;
Usage: json2csv.raku --input=data.json [--output=out.csv] [--dot|--underscore] [--no-types] [--filter=key1] [--filter=key2]
  --input        Input JSON file
  --output       Output CSV file (default: output.csv)
  --dot          Use dot.notation (default if --underscore is not passed)
  --underscore   Use underscore_notation
  --no-types     Do not annotate CSV column headers with types
  --filter       Include only specified keys (repeatable)
END
  exit 1;
}

my $json-text = slurp $input;
my $data = from-json($json-text);

my $csv = json-to-csv($data, :dot($use-dot), :with-types($with-types), :filter-keys(@filters));
spurt $output, $csv;
say "✅ CSV written to $output";
