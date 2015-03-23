package CPAN::Common::Index::Mux::Conditional;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Module::Load ();

sub new {
    my ($class, %option) = @_;

    my $resolvers = delete $option{resolvers} || [];
    my %resolvers;
    for my $param (@$resolvers) {
        my $klass = "CPAN::Common::Index::$param->{class}";
        Module::Load::load($klass);
        $resolvers{ $param->{id} }
            = $klass->new( $param->{args} ? $param->{args} : () );
    }
    bless {
        condition => sub {},
        %option,
        resolvers => \%resolvers,
    }, $class;

}
sub resolver  { my ($self, $id) = @_; $self->{resolvers}->{$id} }
sub resolver_ids { my $self = shift; sort keys %{ $self->{resolvers} } }

sub search_packages {
    my ($self, $args) = @_;
    my @ordered = $self->{condition}->($self, $args);
    @ordered = () if @ordered && !defined $ordered[0];
    for my $id (@ordered) {
        my $resolver = $self->resolver($id) or die "Cannot find '$id' resolver";
        my $found = $resolver->search_packages($args);
        return $found if $found;
    }
    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

CPAN::Common::Index::Mux::Conditional - choose index conditionally

=head1 SYNOPSIS

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


=head1 DESCRIPTION

CPAN::Common::Index::Mux::Conditional multiplexes
multiple L<CPAN::Common::Index> objects conditionally.

=head1 LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

=cut

