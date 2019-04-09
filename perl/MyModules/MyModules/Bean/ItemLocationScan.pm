package MyModules::Bean::ItemLocationScan;

use Moose;

has 'id' => (
    is  => 'rw',
    isa => 'Int'
);

has 'serialized' => (
    is  => 'rw',
    isa => 'Maybe[Int]'
);

has 'scan_location' => (
    is  => 'rw',
    isa => 'Maybe[Int]'
);

has 'destination_location' => (
    is  => 'rw',
    isa => 'Maybe[Int]',
    default => '0'
);

has 'employee' => (
    is  => 'rw',
    isa => 'Maybe[Int]'
);

has 'action' => (
    is  => 'rw',
    isa => 'Maybe[Int]'
);

has 'timestamp' => (
    is  => 'rw',
    isa => 'Str'
);

has 'last_modified' => (
    is  => 'rw',
    isa => 'Str'
);

has 'done' => (
    is  => 'rw',
    isa => 'Maybe[Bool]',
    default => undef 
);

#sub BUILD {
#    my $self = shift;
#    $self->done(0) unless defined $self->done;
#    $self->destination_location(0) unless defined $self->destination_location;
#}

no Moose;
__PACKAGE__->meta->make_immutable;
