package Statistics::Test;

use strict;

use Statistics::Test::TwoDist;
use Data::Dumper;
our $VERSION = '0.02';

=head2 new

 Title   : new
 Usage   : my $test = Statistics::Test->new(@args);
 Function: constructor for a Statistics::Test object
 Example :
 Returns : a new object of type Statistics::test
 Args    : objects of type Statistics::Descriptive;


=cut

sub new{
   my ($class, @args) = @_;
   my $self = bless( {}, $class);
   $self->init(@args);
   return $self;
}

=head2 init

 Title   : init
 Usage   : 
 Function: internal method to initialize constructor variables
 Example :
 Returns : none
 Args    : objects of type Statistics::Descriptive


=cut

sub init{
   my ($self,%args) = @_;
   if (defined($args{'distributions'})) {
	 foreach my $dist (@{$args{'distributions'}}) {
	   $self->add_distribution($dist);
	 }
   }
}

=head2 distributions

 Title   : distributions
 Usage   : $obj->distributions()
 Function: returns an array of allt he distributions in the Statistics::Test object
 Example : 
 Returns : value of distributions (a scalar)
 Args    : none


=cut

sub distributions{
    my $self = shift;
    return @{$self->{'distributions'}} if (defined($self->{'distributions'}));
	return ();
}

=head2 add_distribution

 Title   : add_distribution
 Usage   : $test->add_distribution($dist)
 Function: Adds a distribution of type Statistics::Descriptive into the Statistics::Test object
 Example :
 Returns : none
 Args    : an object of type Statistics::Descriptive::Full


=cut

sub add_distribution{
   my ($self,$arg) = @_;
   push(@{$self->{'distributions'}}, $arg) if (ref $arg eq "Statistics::Descriptive::Full");
}

=head2 _count

 Title   : _count
 Usage   : $count = $test->_count;
 Function: internal method to return the number of distributions held in the Statistics::Test object
 Example :
 Returns : the nubmer of distributions held in the Statistics::Test object
 Args    : none


=cut

sub _count{
   my ($self,@args) = @_;
   return scalar($self->distributions);
}

=head2 mann_whitney

 Title   : mann_whitney
 Usage   : $result = $test->mann_whitney;
 Function: performs a mann whitney test on two distributions held in the Statistics::Test object
 Example :
 Returns : a hash of the z-value and p-value of the mann whitney test
 Args    : none


=cut

sub mann_whitney{
  my ($self,@args) = @_;
  my @distributions = $self->distributions;
  if ($self->_count == 2) {
	return Statistics::Test::TwoDist::mann_whitney($distributions[0], $distributions[1]);
  } else {
	die "mann_whitney requires two distributions";
  }
}

=head2 t_test

 Title   : t_test
 Usage   : $result = $test->t_test;
 Function: performs a two sample t test on two distributions held in the Statistics::Test object
 Example :
 Returns : a hash of the t-value and p-value of the two sample t test
 Args    : none


=cut

sub t_test{
   my ($self,@args) = @_;
   my @distributions = $self->distributions;
   if($self->_count == 2) {
	 return Statistics::Test::TwoDist::t_test($distributions[0], $distributions[1]);
   } else {
	 die "t_test requires two distributions";
   }
}

=head2 wilcoxon

 Title   : wilcoxon
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub wilcoxon{
   my ($self,@args) = @_;
   my @distributions = $self->distributions;
   if ($self->_count == 2 && $distributions[0]->count == $distributions[1]->count) {
	 return Statistics::Test::TwoDist::wilcoxon($distributions[0], $distributions[1]);
   } else {
	 die "wilcoxon test requires two distributions of equal size";
   }

}


1;
__END__

=head1 NAME

Statistics::Test - Contains statistical tests for 
Statistics::Descriptive objects.

=head1 SYNOPSIS

 use Statistics::Test;
 use Statistics::Descriptive;

 #create two Statistics::Descriptive objects
 my $dist1 = Statistics::Descriptive::Full->new();
 my $dist2 = Statistics::Descriptive::Full->new();

 #push data into Statistics::Descriptive objects
 $dist1->add_data(@arg1);
 $dist2->add_data(@arg2);

 #create a new Statistics::Test object and store the $dist1 and $dist2
 my $test = Statistics::Test->new(distributions => [$dist1]);
 $test->add_distribution($dist2);

 #print t-value from a t-test on the two data sets
 print $test->t_test->{t};

 #print p-value from a mann-whitney test on the two data sets
 print $test->mann_whitney->{p};

=head1 DESCRIPTION

This module provides some statistical tests for significance 
on Statistics::Descriptive objects. The current layout is very 
simple. 
 
A Statistics::Test object takes in two Statistics::Descriptive 
objects and can perform a a two sample t-test or a mann-whitney test 
among the two data sets. It then reports the results in a hash that 
contains the t or z-value and the corresponding p-value.

Implementations of statistical tests for single distributions 
and N-Distributions are planned for future releases.

=head1 AUTHOR

James Chen, E<lt>chenj@seas.ucla.eduE<gt>

=cut
