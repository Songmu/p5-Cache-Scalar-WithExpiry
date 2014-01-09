use strict;
use warnings;
use utf8;
use Test::More;
use Test::Time time => 1;
use Cache::Scalar::WithExpiry;
use Time::HiRes qw//;

{
    # CORE::GLOBAL::time() is overrided by Test::Time and use it
    no warnings;
    *Time::HiRes::time = sub { time() };
}

subtest 'get/set' => sub {
    my $cache = Cache::Scalar::WithExpiry->new();
    is($cache->get(), undef);
    eval {
        $cache->set('abc');
    };
    like $@, qr/expiry time is required/;
};

subtest 'get/set expiration' => sub {
    my $cache = Cache::Scalar::WithExpiry->new();
    is($cache->get(), undef);
    $cache->set('abc', 3);
    is($cache->get(), 'abc');
    sleep 10;
    is($cache->get(), undef);
    is($cache->get(), undef, 'run twice');
};

subtest 'delete expiration' => sub {
    my $cache = Cache::Scalar::WithExpiry->new();
    is($cache->get(), undef);
    $cache->set('abc', 13);
    is($cache->get(), 'abc');
    $cache->delete();
    is($cache->get(), undef, 'removed');
};

subtest 'expiration' => sub {
    my $cache = Cache::Scalar::WithExpiry->new();
    is($cache->get(), undef);
    $cache->set('abc', 10);
    is($cache->get(), undef);
};

subtest 'get_or_set' => sub {
    my $cache = Cache::Scalar::WithExpiry->new();
    $cache->get_or_set(sub {
        (26, 13);
    });
    is $cache->get, 26;
    sleep 10;
    is $cache->get, undef;
};

subtest 'get_or_set' => sub {
    my $cache = Cache::Scalar::WithExpiry->new();
    eval {
        $cache->get_or_set(sub {
            1;
        });
    };
    like $@, qr/expiry time is required/;
};

done_testing;
