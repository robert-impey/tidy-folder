#!/usr/bin/tclsh

set results [exec perl tidy-folder.pl -t conflicted_copy --dir fixtures/conflicted_copy]

if { $results == "fixtures/conflicted_copy/foo (bar's conflicted copy 2016-06-13).txt" } {
    puts "ok"
} else {
    puts "not ok"
}

