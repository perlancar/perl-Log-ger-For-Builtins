package Log::ger::For::Builtins;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict 'subs', 'vars';
use warnings;
use Log::ger;

use Data::Dmp ();

our %SUPPORTED = (
    # func => [code or target sub, bool log_result]

    readpipe    => ["CORE::readpipe", 1],
    rename      => ["CORE::rename", 1],
    system      => [sub { system(@_) }, 1],
);

sub import {
    my $package = shift;

    my $caller = caller(0);
    for my $func (@_) {
        die "Exporting '$func' is not supported"
            unless grep { $func eq $_ } keys %SUPPORTED;
        *{"$caller\::$func"} = sub {
            my ($code_or_subname, $log_result) = @{ $SUPPORTED{$func} };
            my $wantarray = wantarray();

            log_trace "-> %s(%s)", $func, join(", ", map {Data::Dmp::dmp($_)} @_);

            my $res;
            if (ref $code_or_subname eq 'CODE') {
                if ($wantarray) { $res = [$code_or_subname->(@_)]  } else { $res = $code_or_subname->(@_) }
            } else {
                if ($wantarray) { $res = [&{$code_or_subname}(@_)] } else { $res = &{$code_or_subname}(@_) }
            }

            log_trace "<- %s%s", $func, $log_result ? " = ".($wantarray ? "(".join(", ", map {Data::Dmp::dmp($_)} @$res).")" : Data::Dmp::dmp($res)) : " (result not logged)";
            $wantarray ? @$res : $res;
        };
    }
}

1;
# ABSTRACT: Add logging to Perl builtins

=head1 SYNOPSIS

 use Log::ger::For::Builtins qw(
     readpipe
     rename
     system
 );


=head1 DESCRIPTION

This module exports wrappers for Perl builtins with added logging. Logging is
produced using L<Log::ger> at the trace level and can be seen by using one of
output plugins e.g. L<Log::ger::Output::Screen>.


=head1 SEE ALSO

L<Log::ger>
