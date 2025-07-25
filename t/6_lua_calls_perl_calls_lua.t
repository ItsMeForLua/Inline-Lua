#!/usr/bin/env perl

use strict;
use warnings;

use Inline 'Lua';
use Test::More tests => 1;

# This sub is called from the Lua code below
sub curry {
    my $arg = shift;
    return sub {
        return $arg * shift;
    };
}

# The test now calls the Lua function directly
is(lua_curry(\&curry, 6, 7), 42, 'currying works');

__DATA__
__Lua__
function lua_curry (f, a, b)
    local g = f(a)
    return g(b)
end
