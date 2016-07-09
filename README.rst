Formula for Parts of OpenBSD's Base
===================================

Mirror
------
You should set `pillar[openbsd:mirror]` 
to a (preferably complete) mirror near 
your (minion's) location.
See https://www.openbsd.org/ftp.html 
for a list of mirrors.

Don't build as root
-------------------
It's recommended not to build code as root.
You have to set `pillar[openbsd:build_user]`
to specify a user (who should be member of
the group `wsrc`) who's account should be
used to compile code.
