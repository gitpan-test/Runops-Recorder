#!/usr/bin/perl

package RecordingHandler;

use strict;
use warnings;

use Test::More qw(no_plan);
BEGIN { use_ok("Runops::Recorder::Reader"); }

# Generate some data
qx{$^X -Mblib -MRunops::Recorder=test-recording t/data/example.pl};
fail "Failed to generate test data" if $? or !-e "test-recording/main.data";

my $keyframes;
sub on_keyframe {
    $keyframes++;
}

my $switched_files;
my %seen_file;
sub on_switch_file {
    my (undef, $id, $path) = @_;
    $seen_file{$id} = $path;
    $switched_files++;
}

my $next_statements;
sub on_next_statement {
    $next_statements++;
}

my $enter_subs;
my %seen_subs;
sub on_enter_sub {
    my (undef, $id, $name) = @_;
    $seen_subs{$id} = $name;
    $enter_subs++;
}

my $reader = Runops::Recorder::Reader->new("test-recording", { handler => __PACKAGE__, skip_keyframes => 0 });
$reader->read_all;

is($keyframes, 1);
is($switched_files, 5);
is($seen_file{2}, 't/data/example.pl');
is(scalar keys %seen_file, 3),
is($next_statements, 13);
is($enter_subs, 3);
is($seen_subs{3}, 'import');
is($seen_subs{6}, 'foo');
is(scalar keys %seen_subs, 2),