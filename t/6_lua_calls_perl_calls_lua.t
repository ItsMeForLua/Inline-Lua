#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 1;
use Inline::Lua;

my $lua = Inline::Lua->new(DATA => \*DATA);

# Bind the Perl sub into Lua
$lua->set('perl_curry', \&curry);

# Call Lua function that uses it
is($lua->call('lua_curry', \&curry, 6, 7), 42, 'currying works');

sub curry {
    my $arg = shift;
    return sub {
        return $arg * shift;
    };
}

__DATA__
__Lua__
function lua_curry (f, a, b)
    local g = f(a)
    return g(b)
end
