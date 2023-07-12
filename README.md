# bbsdial
A Collection of perl scripts to map phone numbers to telnet connections on an asterisk dialup to telnet gateway

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
```
