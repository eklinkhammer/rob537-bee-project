#!/usr/bin/perl

while(<>) {
    my @line = split ' ', $_;
    print $_ if $line[2] != 0 || $line[3] != 0;
}
