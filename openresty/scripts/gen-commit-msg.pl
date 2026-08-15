#!/usr/bin/env perl
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2026 honeok <i@honeok.com>

use strict;
use warnings;

my (%old_versions, %new_versions);
my $current_category;

open my $diff, '-|', 'git', 'diff', '-U0', 'HEAD', '--'
    or die "Failed to execute git diff: $!\n";

while (my $line = <$diff>) {
    chomp $line;

    if ($line =~ m{^\+\+\+ b/(.+)$}) {
        my @parts = split m{/}, $1;

        $current_category = @parts >= 2
            ? $parts[-2]
            : undef;

        next;
    }

    next unless defined $current_category;

    # Only process changed ARG assignments.
    next unless $line =~ /^([+-])ARG\s+([^=\s]+)\s*=\s*(.*?)\s*$/;

    my ($symbol, $variable, $version) = ($1, $2, $3);

    # Remove optional surrounding quotes.
    if (
        ($version =~ /^"(.*)"$/) ||
        ($version =~ /^'(.*)'$/)
    ) {
        $version = $1;
    }

    if ($symbol eq '-') {
        $old_versions{$current_category}{$variable} = $version;
    } else {
        $new_versions{$current_category}{$variable} = $version;
    }
}

close $diff or die "git diff failed\n";

my $first_section = 1;

for my $category (sort keys %old_versions) {
    next unless exists $new_versions{$category};

    my @variables = grep {
        exists $new_versions{$category}{$_}
            && $old_versions{$category}{$_} ne $new_versions{$category}{$_}
    } sort keys %{ $old_versions{$category} };

    next unless @variables;

    print "\n" unless $first_section;
    print "$category:\n";

    $first_section = 0;

    for my $variable (@variables) {
        my $old_version = $old_versions{$category}{$variable};
        my $new_version = $new_versions{$category}{$variable};

        $old_version = substr($old_version, 0, 8)
            if length($old_version) > 20;

        $new_version = substr($new_version, 0, 8)
            if length($new_version) > 20;

        printf "- Updates `%s` from %s to %s\n",
            $variable,
            $old_version,
            $new_version;
    }
}
