#!/usr/bin/perl -wT

use warnings;
use strict; 

use DBI;
use Asterisk::AGI;

my $AGI = new Asterisk::AGI;
$AGI->setcallback(\&callback);
sub callback() { exit ; }

my %agiEnv = $AGI->ReadParse();

my $modemdevice = $ARGV[0];
if (!defined $modemdevice) {
	$AGI->exec("NoOp","Modem device not set.");

	exit;
}

# Connect to the database.
my $dbh = DBI->connect('DBI:MariaDB:database=bbslist;host=localhost',
                       'bbslist', 'dialup',
                       { RaiseError => 1, PrintError => 0 })
    or fail_db();

sub fail_db {
	$AGI->exec("NoOp","Unable to connect to bbslist database.");

	exit;
}

$AGI->exec("NoOp","Connected bbslist database.");

$AGI->exec("NoOp","Releasing modem "."$modemdevice".".");

$dbh->do("UPDATE modems SET available = 1, protocol = NULL, host = NULL, port = NULL WHERE device = '"."$modemdevice"."'");

$dbh->disconnect;

