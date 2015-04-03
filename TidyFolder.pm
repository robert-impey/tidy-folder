package TidyFolder;

use strict;
use warnings;

use File::Find::Rule;

use base 'Exporter';
our @EXPORT_OK = qw(
  find_rsync_temporary_files
  find_superfluous_ut_files
  find_numbered_torrent_files
  find_ms_office_temporary_files
  find_conflict_files
  find_bracket_number_files
);

sub find_files_matching_sub {
	my $directory    = shift;
	my $criteria_sub = shift;

	my @files;

	foreach ( File::Find::Rule->directory->in($directory) ) {
		my $cur_dir = $_;
		if ( chdir $cur_dir ) {
			foreach ( glob('.* *') ) {
				if ( -f $_ || -d $_) {
					my $matching_file = &$criteria_sub( $_, $cur_dir );
					if ($matching_file) {
						push @files, $matching_file;
					}
				}
			}
		}
		else {
			warn $!;
			warn "Can't chdir to $cur_dir\n";
		}
	}

	return @files;
}

sub find_rsync_temporary_files {
	my $directory = shift;

	return find_files_matching_sub(
		$directory,
		sub {
			my $file    = shift;
			my $cur_dir = shift;

			if ( $file =~ /^\.(.*)\.[a-z0-9]{6}$/i ) {
				if ( -f "$cur_dir/$1" ) {
					return "$cur_dir/$file";
				}
			}
		}
	);
}

sub find_superfluous_ut_files {
	my $directory = shift;

	return find_files_matching_sub(
		$directory,
		sub {
			my $file    = shift;
			my $cur_dir = shift;

			if ( $file =~ /^(.*)\.!ut$/i ) {
				if ( -f "$cur_dir/$1" ) {
					return "$cur_dir/$file";
				}
			}
		}
	);
}

sub find_numbered_torrent_files {
	my $directory = shift;

	return find_files_matching_sub(
		$directory,
		sub {
			my $file    = shift;
			my $cur_dir = shift;

			if ( $file =~ /^(.*)\.(\d+)\.torrent$/i ) {
				if ( -f "$cur_dir/$1.torrent" ) {
					return "$cur_dir/$file";
				}
			}
		}
	);
}

sub find_ms_office_temporary_files {
	my $directory = shift;

	return find_files_matching_sub(
		$directory,
		sub {
			my $file    = shift;
			my $cur_dir = shift;

			if ( $file =~ /\w{2}(.*\.(?:doc|xls|ppt)[xm]?)/i ) {
				my $temp_file = '~$' . $1;
				if ( -f $temp_file ) {
					return "$cur_dir/$temp_file";
				}
			}
		}
	);
}

sub find_conflict_files {
	my $directory = shift;

	return find_files_matching_sub(
		$directory,
		sub {
			my $file    = shift;
			my $cur_dir = shift;

			if ( $file =~ /(.+)\[Conflict(?: \d+)?\](.*)/ ) {
				my $origingl_file = "$1$2";

				if ( -f $origingl_file || -d $origingl_file) {
					return "$cur_dir/$file";
				}
			}
		}
	);
}

sub find_bracket_number_files {

	my $directory = shift;

	return find_files_matching_sub(
		$directory,
		sub {
			my $file    = shift;
			my $cur_dir = shift;

			if ( $file =~ /(.+?)\s*\(\d+\)(.*)/ ) {
				my $origingl_file = "$1$2";

				if ( -f $origingl_file || -d $origingl_file) {
					return "$cur_dir/$file";
				}
			}
		}
	);
}

1;
