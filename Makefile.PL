use inc::Module::Install;

name 'Pod-Parser-I18N';
all_from 'lib/Pod/Parser/I18N.pm';

requires 'Moose';
requires 'Pod::Parser';

repository 'http://github.com/lestrrat/pod-parser-i18n/tree/master';

WriteAll;