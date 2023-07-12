# bbsdial
A collection of perl scripts to map phone numbers to telnet connections on an asterisk dialup to telnet gateway

# prerequisites
- Asterisk (tested on 16)
- MariaDB
- perl 5.x
- perl modules DBD::MariaDB and Asterisk::AGI from CPAN
- modified mgetty -> autologin, no issue or prompt
- modified telnet -> silent, no escape, default to binary

# installation
- change the SQL credentials to something unique
- create the SQL database:
```
# mariadb < dbsetup.sql
```
- place bbsdial.pl and releasemodem.pl in /usr/share/asterisk/agi-bin
- place telnetshim.pl somewhere
- add the following to /etc/mgetty/login.config:
```
/AutoTEL/ nobody nobody /path/to/telnetshim.pl
*       -       -       /bin/false
```

# patching mgetty
By default mgetty is slightly noisy, and demands a login.  The included patch against mgetty-1.2.1 silences mgetty and automatically logs in as /AutoTEL/

# patching telnet
This is left as an exercise for you.  Telnet is very noisy and may confuse some dialup clients.  It is often desirable to use a telnet implementation without escape mode and zero feedback given.

# configuring Asterisk
- The included extensions.conf file is just the new bbslist context relevant to executing the AGI scripts and dialing.
  Insert those lines in your /etc/asterisk/extensions.conf somewhere appropriate (the bottom of the file is fine).
- The _227XXXX pattern should be replaced in the bbslist context if you are using a different prefix.
- add the following to your main dialplan context (typically named default or local):
```
include => bbslist
```

# configuring your ATAs
- Generic instructions you can follow from CRD's guide [here](https://gekk.info/articles/ata-config.html)
- For Grandstream HT702 devices there is a template xml file included in this package.
  Be sure to replace the MACADDR, PHONE1, PHONE2, PASSWORD1, PASSWORD2 and SIPSERVER placeholders.
