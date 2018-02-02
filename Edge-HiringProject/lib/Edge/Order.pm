package Edge::Order;

use Moose;

has 'product' => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has 'price' => (
  is => 'ro',
  isa => 'Int',
  required => 1,
);

has 'quantity' => (
  is => 'ro',
  isa => 'Int',
  required => 1,
);

has 'total' => (
  is => 'ro',
  isa => 'Int',
  required => 1,
);



no Moose;
__PACKAGE__->meta->make_immutable;
