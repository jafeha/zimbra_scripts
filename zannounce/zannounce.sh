#!/bin/bash

#
# This Script is used for Updating our Admin-Announcement Distribution List
#
#    Copyright (C) 2015 Jakob Hasselmann
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

if [[ $EUID -ne 1001 ]]; then
   echo "This script must be run as user 'zimbra'" 1>&2
   exit 1
fi

# Get User Accounts in Distribution List
echo '# Getting a List of Accounts in the Distribution List...'
zmprov gdl announcements@domain.com | awk 'f;/members/{f=1}' > /tmp/list_members.txt
echo '#'

# Get all User Accounts that ever logged in
echo '# Getting a List of User Accounts who ever logged in...'
zmaccts | grep "@" | grep -v never | cut -d" " -f1 > /tmp/list_all.txt
echo '#'

# Compare Logged in Users with Accounts in Distribution List
echo '# Comparing Lists...'
grep -Fxv -f /tmp/list_members.txt /tmp/list_all.txt > /tmp/new_accounts.txt
echo '#'

# Add new Users to Distribution List
echo '# Adding new Members to Distribution List...'
for each in `cat /tmp/new_accounts.txt`; do zmprov adlm announcements@domain.com $each; done
echo '#'

# Print newly added Distribution List Members
printf '# I Added the following Users to the Distribution List announcements@domain.com:\n'; cat /tmp/new_accounts.txt

# Delete Lists
rm /tmp/list_members.txt
rm /tmp/list_all.txt
rm /tmp/new_accounts.txt

