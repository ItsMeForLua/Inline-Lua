use 5.008008;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

# --- Helper function to find Lua ---
# This is a simple check.
# Maybe Devel::CheckLib or ExtUtils::PkgConfig in the future.
sub find_lua {
    my $inc = '';
    my $libs = '';

    # Handle Windows CI environment variables first
    if ($^O eq 'MSWin32' && $ENV{LUA_INC_PATH} && $ENV{LUA_LIB_PATH}) {
        $inc = "-I$ENV{LUA_INC_PATH}";
        $libs = "-L$ENV{LUA_LIB_PATH} -llua53"; # Assuming lua53.lib
        return ($inc, $libs);
    }

    # Common paths for Unix-like systems
    my @inc_paths = qw(/usr/include/lua5.3 /usr/local/include/lua5.3 /usr/include /usr/local/include);
    
    # Find include path
    for my $path (@inc_paths) {
        if (-e "$path/lua.h") {
            $inc = "-I$path";
            last;
        }
    }

    # NOTE: On most systems, just linking -llua5.3 is enough if it's in the standard path.
    $libs = '-llua5.3';

    # If lua.h wasn't found, the build can't proceed.
    die "Could not find lua.h. Please install the Lua development libraries (e.g., liblua5.3-dev on Debian/Ubuntu)" unless $inc;

    return ($inc, $libs);
}

my ($LUA_INC, $LUA_LIBS) = find_lua();

WriteMakefile(
    NAME              => 'Inline-Lua',
    # This will read the version from the $VERSION variable in the .pm file
    VERSION_FROM      => 'lib/Inline/Lua.pm', 
    PREREQ_PM         => {
        'perl'            => '5.8.8',
        'Inline'          => '0.80', #
        'Test::Exception' => 0,
        'Test::More'      => 0,
    },
    # This will read the abstract from the POD in the .pm file
    ABSTRACT_FROM     => 'lib/Inline/Lua.pm',
    AUTHOR            => 'Andrew D. France <andrewforlua@gmail.com>',
    LICENSE           => 'perl_5',
    
    # --- XS Configuration ---
    LIBS              => [$LUA_LIBS],
    DEFINE            => '', 
    INC               => $LUA_INC,
    # This tells MakeMaker to look for *.c and *.xs files
    OBJECT            => '$(O_FILES)', 

    # --- For CPAN Testers ---
    test              => { TESTS => 't/*.t' },

    # --- For META files (used by CPAN toolchains) ---
    META_MERGE => {
        'meta-spec' => { version => 2 },
        'resources' => {
            repository => {
                type => 'git',
                url  => 'https://github.com/ItsMeForLua/Inline-Lua.git',
                web  => 'https://github.com/ItsMeForLua/Inline-Lua',
            },
            bugtracker => {
                web => 'https://github.com/ItsMeForLua/Inline-Lua/issues',
            },
        },
        'x_authority' => 'cpan:MEFORLUA',
    },

    # --- For `make dist` command ---
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Inline-Lua-*' },
);

sub MY::postamble {
'
test-author :
	$(NOECHO) $(ECHO) "Running author tests..."
	$(NOECHO) prove -lvr xt/author
'
}
