package Edge::HiringProject;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Debugger;
use Edge::Customer;
use Edge::Order;

our $VERSION = '0.1';

get '/' => sub {
  template 'index' => {
    title => 'Edge::HiringProject',
  }
};

get '/form/:form_name' => sub {
    my $schema = schema 'edge';
    my $form_name = route_parameters->get('form_name') || '';
    my $form = $schema->resultset('Form')->search({
                  'data' => \"->>'name' = '$form_name'"
                })->single;
    if ($form) {
      template 'form' => {
        'form' => $form_name,
        'title' => $form->data->{title},
        'form_description' => $form->data->{description},
        'form_fields' => $form->data->{fields},
      };
    }
    else {
      redirect '/';
    }
};

post '/submit/:form_name' => sub {
    my $schema = schema 'edge';
    my $form_name = route_parameters->get('form_name') || '';
    my $form = $schema->resultset('Form')->search({
                  'data' => \"->>'name' = '$form_name'"
                })->single;
    if ($form) {
      my $submission = {
          id => session->id,
          form => $form_name,
        };
      foreach my $field (@{$form->data->{fields}}) {
        $submission->{$field->{name}} = body_parameters->get($field->{name});
      }
      $form->create_related('form_submissions', { data => $submission });
    }
    redirect '/customer';
};

get '/customer' => sub {
    my $customer = Edge::Customer->new( schema => schema('edge'), id => session->id );
    template 'customer' => {
      'title' => 'Customer Information: ' . session->id,
      'customer' => $customer,
    };
};

true;
