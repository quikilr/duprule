use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib/";
use DupRules;
use Utils;
use Getopt::Std;

my %args;
getopts('o:h', \%args);

if (defined $args{h}) {
	print qq{Usage: perl $0 [options] < input_rules > uniq_rules
	options:
		-o\t optional\t file to write duplicate rules to
		-h\t optional\t print this help message};
	exit 0;
}

my @rules;
my $util = Utils->new();

while (my $rule = <STDIN>) {
	chomp $rule;
	if ($util->is_supported($rule)) {
		push @rules, $rule;
	}else{
		print $rule, "\n";
	}
}

my $DupRules = DupRules->new();

my ($uniq, $duplicates) = $DupRules->duprule(\@rules);


if (defined $args{o}) {
	open my $out, '>', $args{o} or die $!;
	flock $out, 2; # lock file
	foreach my $dup (@{$duplicates}) {
		print $out join(', ', @{$dup}), "\n";
	}
	close $out; # unlock and close
}

foreach my $rule (@{$uniq}) {
	print $rule, "\n";
}
