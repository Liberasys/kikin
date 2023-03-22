#!/usr/bin/perl

# G. Husson - Liberasys - 20160503
# G. Husson - Thalos - 20120713
 
$first = 1;
 
print "{\n";
print "\t\"data\":[\n\n";
 
for (`sudo netstat --tcp --listening --numeric --program | grep LISTEN`) {
  ($listenport,$procname) = m/^.*:(\d+).*[\/-](.*)$/;
  $procname =~ s/\s+$//; #remove trailing spaces
  #print "$listenport,$procname\n";

  print ",\n" if not $first;
  $first = 0;

  print "\t{\n";
  print "\t\t\"{#PROCNAME}\":\"$procname\",\n";
  print "\t\t\"{#PORT}\":\"$listenport\"\n";
  print "\t}";
  }

 
print "\n\t]\n";
print "}\n";
