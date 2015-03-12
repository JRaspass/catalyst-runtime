use warnings;
use strict;
use Test::More;
use HTTP::Request::Common;

{
  package MyApp::Controller::Root;
  $INC{'MyApp/Controller/Root.pm'} = __FILE__;

  use Moose;
  use MooseX::MethodAttributes;

  extends 'Catalyst::Controller';

  sub an_int :Local Args(Int) {
    my ($self, $c, $int) = @_;
    $c->res->body('an_int');
  }

  sub many_ints :Local Args(ArrayRef[Int]) {
    my ($self, $c, $int) = @_;
    $c->res->body('many_ints');
  }

  sub any_priority :Path('priority_test') Args(1) { $_[1]->res->body('any_priority') }
  sub int_priority :Path('priority_test') Args(Int) { $_[1]->res->body('int_priority') }

  sub default :Default {
    my ($self, $c, $int) = @_;
    $c->res->body('default');
  }

  MyApp::Controller::Root->config(namespace=>'');

  package MyApp;
  use Catalyst;

  #MyApp->config(show_internal_actions => 1);
  MyApp->setup;
}

use Catalyst::Test 'MyApp';

{
  my $res = request '/an_int/1';
  is $res->content, 'an_int';
}

{
  my $res = request '/an_int/aa';
  is $res->content, 'default';
}

{
  my $res = request '/many_ints/1';
  is $res->content, 'many_ints';
}

{
  my $res = request '/many_ints/1/2';
  is $res->content, 'many_ints';
}

{
  my $res = request '/many_ints/1/2/3';
  is $res->content, 'many_ints';
}

{
  my $res = request '/many_ints/1/2/a';
  is $res->content, 'default';
}

{
  my $res = request '/priority_test/1';
  is $res->content, 'int_priority';
}
{
  my $res = request '/priority_test/a';
  is $res->content, 'any_priority';
}

done_testing;
