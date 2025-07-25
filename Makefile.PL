use 5.008008;
use ExtUtils::MakeMaker;
use ExtUtils::Constant qw(WriteConstants);

sub find_lua {
    my $inc = '';
    my $libs = '';
    if ($^O eq 'MSWin32' && $ENV{LUA_INC_PATH} && $ENV{LUA_LIB_PATH}) {
        $inc = "-I$ENV{LUA_INC_PATH}";
        $libs = "-L$ENV{LUA_LIB_PATH} -llua53";
        return ($inc, $libs);
    }
    my @inc_paths = qw(
        /usr/include/lua5.3 
        /usr/local/include/lua5.3 
        /opt/local/include/lua5.3
        /usr/include 
        /usr/local/include
        /opt/local/include
    );
    
    for my $path (@inc_paths) {
        if (-e "$path/lua.h") {
            $inc = "-I$path";
            last;
        }
    }
    $libs = '-llua5.3';
    die "Could not find lua.h. Please install the Lua development libraries (e.g., liblua5.3-dev on Debian/Ubuntu)" unless $inc;
    return ($inc, $libs);
}

my ($LUA_INC, $LUA_LIBS) = find_lua();

sub test_lua_constant {
    my $constant = shift;
    my $test_code = qq{
#include "lua.h"
int main() { 
    int x = $constant; 
    return 0; 
}
};
    open my $fh, '>', 'test_const.c' or return 0;
    print $fh $test_code;
    close $fh;
    
    my $result = system("cc $LUA_INC -c test_const.c -o test_const.o 2>/dev/null") == 0;
    unlink 'test_const.c', 'test_const.o';
    return $result;
}

my @available_constants = (
    'LUA_TNONE', 'LUA_TNIL', 'LUA_TBOOLEAN', 'LUA_TLIGHTUSERDATA', 
    'LUA_TNUMBER', 'LUA_TSTRING', 'LUA_TTABLE', 'LUA_TFUNCTION', 
    'LUA_TUSERDATA', 'LUA_TTHREAD',
    'LUA_REGISTRYINDEX', 'LUA_MULTRET'
);

my @optional_constants = qw(LUA_OK LUA_YIELD LUA_ERRRUN LUA_ERRSYNTAX LUA_ERRMEM LUA_ERRGCMM LUA_ERRERR);
for my $const (@optional_constants) {
    if (test_lua_constant($const)) {
        push @available_constants, { name => $const, macro => 1 };
    } else {
        warn "Warning: $const not available in this Lua installation\n";
    }
}

WriteConstants(
    NAME         => 'Inline::Lua',
    NAMES        => \@available_constants,
    DEFAULT_TYPE => 'IV',
    C_FILE       => 'const-c.inc',
    XS_FILE      => 'const-xs.inc',
);

WriteMakefile(
    NAME              => 'Inline::Lua',
    VERSION_FROM      => 'lib/Inline/Lua.pm', 
    PREREQ_PM         => {
        'perl'              => '5.8.8',
        'Inline'            => '0.80',
        'Test::Exception'   => 0,
        'Test::More'        => 0,
        'ExtUtils::Constant'=> 0,
    },
    ABSTRACT_FROM     => 'lib/Inline/Lua.pm',
    AUTHOR            => 'Andrew D. France <andrewforlua@gmail.com>',
    LICENSE           => 'perl_5',
    
    LIBS              => [$LUA_LIBS],
    DEFINE            => '', 
    INC               => "-I. $LUA_INC",
    OBJECT            => '$(O_FILES)', 
    test              => { TESTS => 't/*.t' },
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
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Inline-Lua-* const-c.inc const-xs.inc' },
);

sub MY::postamble {
'
test-author :
	$(NOECHO) $(ECHO) "Running author tests..."
	$(NOECHO) prove -lvr xt/author
'
}
