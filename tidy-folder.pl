#!/usr/bin/env perl

use strict;
use warnings;

use File::Path;
use Getopt::Long;
use Pod::Usage;

use TidyFolder qw(
find_bracket_number_files
find_conflict_files
find_conflicted_copy_files
find_ms_office_temporary_files
find_numbered_torrent_files
find_rsync_temporary_files
find_superfluous_ut_files
find_unicode_encoding_conflict_files
find_vim_swp_files
);

my $man  = 0;
my $help = 0;

my ( $directory, $type_of_files, $delete, $print0, $exec );

$directory = '.';
$print0    = 0;
$delete    = 0;
$exec = '';

GetOptions(
    'directory=s'     => \$directory,
    'type-of-files=s' => \$type_of_files,
    'delete'            => \$delete,
    'print0'            => \$print0,
    'exec=s' => \$exec,
    'help|?'            => \$help,
    'man'                 => \$man
); 

pod2usage(1) if $help;
pod2usage( -exitstatus => 0, -verbose => 2 ) if $man or !$type_of_files;

my @files;

if ( $type_of_files eq 'rsync_temporary' ) {
    @files = find_rsync_temporary_files($directory);
} elsif ( $type_of_files eq 'superfluous_ut' ) {
    @files = find_superfluous_ut_files($directory);
} elsif ( $type_of_files eq 'numbered_torrent' ) {
    @files = find_numbered_torrent_files($directory);
} elsif ( $type_of_files eq 'ms_office_temporary' ) {
    @files = find_ms_office_temporary_files($directory);
} elsif ( $type_of_files eq 'conflict' ) {
    @files = find_conflict_files($directory);
} elsif ( $type_of_files eq 'conflicted_copy' ) {
    @files = find_conflicted_copy_files($directory);
} elsif ( $type_of_files eq 'bracket_number' ) {
    @files = find_bracket_number_files($directory);
} elsif ( $type_of_files eq 'unicode_encoding_conflict' ) {
    @files = find_unicode_encoding_conflict_files($directory);
} elsif ( $type_of_files eq 'vim_swp' ) {
    @files = find_vim_swp_files($directory);
} else {
    warn "Unrecognised type of file - '$type_of_files'!\n";
}

if ( scalar(@files) ) {

    if ($exec) {
        foreach my $file (@files) {
            my $c = "$exec \"$file\"";

            print $c, "\n";
            system $c;
        }
    } else {
        my $separator = $print0 ? "\0" : "\n";

        print join $separator, sort(@files);

        print "\n" unless $print0;

        if ($delete) {
            foreach my $file (@files) {
                if ( -f $file ) {
                    unlink $file;
                } elsif ( -d $file ) {
                    rmtree($file);
                } else {
                    warn "Unable to delete $file!\n";
                }
            }

            print "Deleted!\n";
        }
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
        -help	    	brief help message
        -man	     	full documentation

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
    conflict
    bracket_number
    unicode_encoding_conflict
    vim_swp

=item B<--delete>

Delete the files that match the criteria.

=item B<--print0>

Print the file names separated by NUL for xargs -0.

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print the manual page and exit.

=back

=head1 DESCRIPTION

This script is for finding and deleting the files that
are left behind by various programs.

=cut
