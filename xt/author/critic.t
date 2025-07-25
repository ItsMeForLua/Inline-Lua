# xt/author/critic.t
use strict;
use warnings;
use Test::More;

eval "use Test::Perl::Critic";
if ($@) {
    plan skip_all => "Test::Perl::Critic required for testing PBP compliance";
}

all_critic_ok('lib/');

done_testing();
