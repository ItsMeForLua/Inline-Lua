#!/usr/bin/env perl
use strict;
use warnings;

use Inline Lua => <<'END_LUA';

function lua_curry(f, a, b)
  local g = f(a)
  return g(b)
end

END_LUA

use Test::More tests => 1;

sub curry {
  my $arg = shift;
  return sub {
    return $arg * shift;
  };
}

is(lua_curry(\&curry, 6, 7), 42, 'currying works');
