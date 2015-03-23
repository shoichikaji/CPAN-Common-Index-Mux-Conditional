use strict;
use warnings;
use utf8;
use Test::More;
use CPAN::Common::Index::Mux::Conditional;

{
    package CPAN::Common::Index::Foo;
    sub new { bless {}, shift }
    sub search_packages {
        my $self = shift;
        $self->{called}++;
        return; # not found
    }
    sub called { shift->{called} }
    $INC{"CPAN/Common/Index/Foo.pm"} = 1; # WTF
}

my $c = CPAN::Common::Index::Mux::Conditional->new(
    condition => sub {
        my ($self, $arg) = @_;
        $arg->{package} eq "Moose" ? qw(meta foo) : qw(foo meta);
    },
    resolvers => [
        { id => "foo", class => "Foo"    },
        { id => "meta", class => "MetaDB" },
    ],
);

my $result1 = $c->search_packages({package => "Moose"});
is $result1->{package}, "Moose";
ok !$c->resolver("foo")->called;

my $result2 = $c->search_packages({package => "Mouse"});
is $result2->{package}, "Mouse";
ok $c->resolver("foo")->called;

is_deeply [ sort qw(foo meta) ], [ $c->resolver_ids ];

done_testing;
