#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use feature "switch";
use File::Path;

use TidyFolder qw(
	find_rsync_temporary_files
	find_superfluous_ut_files
	find_numbered_torrent_files
	find_ms_office_temporary_files
);

my $man = 0;
my $help = 0;

my ($directory, $type_of_files, $delete);

$directory = '.';
$delete = 0;

GetOptions(
    'd|directory:s' => \$directory,
	't|type-of-files:s' => \$type_of_files,
	'delete' => \$delete,
    'help|?' => \$help,
	man => \$man
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

my @files;

given ($type_of_files) {
	when ('rsync_temporary') {
		@files = find_rsync_temporary_files($directory);
	} when ('superfluous_ut') {
		@files = find_superfluous_ut_files($directory);
	} when ('numbered_torrent') {
		@files = find_numbered_torrent_files($directory);
	} when ('ms_office_temporary') {
		@files = find_ms_office_temporary_files($directory);
	} default {
		warn "Unrecognised type of file!\n";
		pod2usage(-exitstatus => 0, -verbose => 2) if $man;
	}
}

if (scalar(@files)) {
    print join "\n", sort(@files), "\n";
	
	if ($delete) {
		foreach my $file (@files) {
			if (-f $file) {
				unlink $file;
			} elsif (-d $file) {
				rmtree($file);
			} else {
				warn "Unable to delete $file!\n";
			}
		}
		
		print "Deleted!\n";
	}
}

__END__

=head1 NAME

    tidy-folder.pl

=head1 SYNOPSIS

    tidy-folder.pl -d C:\foo -t some_type
    Options:
		-d|directory		The directory to search
		-t|type-of-files	The type of files
		--delete			Delete the found files
		-help            	brief help message
		-man             	full documentation

=head1 OPTIONS

=over 8

=item B<-d|--directory>

The name of the directory to search.

=item B<-t|--type-of-files>

The type of files to search for.

Possibly:
	rsync_temporary
	superfluous_ut
	numbered_torrent
	ms_office_temporary
	
=item B<--delete>

Delete the files that match the criteria.

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

This script is for finding and deleting the files that
are left behind by various programs.

=cut
