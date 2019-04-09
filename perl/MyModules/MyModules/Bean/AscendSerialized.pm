package MyModules::Bean::AscendSerialized;

use Moose;

has 'id' => (
    is  => 'rw',
    isa => 'Int',
);

has 'serial' => (
    is  => 'rw',
    isa => 'Str',
);

has 'itemDescription' => (
    is  => 'rw',
    isa => 'Str',
);

has 'lcItemNo' => (
    is  => 'rw',
    isa => 'Maybe[Str]',
);

has 'productId' => (
    is  => 'rw',
    isa => 'Maybe[Str]',
    default => undef,
);

has 'customer' => (
    is  => 'rw',
    isa => 'Maybe[Str]',
    default => undef,
);

has 'lastModified' => (
	is  => 'rw',
	isa => 'Maybe[DateTime]',
	default => undef,
);

no Moose;
__PACKAGE__->meta->make_immutable;
