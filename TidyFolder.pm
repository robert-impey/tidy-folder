package TidyFolder;

use strict;
use warnings;

use File::Find::Rule;
use File::Spec;

use base 'Exporter';
our @EXPORT_OK = qw(
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

sub find_files_matching_sub {
    my $directory    = shift;
    my $criteria_sub = shift;

    my @files;

    foreach ( File::Find::Rule->directory->in($directory) ) {
        my $cur_dir = $_;
        if ( chdir $cur_dir ) {
            foreach ( glob('.* *') ) {
                if ( -f $_ || -d $_ ) {
                    my $matching_file = &$criteria_sub( $_, $cur_dir );
                    if ($matching_file) {
                        push @files, File::Spec->canonpath($matching_file);
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

# Created by rsync
# Left behind when two processes try to sync one directory.
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

# Created by UTorrent
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

# Created by deluge
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

# Left behind when synching a folder
# with an open Microsoft Office file
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

# Dropbox
sub find_conflict_files {
    my $directory = shift;

    return find_files_matching_sub(
        $directory,
        sub {
            my $file    = shift;
            my $cur_dir = shift;

            # todo (hiroko's conflicted copy 2016-10-31).txt
            if ( $file =~
                /(.+) \([\.\w]+'s conflicted copy \d{4}-\d{2}-\d{2}\)(.*)/ )
            {
                my $original_file = "$1$2";

                if ( -f $original_file || -d $original_file ) {
                    return "$cur_dir/$file";
                }
            }
        }
    );
}

# Created by Dropbox
sub find_conflicted_copy_files {
    my $directory = shift;

    return find_files_matching_sub(
        $directory,
        sub {
            my $file    = shift;
            my $cur_dir = shift;

            if ( $file =~
/(.+) \(\w+'s conflicted copy (?:\d{4}-\d{2}-\d{2})(?:\s*\(\d+\))?\)(.*)/
              )
            {
                my $original_file = "$1$2";

                if ( -f $original_file || -d $original_file ) {
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
                my $original_file = "$1$2";

                if ( -f $original_file || -d $original_file ) {
                    return "$cur_dir/$file";
                }
            }
        }
    );
}

# Created by Dropbox
sub find_unicode_encoding_conflict_files {
    my $directory = shift;

    return find_files_matching_sub(
        $directory,
        sub {
            my $file    = shift;
            my $cur_dir = shift;

            if ( $file =~
                /^(.*) \(Unicode Encoding Conflict(?: \(\d+\))?\)\.(\w+)$/ )
            {
                if ( -f "$cur_dir/$1.$2" ) {
                    return "$cur_dir/$file";
                }
            }
        }
    );
}

sub find_vim_swp_files {
    my $directory = shift;

    return find_files_matching_sub(
        $directory,
        sub {
            my $file    = shift;
            my $cur_dir = shift;

            if ( $file =~ /\.(.+)\.swp/ ) {
                my $original_file = "$1";

                if ( -f $original_file ) {
                    return "$cur_dir/$file";
                }
            }
        }
    );
}

1;
