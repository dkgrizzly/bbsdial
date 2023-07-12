#!/usr/bin/perl -wT

use warnings;
use strict; 

use DBI;
use Asterisk::AGI;

my $AGI = new Asterisk::AGI;
$AGI->setcallback(\&callback);
sub callback() { exit ; }

my %agiEnv = $AGI->ReadParse();

 my ($caller) = $agiEnv{callerid} =~ /<(\d+)>/;
if (!defined $caller) {
    ($caller) = $agiEnv{callerid} =~ /(\d+)/;
}

my $dialed = $agiEnv{extension};
if (!defined $dialed) {
	$AGI->exec("NoOp","Dialed extension not set.");

	$AGI->answer();
	$AGI->exec('Playtones','congestion');
	$AGI->exec('Congestion','');
	$AGI->exec('Wait','30');

	sleep 30;

	$AGI->hangup();

	exit;
}

$AGI->exec("NoOp","Extension "."$dialed");

# Give call progress while we do our DB stuff
$AGI->exec('Progress', '');
$AGI->exec('Ringing', '');

# Connect to the database.
my $dbh = DBI->connect('DBI:MariaDB:database=bbslist;host=localhost',
                       'bbslist', 'dialup',
                       { RaiseError => 1, PrintError => 0 })
    or fail_db();

sub fail_db {
	$AGI->exec("NoOp","Unable to connect to bbslist database.");

	$AGI->answer();
	$AGI->exec('Playtones','congestion');
	$AGI->exec('Congestion','');
	$AGI->exec('Wait','30');

	$AGI->hangup();

	exit;
}

$AGI->exec("NoOp","Connected bbslist database.");

# Find the BBS in the list
my $bbscount = $dbh->selectrow_arrayref(
	"SELECT COUNT(*) FROM hosts WHERE phone = '"."$dialed"."'"
) or fail_host();

$AGI->exec("NoOp","Host lookup returned ".$bbscount->[0]." rows.");

if($bbscount->[0] < 1) { fail_host(); }

my $bbsrow = $dbh->selectrow_arrayref(
        "SELECT host,port,protocol FROM hosts WHERE phone = '"."$dialed"."'"
) or fail_host();

my $bbshost = $bbsrow->[0];
my $bbsport = $bbsrow->[1];
my $bbsproto = $bbsrow->[2];

sub fail_host {
	# We couldn't find the host
	$dbh->disconnect;

	$AGI->exec("NoOp","Unable to match phone number"."$dialed".".");

	$AGI->answer();
	$AGI->exec('Playback','custom/disconnected');
	$AGI->exec('Playtones','congestion');
	$AGI->exec('Congestion','');
	$AGI->exec('Wait','30');

	$AGI->hangup();

	exit;
}

$AGI->exec("NoOp","Found $dialed in hosts table.");

$AGI->exec("NoOp","Looking for an available modem.");

# Acquire a lock before messing with the modem table
my $havelock = $dbh->selectrow_arrayref("SELECT GET_LOCK('modemlock',1)") or fail_lock();
if ($havelock->[0] < 1) { fail_lock(); }

sub fail_lock {
	# We couldn't get the modem lock, so indicate with fast busy
	$dbh->disconnect;

	$AGI->exec("NoOp","Unable to acquire modem table lock.");

	$AGI->answer();
	$AGI->exec('Playtones','congestion');
	$AGI->exec('Congestion','');
	$AGI->exec('Wait','30');

	$AGI->hangup();

	exit;
}

$AGI->exec("NoOp","Locked table.");

# Find an available modem
my $modemrows = $dbh->selectrow_arrayref("SELECT COUNT(*) FROM modems WHERE available = 1") or fail_modem();
$AGI->exec("NoOp","Modem lookup returned ".$modemrows->[0]." rows.");

if ($modemrows->[0] < 1) { fail_modem(); }

my $modemrow = $dbh->selectrow_arrayref(
    "SELECT device,extension FROM modems WHERE available = 1"
) or fail_modem();

my $modemdevice = $modemrow->[0];
my $modemextension = $modemrow->[1];

sub fail_modem {
	# We couldn't find a modem, so indicate with fast busy
	$dbh->disconnect;

	$AGI->exec("NoOp","Unable to acquire modem.");

	$AGI->answer();
	$AGI->exec('Playtones','busy');
	$AGI->exec('Busy','');
	$AGI->exec('Wait','30');

	$AGI->hangup();

	exit;
}

$AGI->exec("NoOp","Marking modem unavailable.");

# Mark it as assigned.
$dbh->do("UPDATE modems SET available = 0, protocol = '"."$bbsproto"."', host = '"."$bbshost"."', port = '"."$bbsport"."' WHERE device = '"."$modemdevice"."'") or fail_modem();

$AGI->exec("NoOp","Acquired modem "."$modemdevice"."@"."$modemextension");

# Release the lock on the modems table.
$dbh->do("SELECT RELEASE_LOCK('modemlock')");

$AGI->exec("NoOp","Released modem table lock.");

$AGI->exec("NoOp","Dialing extension.");

$AGI->set_variable("MODEMDEVICE","$modemdevice");
$AGI->set_variable("DIALSTRING","$modemextension");

$dbh->disconnect;

