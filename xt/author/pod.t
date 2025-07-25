# xt/author/pod.t
# This test ensures that all of our POD is syntactically valid.
use strict;
use warnings;
use Test::More;

eval "use Test::Pod 1.41";
plan skip_all => "Test::Pod 1.41 required for testing POD" if $@;

all_pod_files_ok();

done_testing();

# --------------------------------------------------------------------

# xt/author/pod-coverage.t
# This test checks that we have documentation for all your public subroutines.
use strict;
use warnings;
use Test::More;

eval "use Test::Pod::Coverage 1.08";
plan skip_all => "Test::Pod::Coverage 1.08 required for testing POD coverage" if $@;

# REMINDER: The also_private key can list regexes for functions that are okay to be undocumented.
all_pod_coverage_ok( "Inline::Lua", {
    also_private => [ qr/^(?:main_returns|register_undef|interpreter|destroy|compile|call)$/ ],
} );

done_testing();
