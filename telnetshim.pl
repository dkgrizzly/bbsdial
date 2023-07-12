#!/usr/bin/perl -wT

use warnings;
use strict; 

use DBI;

$ENV{PATH} = '';

my $modemdevice = `/usr/bin/tty`;
if (!defined $modemdevice) {
	exit_message("UNABLE TO DETERMINE DEVICE NODE. E11\r\n");
}

chomp $modemdevice;

# Connect to the database.
my $dbh = DBI->connect('DBI:MariaDB:database=bbslist;host=localhost',
                       'bbslist', 'dialup',
                       { RaiseError => 1, PrintError => 0 })
    or exit_message("UNABLE TO SERVICE REQUESTS AT THIS TIME. E19\r\n");

my $modemcount = $dbh->selectrow_arrayref(
        "SELECT COUNT(*) FROM modems WHERE device = '"."$modemdevice"."'"
) or exit_message("DEVICE NOT RECOGNIZED. E23\r\n");

if($modemcount->[0] < 1) { exit_message("DEVICE NOT RECOGNIZED. E25\n"); }

my $bbsrow = $dbh->selectrow_arrayref(
        "SELECT host,port,protocol FROM modems WHERE device = '"."$modemdevice"."'"
) or exit_message("UNABLE TO SERVICE REQUESTS AT THIS TIME. E29\r\n");

my $bbshost = $bbsrow->[0];
my $bbsport = $bbsrow->[1];
my $bbsproto = $bbsrow->[2];

$dbh->disconnect;

if("$bbsproto" eq "telnet") {
  printf("TELNET TO "."$bbshost".":"."$bbsport"."\r\n");
  system("/usr/bin/telnet -8 -E $bbshost $bbsport");
  sleep 1;
  exit;
}
if("$bbsproto" eq "ssh") {
  printf("SSH TO "."$bbshost".":"."$bbsport"."\r\n");
  sleep 1;
  exit;
}

printf("UNKNOWN PROTOCOL. E46\r\n");
sleep 1;

sub exit_message {
  my $item;

  foreach $item (@_) {
    print $item;
  }

  sleep 1;
  exit;
}
