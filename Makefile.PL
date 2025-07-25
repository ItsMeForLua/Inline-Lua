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

WriteConstants(
    NAME         => 'Inline::Lua',
    NAMES        => [
        { name => 'LUA_OK',         macro => 1 },
        { name => 'LUA_YIELD',      macro => 1 },
        { name => 'LUA_ERRRUN',     macro => 1 },
        { name => 'LUA_ERRSYNTAX',  macro => 1 },
        { name => 'LUA_ERRMEM',     macro => 1 },
        { name => 'LUA_ERRGCMM',    macro => 1 },
        { name => 'LUA_ERRERR',     macro => 1 },
        'LUA_TNONE', 'LUA_TNIL', 'LUA_TBOOLEAN', 'LUA_TLIGHTUSERDATA', 
        'LUA_TNUMBER', 'LUA_TSTRING', 'LUA_TTABLE', 'LUA_TFUNCTION', 
        'LUA_TUSERDATA', 'LUA_TTHREAD',
        'LUA_REGISTRYINDEX', 'LUA_MULTRET'
    ],
    DEFAULT_TYPE => 'IV',
    C_FILE       => 'const-c.inc',
    XS_FILE      => 'const-xs.inc',
);

WriteMakefile(
    NAME              => 'Inline-Lua',
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
