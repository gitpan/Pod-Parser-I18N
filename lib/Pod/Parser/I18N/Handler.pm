package Pod::Parser::I18N::Handler;
use Moose::Role;

requires qw(verbatim command textblock interior_sequence);

foreach my $noop qw( begin_pod end_pod begin_input end_input) {
    __PACKAGE__->meta->add_method($noop => sub {});
}

1;