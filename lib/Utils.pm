# (c) mhasbini 2016
package Utils;
use strict;
use warnings;
use Data::Dumper;
use Digest::MD5 qw/md5_hex/;
use utf8;
use Encode;

sub new {
	my $class = shift;
	my %parm  = @_;
	my $this  = {};
	bless $this, $class;
	return $this;
}

sub generate_id {
	my $self = shift;
	my @status = @{ shift; };
	my $str = '';
	foreach my $status (@status) {
		my %pos = %{ $status->{pos} };
		foreach my $pos (sort {$a <=> $b} keys %pos) {
			$str .= $pos;
			$str .= $pos{$pos}->{ascii_shift}{'l'};
			$str .= $pos{$pos}->{ascii_shift}{'u'};
			$str .= $pos{$pos}->{ascii_shift}{'d'};
			$str .= $pos{$pos}->{bitwize_shift}{'l'};
			$str .= $pos{$pos}->{bitwize_shift}->{'u'};
			$str .= $pos{$pos}->{bitwize_shift}->{'d'};
			$str .= $pos{$pos}->{case};
			$str .= $pos{$pos}->{element};
			$str .= $pos{$pos}->{value};
		}
		if(defined $status->{deleted_chars}) {
			foreach my $key (sort keys %{$status->{deleted_chars}}) {
				$str .= "deleted_key:$key";
			}
		}
		if (defined $status->{substitution}) {
			my %substitution = %{ $status->{substitution} };
			foreach my $key (sort keys %substitution) {
				$str .= $key.$substitution{$key}{'c'};
				foreach my $s_key (qw/ascii_shift bitwize_shift/) {
					foreach my $n (sort {$a <=> $b} keys %{$substitution{$key}{$s_key}}) {
						$str .= $substitution{$key}{$s_key}{$n}{'l'};
						$str .= $substitution{$key}{$s_key}{$n}{'u'};
						$str .= $substitution{$key}{$s_key}{$n}{'d'};
					}
				}
				foreach my $n (sort {$a <=> $b} keys %{$substitution{$key}{'case'}}) {
					$str .= $substitution{$key}{'case'}{$n};
				}
			}
		}
	}
	return md5_hex(utf8::is_utf8($str) ? Encode::encode_utf8($str) : $str);
}

sub is_supported {
	my $self = shift;
	my $rule = shift;
	my $validate_regex = q!\*[0-9A-Za-z][0-9A-Za-z]|x[0-9A-Za-z][0-9A-Za-z]|i[0-9A-Za-z].|O[0-9A-Za-z][0-9A-Za-z]|o[0-9A-Za-z].|s..|L[0-9A-Za-z]|R[0-9A-Za-z]|\+[0-9A-Za-z]|-[0-9A-Za-z]|\.[0-9A-Za-z]|,[0-9A-Za-z]|y[0-9A-Za-z]|Y[0-9A-Za-z]|T[0-9A-Za-z]|p[0-9A-Za-z]|D[0-9A-Za-z]|'[0-9A-Za-z]|z[0-9A-Za-z]|Z[0-9A-Za-z]|\$.|\^.|\@.|:|l|u|c|C|t|r|d|f|{|}|\[|\]|q|k|K|\s!;
	$rule =~ s/$validate_regex//g;
	return length($rule) == 0 ? 1 : 0;
}

1;
