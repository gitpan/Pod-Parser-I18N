package Pod::Parser::I18N;
use Moose;
use Moose::Util::TypeConstraints;
use Data::Localize;

our $VERSION = '0.00001';
our $AUTHORITY = 'cpan:DMAKI';

extends 'Pod::Parser';

subtype 'Pod::Parser::I18N::HandlerSpec'
    => as 'Object'
    => where {
        $_->does('Pod::Parser::I18N::Handler') ||
        $_->isa('Pod::Parser')
    }
    => message { "Object must implement Pod::Parser or Pod::Parser::I18N::Handler" }
;
    
has 'handler' => (
    is => 'rw',
    isa => 'Pod::Parser::I18N::HandlerSpec',
    lazy_build => 1
);

subtype 'Pod::Parser::I18N::LocalizerSpec'
    => as 'Object'
    => where { $_->can('localize') }
    => message { "Object must implement localize()" }
;
coerce 'Pod::Parser::I18N::LocalizerSpec'
    => from 'ArrayRef'
    => via  {
        my $loc = Data::Localize->new();
        foreach my $h (@$_) {
            $loc->add_localizer(%$h);
        }
        return $loc;
    }
;
coerce 'Pod::Parser::I18N::LocalizerSpec'
    => from 'HashRef'
    => via {
        my $loc = Data::Localize->new();
        $loc->add_localizer(%$_);
        return $loc;
    }
;

has 'localizer' => (
    is => 'rw',
    isa => 'Pod::Parser::I18N::LocalizerSpec',
    lazy_build => 1,
    required => 1,
    coerce => 1,
    handles => {
        set_languages  => 'set_languages'
    }
);

sub new {
    my $class = shift;
    my $meta = $class->meta;

    my $self = $class->SUPER::new(@_);
    $self = $meta->new_object(__INSTSANCE__ => $self, @_);
    $self->Moose::Object::BUILDALL();
    return $self;
}

sub _build_localizer {
    return Data::Localize->new();
}

sub _build_handler {
    Class::MOP::load_class("Pod::Parser::I18N::Handler::Handle");
    return Pod::Parser::I18N::Handler::Handle->new();
}

sub localize {
    my ($self, $thing) = @_;
    $thing =~ s/^(\s+)?(.+?)(\s+)?$/
        ($1 || '') . $self->localizer->localize($2) . ($3 || '');
    /smex;
    return $thing;
}

sub verbatim {
    my $self = shift;
    my $para = shift;
    $self->handler->verbatim($self->localize($para), @_, $self);
}

sub command {
    my $self = shift;
    my $command = shift;
    my $para = shift;
    $self->handler->command($self->localize($command), $self->localize($para), @_, $self);
}

sub textblock {
    my $self = shift;
    my $para = shift;

    $self->handler->textblock($self->localize($para), @_, $self);
}

sub interior_sequence {
    my $self = shift;
    my $command = shift;
    my $arg     = shift;
    $self->handler->interior_sequence($command, $self->localize($arg), @_, $self);
}

foreach my $delegate qw(begin_input end_input begin_pod end_pod) {
    __PACKAGE__->meta->add_method($delegate => sub {
        my $self = shift;
        $self->handler->$delegate(@_);
    });
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

__END__

=head1 NAME

Pod::Parser::I18N - Internationalized POD

=head1 SYNOPSIS

    use Pod::Parser::I18N;

    my $parser = Pod::Parser::I18N->new(
        localizer => [
            { class => 'Gettext', path => '/path/to/data/*.po' }
        ],
        handler   => MyHandler->new()
    );

    $parser->prse_from_file('/path/to/pod.pod');

=head1 DESCRIPTION

This module exists in cases you want to display internationalized/translated versions of your POD.

The idea is to have a thin layer that consumes POD, and runs the text in there through Data::Localize before your actual processor gets to it.

This software is still in its very early stage. Please feel free to send me patches comments. The repository is at:

  http://github.com/lestrrat/pod-parser-i18n/tree/master

=head1 METHODS

=head2 new(%opts)

=over 4

=item localizer => $object | \@list | \%hash

Specifies the localizer object to use. If given a hash, it is taken as the parameters passed to Data::Localize::add_localizer(). Given a list, the values are expected to be hash references, each of which are taken as the values to be passed to add_localizer().

=item handler => $object

Specifies the actual handler that does the POD processing. It must be either a Pod::Parser subclass or an object that implements Pod::Parser::I18N::Handler role.

=back

=head1 AUTHOR

Daisuke Maki C<< <daisuke@endeworks.jp> >>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut