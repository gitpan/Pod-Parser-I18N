package Pod::Parser::I18N::Handler::Handle;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::clean -except => qw(meta);

with 'Pod::Parser::I18N::Handler';

class_type 'IO::File';

has 'handle' => (
    is => 'rw',
    isa => 'GlobRef | IO::File',
    default => sub {
        binmode(\*STDOUT, ":utf8");
        \*STDOUT
    }
);

sub verbatim {
    my $fh = $_[0]->handle;
    print $fh $_[1];
}

sub textblock {
    my $fh = $_[0]->handle;
    print $fh $_[1];
}

sub command {
    my $fh = $_[0]->handle;

    if ($_[2] !~ /\n$/) {
        print $fh "=$_[1]\n\n";
    } else {
        print $fh "=$_[1] $_[2]";
    }
}

sub interior_sequence {}

1;