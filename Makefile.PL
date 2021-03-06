use strict;
use warnings;
use ExtUtils::MakeMaker 6.48;
use 5.006;

sub parseversion
{
    my $version;
    open GP, 'lib/PDL/Transform/Color.pm' or die "Couldn't open Color.pm";
    for(<GP>){
        if(m/our \$VERSION = \'([\d\.\_]+b?)\'/) {$version = $1;}
        last if($version);
    }
    die "Couldn't parse version from Color.pm" unless($version);
    close GP;
    return $version;
}


sub MY::libscan {
    package MY;

    my ($self, $file) = @_;

    # Don't install the README.pod or any .pl file
    return undef if $file =~ /\.pl$|^README.pod/;

    return $self->SUPER::libscan ($file);
}


sub MY::postamble {
    my $text = <<'FOO';
install ::
	@echo "Updating PDL documentation database...";
	@$(PERL) -e "exit if $$ENV{DESTDIR}; use PDL::Doc; eval { PDL::Doc::add_module(q{PDL::Trasform::Color}); }; ";

FOO
    return $text;
}


WriteMakefile(
    NAME                      => 'PDL::Transform::Color',
    AUTHOR                    => 'Craig DeForest <craig@deforest.org>',
    VERSION                   => parseversion(),
    ABSTRACT_FROM             => 'lib/PDL/Transform/Color.pm',
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002
        ? ('LICENSE'          => 'perl')
        : ()
    ),
    MIN_PERL_VERSION          => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 6.48,
    },
    PREREQ_PM => { 
        'PDL'                 => 0,
        'PDL::MatrixOps'      => 0,
	'PDL::Transform'      => 0,
        'Safe::Isa'           => 0
    },
    META_ADD => {
        resources => {
            homepage          => 'http://github.com/drzowie/PDL-Transform-Color',
            repository        => 'git://github.com/drzowie/PDL-Transform-Color.git',
            bugtracker        => 'http://rt.cpan.org/Public/Dist/Display.html?Name=PDL-Transform-Color'
        }
    },  

    dist                      => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean                     => { FILES => 'PDL-Transform-Color-* pdl_transform_color_test_* *~' },
  );

# reroute the main POD into a separate README.pod if requested. This is here
# purely to generate a README.pod for the github front page
my $POD_header = <<EOF;
=head1 OVERVIEW

This module provides transformations for manipulating color.  This repository 
stores the history for the PDL::Transform::Color module on CPAN. 

=cut

EOF


if(exists $ARGV[0] && $ARGV[0] eq 'README.pod')
{
    open MOD, 'lib/PDL/Transform/Color.pm ' or die "Couldn't open main module";
    open README, '>README.pod'              or die "Couldn't open README.pod";

    print README $POD_header;

    while (<MOD>)
    {
        if (/^=/../^=cut/) { print README; }
    }
}

