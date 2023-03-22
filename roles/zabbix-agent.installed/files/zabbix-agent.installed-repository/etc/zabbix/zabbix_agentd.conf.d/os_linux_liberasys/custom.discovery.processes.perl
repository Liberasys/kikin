#!/usr/bin/perl

# G. Husson - Liberasys - 20160503
# G. Husson - Thalos - 20120713
 
my $first = 1;
my %binfile_hashtable;

# find the processes, extract the binary file name and put in in an hashtable
foreach my $process_execpath (`ls -1 /proc/*/exe`) {
  my $process_binpath = (`readlink --canonicalize $process_execpath`);
  $process_binpath =~ s/\(deleted\)//;
  if ($process_binpath ne "") {
    my $process_basename = `basename --zero $process_binpath`;
    $process_basename =~ s/\x00$//;
    $binfile_hashtable{$process_basename} = '';
  }
} 

print "{\n";
print "\t\"data\":[\n";

my @unique = keys %hash;

for (keys %binfile_hashtable) {
  my $procname = $_;
  print ",\n" if not $first;
  $first = 0;

  print "\t\t{";
  print "\"{#PROCNAME}\":\"$procname\"";
  print "}";


  }
 
print "\n\t]\n";
print "}\n";

exit 0;

