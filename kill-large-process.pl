#!/usr/local/bin/perl

use strict;
use warnings;
use 5.010;
use DateTime;
use Proc::ProcessTable;

my $table = Proc::ProcessTable->new;

for my $process (@{$table->table}) {
    # skip root processes
    next if $process->uid == 0 or $process->gid == 0;

    # skip anything other than Passenger application processes
    #next unless $process->fname eq 'ruby' and $process->cmndline =~ /\bRails\b/;

    # skip any using less than 1 GiB
    # next if $process->rss < 1_073_741_824;
    # anything 70 G > will be killed
    next if $process->rss < 70_073_741_824;

    # document the slaughter
    (my $cmd = $process->cmndline) =~ s/\s+\z//;
    my $pid = $process->pid;
    my $uid = $process->uid;
    my $rss = $process->rss;
    my $fname = $process->fname;
    print "Killing process: pid=", $process->pid, " uid=", $process->uid, " rss=", $process->rss, " fname=", $process->fname, " cmndline=", $cmd, "\n";
    my $report = "Killing process: pid= $pid,  uid=, $uid,  rss=, $rss,  fname=, $fname,  cmndline=, $cmd, \n";
    my $dt = DateTime->now;

    # try first to terminate process politely
    kill 15, $process->pid;

    # wait a little, then kill ruthlessly if it's still around
    sleep 5;
    kill 9, $process->pid;
    my $filename = 'memory_overflow_report.txt';
    open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
    say $fh $dt;
    say $fh $report;
    close $fh;
    say 'done';
}
