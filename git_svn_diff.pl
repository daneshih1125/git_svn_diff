#!/usr/bin/perl
my $git_diff_res = `git diff`;
my $svn_version = `git svn info |grep "Last Changed Rev"`;
$svn_version =~ s/Last Changed Rev: ([0-9]+)/$1/g;
$svn_version =~ s/\n//g;

my @lines = split /\n/, $git_diff_res;
my $file_name = "";
my $got_diff = 0;
foreach my $line (@lines) {
    if ($line =~ /^diff --git/) {
        ($file_name) = $line =~ /^diff --git a\/(\S+) b\/\S+/;
        print "Index: $file_name\n";
        print "===================================================================\n";
        $got_diff = 1;
        next;
    }
    if ($line =~ m/^index [a-z0-9]{7}\.\.[a-z0-9]{7} [0-9]{6}/) {
        next;
    }
    if ($line =~ m/^\-\-\-/) {
        print "--- $file_name";
        print "\t(revision $svn_version)\n";
        next;
    }
    if ($line =~ m/^\+\+\+/) {
        print "+++ $file_name";
        print "\t(working copy)\n";
        next;
    }
    print "$line\n";
}

my $git_diff_cached = `git diff --cached`;
my @lines = split /\n/, $git_diff_cached;
foreach my $line (@lines) {
    if ($line =~ /^diff --git/) {
        ($file_name) = $line =~ /^diff --git a\/(\S+) b\/\S+/;
        print "Index: $file_name\n";
        print "===================================================================\n";
        next;
    }
    if ($line =~ m/^index [a-z0-9]{7}\.\.[a-z0-9]{7}$/ || 
        $line =~ m/^new file mode [0-9]+$/ ) {
        next;
    }
    if ($line =~ m/^\-\-\-/) {
        print "--- $file_name";
        print "\t(revision 0)\n";
        next;
    }
    if ($line =~ m/^\+\+\+/) {
        print "+++ $file_name";
        print "\t(revision 0)\n";
        next;
    }
    print "$line\n";
}
