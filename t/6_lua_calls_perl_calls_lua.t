#!/usr/bin/env perl

use strict;
use warnings;
# use feature 'say'; # Removed for 5.8 compatibility

use Inline 'Lua';

use Test::More tests => 1;

my $code = <<'EOLUA';
function lua_curry (f, a, b)
    local g = f(a)
    return g(b)
end
EOLUA

my $curry = Inline::Lua->new($code);

sub curry {
    my $arg = shift;
    return sub {
        # The original "say" module is now replaced with a more portable and backwards compatible "print"
        return $arg * shift;
    };
}

is($curry->lua_curry(\&curry, 6, 7), 42, 'currying works');
