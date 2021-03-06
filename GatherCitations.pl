#!/usr/bin/env perl6

use JSON::Fast;

my $projectsfile = 'projects.txt';
my %citing;
%citing<__date> = DateTime.new(now).Str;
say "Downloading projects file";

update $projectsfile, "./archive/projects_{ %citing<__date> }.txt";

my $list = try from-json( $projectsfile.IO.slurp) ;
if $! {
	die "Cannot parse $projectsfile as JSON: $!";
}
my $c = 0;

for $list.list -> $mod {
	unless %citing{$mod<name>}:exists and %citing{$mod<name>} gt $mod<version> {
		%citing{$mod<name>} = {};
		with $mod<depends> {
			for $mod<depends>.flat { %citing{$mod<name>}{$_} = $mod<version> }
		}
	}
}

say "\nCitation data gathered. Stored in './archive/CitationData_{%citing<__date>}.json'. Use CitationAnalyse.pl to process.";

"./archive/CitationData_{%citing<__date>}.json".IO.spurt: to-json(%citing);


sub update ($projectsfile, $store) {
        try unlink $projectsfile;
        my $url = 'http://ecosystem-api.p6c.org/projects.json';
        my $s;
        use HTTP::UserAgent;
        my $ua = HTTP::UserAgent.new;
        my $response = $ua.get($url);
        $projectsfile.IO.spurt: $response.decoded-content;
        $store.IO.spurt: $response.decoded-content;
    
        CATCH {
            die "Could not download module metadata: {$_.message}"
        }
    }

