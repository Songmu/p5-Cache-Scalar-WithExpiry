package Cache::Scalar::WithExpiry;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Carp ();
use Time::HiRes;

use constant {
    TIME  => 0,
    VALUE => 1,
};

sub new {
    my ($class) = @_;
    bless [undef, undef], $class;
}

sub get {
    my ($self) = @_;

    if (defined $self->[TIME] && $self->[TIME] <= Time::HiRes::time()) {
        undef $self->[VALUE];
        undef $self->[TIME];
    }
    wantarray ? ($self->[VALUE], $self->[TIME]) : $self->[VALUE];
}

sub get_or_set {
    my ($self, $code) = @_;

    if (my $val = $self->get) {
        return $val;
    } else {
        my ($val, $expiry) = $code->();
        $self->set($val, $expiry);
        return $val;
    }
}

sub set {
    my ($self, $val, $expiry) = @_;
    Carp::croak 'expiry time is required' if !$expiry || $expiry <= 0;

    $self->[TIME]  = $expiry;
    $self->[VALUE] = $val;
    return $val;
}

sub delete :method {
    my ($self) = @_;
    undef $self->[VALUE];
    return undef;
}

1;
__END__

=encoding utf-8

=head1 NAME

Cache::Scalar::WithExpiry - Cache one scalar value

=head1 SYNOPSIS

    use Cache::Scalar::WithExpiry;
    use feature qw/state/;
    
    sub get_stuff {
        my ($class, $key) = @_;
    
        state $cache = Cache::Scalar::WithExpiry->new();
        my $value = $cache->get_or_set(sub {
            my $val          = Storage->get;
            my $expiry_epoch = time + 20;
            return ($val, $expiry_epoch); # cache in 20 seconds
        });
    }

=head1 DESCRIPTION

Cache::Scalar::WithExpiry is cache storage for one scalar value with expiry epoch.

=head1 METHODS

=over 4

=item C<< my $obj = Cache::Scalar::WithExpiry->new() >>

Create a new instance.

=item C<< my $stuff = $obj->get($key); >>

Get a stuff from cache storage by C<< $key >>

=item C<< $obj->set($val, $expiration_epoch) >>

Set a stuff for cache. C<$expiry_epoch> is required.

=item C<< $obj->get_or_set($code) >>

Get a cache value if it's already cached. If it's not cached, run C<$code> which should
return two value, C<$value_to_be_cached> and C<$expiry_epoch>, and cache the value
until the expiry epoch.

=item C<< $obj->delete($key) >>

Delete the cache.

=head1 THANKS TO

tokuhirom. Most code of this module is steal from his L<Cache::Memory::Simple::Scalar>.

=head1 LICENSE

Copyright (C) Songmu.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Songmu E<lt>y.songmu@gmail.comE<gt>

=cut

