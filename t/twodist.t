use strict;


BEGIN {
  eval { require Test; };
  if($@){
    use lib 't';
  }
  use Test;
  plan test => 8;
}

use Statistics::Test;
ok(1);

use Statistics::Descriptive;
ok(2);

my $dist1 = Statistics::Descriptive::Full->new();
my $dist2 = Statistics::Descriptive::Full->new();
my @list1 = (0.37, 0.70, 0.75, 0.30, 0.45, 0.16, 0.62, 0.73, 0.33);
my @list2 = (0.86, 0.55, 0.80, 0.42, 0.97, 0.84, 0.24, 0.51, 0.92, 0.69);
$dist1->add_data(@list1);
$dist2->add_data(@list2);
ok(3);

my $test = Statistics::Test->new(distributions => [$dist1]);
$test->add_distribution($dist2);
ok(4);

if(defined($test->t_test->{t})) {
	ok(5);
} else {
	warn(5);
}

if(defined($test->t_test->{p})) {
	ok(6);
} else {
	warn(6);
}

if(defined($test->mann_whitney->{z})) {
	ok(7);
} else {
	warn(7);
}

if(defined($test->mann_whitney->{p})) {
	ok(8);
} else {
	warn(8);
}