#!/usr/bin/perl

# G. Husson - Liberasys - 20160503
# G. Husson - Thalos - 20120713

 
$first = 1;
 
print "{\n";
print "\t\"data\":[\n\n";
 
for (`sudo netstat --udp --listening --numeric --program | grep udp`) {
  ($listenport,$procname) = m/^.*:(\d+).*[\/-](.*)$/;
  $procname =~ s/\s+$//; #remove trailing spaces
  #print "$listenport,$procname\n";

  print "\t,\n" if not $first;
  $first = 0;

  print "\t{\n";
  print "\t\t\"{#PROCNAME}\":\"$procname\",\n";
  print "\t\t\"{#PORT}\":\"$listenport\"\n";
  print "\t}\n";
  }

 
print "\n\t]\n";
print "}\n";
