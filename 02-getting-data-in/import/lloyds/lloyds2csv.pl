#!/usr/bin/perl
while (<>) {
  chomp;
  s/\r$//;
  # Remove quoted strings with commas
  s/"([A-Z0-9]+),/"$1 /g;
  s/"//g;
  # Collapse spaces
  s/  +/ /g;
  @fields=split(/,/,$_);
  # Clean up account names
  $fields[3] =~ s/99966633/assets:Lloyds:current/;
  print join(",",@fields)."\n";
}
