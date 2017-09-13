#!/usr/bin/perl -w
# v1.0
# Copyright (c) Duncan McNutt May 2008. Free for personal use.
# Please send enhancements & bug reports back to me duncan _at_ aranea net
# For commercial use, please contact me.
#
# This script will clean out samba 3.x vfs recycle trash/rubbish bins.
# It looks for all files with an access date older than a certain number of
# days and deletes them. Empty directories will be deleted as well.
#
# There is a lot of outdated information on the recycle feature of samba.
# For up to date documentation on the recycle feature, see:
#  http://www.samba.org/samba/docs/man/manpages-3/vfs_recycle.8.html
#

# List of the shares with recycle bins goes here, use colons ":" to separate
# the different directories.
$recycledirs = "/data/home/astrid:/data/home/christian:/data/abcTeam";

# If I have time I will write a smb.conf parsing script to get it from there,
# but don't hold your breath.

# If you are paranoid (like me) and don't trust scripts that delete things
# without testing them first, then set this to one for dry runs.
# This is a good idea the first time you run this script, you may have mistyped
# a directory above...
# This can be 0 for off and 1 for on.
$testing = 0;

# After how many day in the recycle bin should the files be removed?
# Most people seem to think a week is fine.
$maxage = 14;

# The next parameter needs to be set depending on how the recycle system
# handles the dating of the "deleted" files.  Most administrators "touch"
# (update the timestamp) on the files to mark the date they were moved to the
# recycle bin.  This allows you to use scripts such as this to delete them
# later based on thier age.
#
# There are two ways to mark the files that were moved to the recycle bin:
# "recycle:touch  specifies whether a file's access date should be updated when
# the file is moved to the repository.
#   So if you use "recycle:touch = true" then use "atime" below
# "recycle:touch_mtime specifies whether a file's last modified date should be
# updated when the file is moved to the repository.
#   So if you use "recycle:touch_mtime = true" then use "mtime" below
#
# ATTENTION: you must set either the touch or the touch_mtime for each recycle
# entry in smb.conf for this script to work!!!
#
# As most of the tips in the internet use touch, atime is the default.
#$modifiedtime = "mtime";
$modifiedtime = "atime";

# Following is the name of the recycle bin, the default is ".recycle"
# This can be changed with the "recycle:repository = " option in smb.conf
$recyclename = ".recycle";

# Extra messages for each action is printed when "verbose" is on.
# 0 means be quite; 1 means print informative output, 2 means print everything
$verbose = 1;

# ------------------------------------------------------
# END OF CONFIG
# ------------------------------------------------------

print "---> BEGIN: ".(localtime),"\n";

@dirs = split(/:/, $recycledirs);
if ($testing) { $verbose = 2; }

foreach (@dirs) {
 if (! -d $_ ) {
   print "ERROR IN CONFIG OF $0 , this is not a directory: $_\n";
   next;
 }
 $dirpath = "$_/$recyclename";
 if (! -d $_ ) {
   print "ERROR IN CONFIG OF $0 , this not a directory: $dirpath\n";
   next;
 }
 if ($verbose) { print "Processing directory: $dirpath\n"; }


 # Delete all old files older than maxage.
 #`find "$dirpath" -$modifiedtime +$maxage -delete`;
 @a=`find "$dirpath" -$modifiedtime +$maxage`;
 if ($verbose) { $count = 0; print "Deleting files: " };
 $count = 0;
 foreach (@a) {
   chomp($_);
   if ($verbose) { $count++; ($verbose==2 ? print "$_ " : print ".") };
   if (! $testing) {
     unlink($_);
   }
 }
 if ($verbose) { print "\nDeleted $count files.\n" };

 # Delete the empty directories.
 # The mindepth makes sure we do not delete the recycle directory itself.
 # `find "$dirpath" -mindepth 1 -type d -empty -delete`;
 @a=`find "$dirpath" -mindepth 1 -type d -empty | sort -r`;
 foreach (@a) {
   if ($verbose) { print "Deleting empty directory: $_" };
   if (! $testing) {
     chomp($_);
     rmdir ($_);
   }
 }
}
print "---> END: ".(localtime),"\n";

