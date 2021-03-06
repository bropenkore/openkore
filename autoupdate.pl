#!/usr/bin/env perl
#########################################################################
#  This software is open source, licensed under the GNU General Public
#  License, version 2.
#  Basically, this means that you're allowed to modify and distribute
#  this software. However, if you distribute modified versions, you MUST
#  also distribute the source code.
#  See http://www.gnu.org/licenses/gpl.html for the full license.
#
#########################################################################

package autoupdate;
use strict;
use FindBin qw($RealBin);
use lib "$RealBin";
use lib "$RealBin/src";
use lib "$RealBin/src/deps";

use Time::HiRes qw(time usleep);
use Carp::Assert;

# Update base
use SVN::Updater;

sub check_svn_util {
	my $saa = SVN::Updater->new({ path => "."});
	if ($saa->_svn_command("help") == -1) {
		print "Warning!!!!!!!!!!! To use this tool please Install \"Subversion Client\" tools\n";
		sleep (60000);
		return -1;
	};
	return 1;
};

sub upgrade {
	my ($path, $repos_name) = @_;
	
	return unless -d "$path/.svn" && !-l $path;
	
	print "Checking " . $repos_name . " for updates...";
	my $sa = SVN::Updater->load({ path => $path });

	my (undef, $old_version) = $sa->info;
	$sa->update("--force", "--accept", "theirs-conflict");
	my (undef, $new_version) = $sa->info;
	
	if ($old_version == $new_version) {
		print " no updates available\n";
	} else {
		print " updated to r$new_version\n";
	}
};

print "-===================== OpenKore Auto Update tool =====================-\n";
if (check_svn_util() == 1) {
	upgrade("$RealBin", "OpenKore core files");
	upgrade("$RealBin/tables", "OpenKore table data files");
	upgrade("$RealBin/fields", "OpenKore map data files");
	upgrade($_, $_) while <$RealBin/plugins/*>;
};
print "-=========================== Done Updating ===========================-\n\n\n";

# Run main App
my $file = "$RealBin/openkore.pl";
$0 = $file;
FindBin::again();
{
	package main;
	do $file;
}

1;
