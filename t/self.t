use strict;
use Test::More (tests => 1);
use Test::Differences;

use Pod::Parser::I18N;
use Pod::Parser::I18N::Handler::Handle;

my $output;
open(my $fh, '>', \$output);
binmode($fh, ':utf8');

my $x = Pod::Parser::I18N->new(
    localizer => {
        class => "Gettext",
        path  => "t/I18N/*.po"
    },
    handler => Pod::Parser::I18N::Handler::Handle->new(
        handle => $fh
    )
);
$x->set_languages('ja');
$x->parse_from_file( "lib/Pod/Parser/I18N.pm" );

my $expected =<<'EOPOD';
=head1 名称

Pod::Parser::I18N - POD国際化モジュール

=head1 概要

    use Pod::Parser::I18N;

    my $parser = Pod::Parser::I18N->new(
        localizer => [
            { class => 'Gettext', path => '/path/to/data/*.po' }
        ],
        handler   => MyHandler->new()
    );

    $parser->prse_from_file('/path/to/pod.pod');

=head1 説明

このモジュールは、PODを国際化された（翻訳された）状態で処理する時に使用します。

PODをパースするレイヤーとそれを実際に表示・処理するレイヤーの間にData::Localizeを差し込み、処理前に翻訳してから処理側に受け渡します。

本ソフトウェアはまだ試作段階です。パッチ・コメント歓迎！レポジトリは下記にあります：

  http://github.com/lestrrat/pod-parser-i18n/tree/master

=head1 METHODS

=head2 new(%opts)

=over 4

=item localizer => $object | \@list | \%hash

国際化に使用するオブジェクトを指定します。ハッシュが渡された場合はそのハッシュがData::Localize::add_localizer()に引数として渡されます。リストが渡された場合はそれぞれの要素がハッシュである必要があり、それらがadd_localizer() に渡されます。

=item handler => $object

PODを実際に処理するオブジェクトを指定します。このオブジェクトはPod::Parserを継承、もしくはPod::Parser::I18N::Handlerロールを実装している必要があります。

=back

=head1 AUTHOR

Daisuke Maki C<< <daisuke@endeworks.jp> >>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

EOPOD

is( $output, $expected );

