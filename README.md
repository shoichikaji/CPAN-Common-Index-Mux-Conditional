# NAME

CPAN::Common::Index::Mux::Conditional - choose index conditionally

# SYNOPSIS

    use CPAN::Common::Index::Mux::Conditional;

    my $condition_cb = sub {
        my ($self, $args) = @_;
        if ($args->{package} eq "Moose") {
            qw(mirror2 mirror1);
        } else {
            qw(mirror1 mirror2);
        }
    };

    my $index = CPAN::Common::Index::Mux::Conditional->new(
        condition => $condition_cb,
        resolvers => [
            { id => "mirror1", class => "Mirror", args => { mirror => 'http://www.cpan.org/' } },
            { id => "mirror2", class => "Mirror", args => { mirror => 'http://cpan.cpantesters.org/' } },
        ],
    );

    # execute $condition_cb, and determines orders of resolvers
    $index->search_package({ package => "Moose" }); # order: mirror2 -> mirror1

# DESCRIPTION

CPAN::Common::Index::Mux::Conditional multiplexes
multiple [CPAN::Common::Index](https://metacpan.org/pod/CPAN::Common::Index) objects conditionally.

# LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Shoichi Kaji <skaji@cpan.org>
