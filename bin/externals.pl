#!/usr/bin/perl

# Checkout or update remote dependencies.  This script uses relative paths, so
# only run this from directly within the .emacs.d directory!

use warnings;
use strict;

use File::Basename;
use Cwd;

our @externals = (
    {
        path   => 'elisp/elpa-emacs23',
        vcs    => 'wget',
        repo   => 'http://bit.ly/pkg-el23',
    },
    {
        path   => 'elisp/evil',
        vcs    => 'git',
        repo   => 'git://gitorious.org/evil/evil.git',
        branch => 'master',
    },
    {
        path   => 'elisp/ecb',
        vcs    => 'cvs',
        repo   => ':pserver:anonymous@ecb.cvs.sourceforge.net:/cvsroot/ecb ecb',
        branch => 'trunk',
    },
    {
        path   => 'elisp/auto-complete',
        vcs    => 'git',
        repo   => 'git://github.com/m2ym/auto-complete.git',
        branch => 'master',
    },
    {
        path   => 'elisp/ess',
        vcs    => 'svn',
        repo   => 'https://svn.r-project.org/ESS/trunk',
    },
    {
        path   => 'elisp/clojure-mode',
        vcs    => 'git',
        repo   => 'git://github.com/technomancy/clojure-mode.git',
        branch => 'master',
    },
    {
        path   => 'elisp/haskellmode-emacs',
        vcs    => 'git',
        repo   => 'git://github.com/haskell/haskell-mode.git',
        branch => 'master',
    },
    {
        path   => 'elisp/tuareg-mode',
        vcs    => 'svn',
        repo   => 'svn://svn.forge.ocamlcore.org/svn/tuareg/trunk',
    },
    {
        path   => 'elisp/python',
        vcs    => 'git',
        repo   => 'https://github.com/fgallina/python.el.git',
        branch => 'emacs23',
    },
    {
        path   => 'elisp/pymacs',
        vcs    => 'git',
        repo   => 'git://github.com/pinard/Pymacs.git',
        branch => 'master',
    },
    {
        path   => 'elisp/org-mode',
        vcs    => 'git',
        repo   => 'git://orgmode.org/org-mode.git',
        branch => 'maint',
    },
    {
        path   => 'elisp/gnus',
        vcs    => 'git',
        repo   => 'http://git.gnus.org/gnus.git',
        branch => 'master',
    },
    {
        path   => 'elisp/slime',
        vcs    => 'cvs',
        repo   => ':pserver:anonymous:anonymous@common-lisp.net:/project/slime/cvsroot slime',
        branch => 'trunk',
    },
    {
        path   => 'elisp/swank-chicken',
        vcs    => 'git',
        repo   => 'git://github.com/nickg/swank-chicken.git',
        branch => 'master',
    },
    {
        path   => 'elisp/cperl-mode',
        vcs    => 'git',
        repo   => 'git://github.com/jrockway/cperl-mode.git',
        branch => 'perl6-pugs',
    },
    {
        path   => 'elisp/emacs_chrome',
        vcs    => 'git',
        repo   => 'git://github.com/stsquad/emacs_chrome.git',
        branch => 'master',
    },
    {
        path   => 'elisp/yasnippet',
        vcs    => 'svn',
        repo   => 'http://yasnippet.googlecode.com/svn/trunk/',
    },
    {
        path   => 'elisp/scala-mode',
        vcs    => 'svn',
        repo   => 'http://lampsvn.epfl.ch/svn-repos/scala/scala-tool-support/trunk/src/emacs/',
    },
    {
        path   => 'elisp/lua',
        vcs    => 'git',
        repo   => 'git://github.com/immerrr/lua-mode.git',
        branch => 'master',
    },
    {
        path   => 'elisp/android-mode',
        vcs    => 'git',
        repo   => 'git://github.com/remvee/android-mode.git',
        branch => 'master',
    },
    {
        path   => 'elisp/multi-web-mode',
        vcs    => 'git',
        repo   => 'https://github.com/fgallina/multi-web-mode.git',
        branch => 'master',
    },
    {
        path   => 'elisp/nxhtml',
        vcs    => 'bzr',
        repo   => 'https://code.launchpad.net/~nxhtml/nxhtml/main',
    },
    {
        path   => 'elisp/rudel',
        vcs    => 'bzr',
        repo   => 'bzr://rudel.bzr.sourceforge.net/bzrroot/rudel/trunk',
    },
    {
        path   => 'elisp/magit',
        vcs    => 'git',
        repo   => 'git://github.com/magit/magit.git',
        branch => 'master',
    },
    {
        path   => 'elisp/git-modes',
        vcs    => 'git',
        repo   => 'git://github.com/magit/git-modes.git',
        branch => 'master',
    },
    {
        path   => 'elisp/egg',
        vcs    => 'git',
        repo   => 'git://github.com/byplayer/egg.git',
        branch => 'master',
    },
    {
        path   => 'elisp/monky',
        vcs    => 'git',
        repo   => 'git://github.com/ananthakumaran/monky.git',
        branch => 'master',
    },
    {
        path   => 'elisp/color-theme-solarized',
        vcs    => 'git',
        repo   => 'git://github.com/sellout/emacs-color-theme-solarized.git',
        branch => 'master',
    },
    {
        path   => 'elisp/color-theme-wombat',
        vcs    => 'git',
        repo   => 'git://github.com/jasonblewis/color-theme-wombat.git',
        branch => 'master',
    },
    {
        path   => 'elisp/nyan-mode',
        vcs    => 'git',
        repo   => 'git://github.com/TeMPOraL/nyan-mode.git',
        branch => 'master',
    },
);

my @dirstack = ();

sub pushd {
    my ($newpath) = @_;
    push @dirstack, getcwd;
    chdir $newpath;
}

sub popd {
    my $oldpath = pop @dirstack;
    chdir $oldpath if ( $oldpath );
}

sub vcs_cvs_checkout {
    my ($path, $repo, $branch) = @_;

    my @repo_words = split(/ /, $repo);
    my $cvsroot = $repo_words[0];
    my $module = $repo_words[1];

    my $branchopt = ( $branch eq 'trunk' ) ? "" : "-r ${branch}";

    my $ppath = dirname($path);
    mkdir $ppath unless ( -d $ppath );
    pushd($ppath);
    `cvs -d ${cvsroot} checkout -P ${branchopt} ${module}`;
    popd();
}

sub vcs_cvs_update {
    my ($path, $repo, $branch) = @_;

    my @repo_words = split(/ /, $repo);
    my $cvsroot = $repo_words[0];
    my $module = $repo_words[1];

    pushd($path);
    `cvs update -Pd`;
    popd();
}

sub vcs_svn_checkout {
    my ($path, $repo) = @_;

    `svn checkout "${repo}" "${path}"`;
}

sub vcs_svn_update {
    my ($path, $repo) = @_;

    pushd($path);
    `svn update`;
    popd();
}

sub vcs_darcs_checkout {
    my ($path, $repo, $branch) = @_;

    `darcs get "${repo}" "${path}"`;
}

sub vcs_darcs_update {
    my ($path, $repo, $branch) = @_;

    pushd($path);
    `darcs pull`;
    popd();
}

sub vcs_bzr_checkout {
    my ($path, $repo) = @_;

    `bzr branch "${repo}" "${path}"`;
}

sub vcs_bzr_update {
    my ($path, $repo) = @_;

    pushd($path);
    `bzr pull`;
    popd();
    print "\n";
}

sub vcs_git_checkout {
    my ($path, $repo, $branch) = @_;

    my $branchopt = $branch ? "-b ${branch}" : "";

    `git clone ${branchopt} "${repo}" "${path}"`;
}

sub vcs_git_update {
    my ($path, $repo, $branch) = @_;

    pushd($path);
    if ( -d ".git" ) {
        `git pull origin ${branch}`;
    }
    popd();
}

sub vcs_wget_checkout {
    my ($path, $repo) = @_;

    mkdir($path);
    pushd($path);
    `wget ${repo}`;
    popd();
}

sub vcs_wget_update {
    my ($path, $repo) = @_;
    vcs_wget_checkout($path, $repo);
}

sub get_vcs_cmd {
    my ($vcs, $cmd) = @_;

    my $fname = "vcs_${vcs}_${cmd}";
    if ( defined &$fname ) {
        return \&$fname;
    }
    else {
        return 0;
    }
}

if ( $^O eq 'MSWin32' ) {
    print <<"EOF";

WARNING: Checking out from remote CVS repositories using CVSNT can cause
things to blow up.  In particular, CVSNT mangles the line endings in
checkouts from the Slime repository, resulting in errors in the Emacs
startup script.

If possible, run this script from within Cygwin instead.
EOF
}

my $command = shift @ARGV || '';
if ( $command eq 'checkout' || $command eq 'co' ) {
    print <<"EOF";

### Optional external Emacs resources ###

Externals marked with [i] are alread installed.  Enter an external's number to
mark it for installation, then type x to checkout marked externals or q to
quit without applying any changes.
EOF
    do {
        # Show externals menu
        print "\n";
        for ( my $i = 0; $i <= $#externals; $i++ ) {
            my $ext = $externals[$i];
            my $flag = ( -d $ext->{path} ) ? 'i' :
                    ( exists $ext->{install} ? '+' : ' ' );
            printf "%2d. [%s] %s (%s)\n", $i+1, $flag, $ext->{path},
                    ( exists $ext->{branch} ? $ext->{vcs} . ' ' . $ext->{branch}
                              : $ext->{vcs} );
        }

        # Prompt for input
        print "\next> ";
        my $cmd = <STDIN>;
        chomp $cmd;

        # Process input
        if ( lc($cmd) eq 'q' ) {
            # Quit
            exit 0;
        } elsif ( lc($cmd) eq 'x' ) {
            # Install marked externals
            for my $ext ( @externals ) {
                if ( exists $ext->{install} ) {
                    print "\n### Checking out " . $ext->{path} . " ###\n";
                    my $fun = get_vcs_cmd($ext->{vcs}, 'checkout');
                    if ( $fun ) {
                        &$fun($ext->{path}, $ext->{repo}, $ext->{branch});
                    } else {
                        print "Error: No checkout function for "
                                . $ext->{vcs} . ".\n";
                    }
                }
            }
            exit 0;
        } elsif ( $cmd =~ m/^[1-9]\d*$/o && $cmd <= $#externals + 1 ) {
            # Toggle mark on non-installed external
            my $ext = $externals[$cmd-1];
            if ( -d $ext->{path} ) {
                print "\nThe external " . $ext->{path}
                        . " is already installed.\n";
            } elsif ( exists $ext->{install} ) {
                delete $ext->{install};
            } else {
                $ext->{install} = 1;
            }
        } else {
            print "\nEnter a number between 1 and "
                    . ( $#externals + 1 ) . ", x, or q.\n";
        }
    } while ( 1 );
}
elsif ( $command eq 'update' || $command eq 'up' ) {
    for my $ext ( @externals ) {
        if ( -d $ext->{path} ) {
            print "\n### Updating " . $ext->{path} . " ###\n";
            my $fun = get_vcs_cmd($ext->{vcs}, 'update');
            if ( $fun ) {
                &$fun($ext->{path}, $ext->{repo}, $ext->{branch});
            }
            else {
                print "Error: No update function for " . $ext->{vcs} . ".\n";
            }
        }
    }
}
else {
    print "\nUsage: `$0 checkout` or `$0 update`.\n";
    exit 1;
}
