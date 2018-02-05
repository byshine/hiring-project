package Edge::Customer;

use Moose;
use Edge::Order;
use Time::Piece;

has 'schema' => (
  is => 'ro',
  isa => 'Edge::Schema',
  required => 1,
);

has 'id' => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has 'profile_form' => (
  is => 'ro',
  isa => 'HashRef',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $profile_form = $self->schema->resultset('FormSubmission')->search(
                    {
                      'data' => \["->>'id' = ?", $self->id],
                      'data' => \["->>'form' = 'profile'"],
                    },
                    {
                      'order_by' => { -desc => 'id' },
                    },
                  )->first;
    if ($profile_form && ref $profile_form->data) {
      return $profile_form->data;
    }
    else {
      return {};
    }
  },
);

has 'birthdate' => (
  is => 'ro',
  isa => 'Str',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $birthdate = $self->profile_form->{birthdate};
    if ($birthdate eq ' ') { return 'mm/dd/yyyy'; }
    return $birthdate;
  },
);

has 'age' => (
  is => 'ro',
  isa => 'Str',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $birthdate = Time::Piece->strptime($self->birthdate, '%Y-%m-%d');
    my $birthyear = $birthdate->year;
    my $localyear = localtime->year;
    my $age = $localyear - $birthyear;
    if ( ($birthdate->mon >= localtime->mon) && ($birthdate->wday >= localtime->wday) ) {
    	$age--;
    }	
    return $age;
  },
);



has 'name' => (
  is => 'ro',
  isa => 'Str',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $name = ($self->profile_form->{fname} || '') . ' ' . ($self->profile_form->{lname} || '');
    if ($name eq ' ') { return '--not set--'; }
    return $name;
  },
);

has 'fname' => (
  is => 'ro',
  isa => 'Str',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $fname = ($self->profile_form->{fname} || '');
    if ($fname eq ' ') { return '--not set--'; }
    return $fname;
  },
);


has 'lname' => (
  is => 'ro',
  isa => 'Str',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $lname = ($self->profile_form->{lname} || '');
    if ($lname eq ' ') { return '--not set--'; }
    return $lname;
  },
);

has 'orders' => (
  is => 'ro',
  isa => 'ArrayRef[Edge::Order]',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $order;	
    my $order_form = $self->schema->resultset('FormSubmission')->search(
                    {
                      'data' => \["->>'id' = ?", $self->id],
                      'data' => \["->>'form' = 'order'"],
                    },
                    {
                      'order_by' => { -desc => 'id' },
                    },
                  );

    if ( $order_form ) {
	my @orders;
	for my $orderResult ( $order_form->all ) {
                $order = Edge::Order->new(
                product => $orderResult->data->{product},
                price   => $orderResult->data->{price},
                quantity => $orderResult->data->{quantity},
		total => ($orderResult->data->{price} * $orderResult->data->{quantity}),
                );
                push @orders, $order
	}
      return \@orders
    }
    else {
      return [];
    }

  },
);


no Moose;
__PACKAGE__->meta->make_immutable;
