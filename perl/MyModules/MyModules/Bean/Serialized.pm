package MyModules::Bean::Serialized;

use Moose;

has 'id' => (
    is  => 'rw',
    isa => 'Int',
);

has 'serial' => (
    is  => 'rw',
    isa => 'Str',
);

#has 'colorName' => (
#    is  => 'rw',
#    isa => 'Str',
#);
#
#has 'sizeName' => (
#    is  => 'rw',
#    isa => 'Str',
#);

has 'description' => (
    is  => 'rw',
    isa => 'Str',
);

has 'itemId' => (
    is  => 'rw',
    isa => 'Int',
);

has 'saleLineId' => (
    is  => 'rw',
    isa => 'Maybe[Int]',
    default => undef,
);

has 'customerId' => (
    is  => 'rw',
    isa => 'Maybe[Int]',
    default => undef,
);

has 'lastModified' => (
	is  => 'rw',
	isa => 'Maybe[DateTime]',
	default => undef,
);

no Moose;
__PACKAGE__->meta->make_immutable;
