package Statistics::Test::TwoDist;
use strict;
use Statistics::Distributions qw (tdistr fdistr tprob fprob udistr uprob);
use Data::Dumper;


=head1 NAME

 Statistics::Test - Contains statistical tests for
  Statistics::Descriptive objects.

=head1 SYNOPSIS

 use Statistics::Test::TwoDist;
 use Statistics::Descriptive;

 #create two Statistics::Descriptive objects
 my $dist1 = Statistics::Descriptive::Full->new();
 my $dist2 = Statistics::Descriptive::Full->new();

 #push data into Statistics::Descriptive objects
 $dist1->add_data(@arg1);
 $dist2->add_data(@arg2);

 #create a Statistics::Test::TwoDist object to hold the data
 my $test = Statistics::Test::TwoDist->new();

 #add the data into the Statistics::Test::TwoDist object
 $test->distribution1($dist1);
 $test->distribution2($dist2);

 #print t-value from a t-test on the two data sets
 print $test->t_test->{t};

 #print p-value from a mann-whitney test on the two data sets
 print $test->mann_whitney->{p};

=head1 DESCRIPTION

 This module provides some statistical tests for significance
 on Statistics::Descriptive objects. The current layout is very
 simple. A Statistics::Test object takes in two
 Statistics::Descriptive objects and can perform a a two sample
 t-test or a mann-whitney test among the two data sets. It then
 reports the results in a hash that contains the t or z-value
 and the corresponding p-value.

 Implementations of statistical tests for single distributions
 and N-Distributions are planned for future releases.

=head1 AUTHOR

James Chen, E<lt>chenj@seas.ucla.eduE<gt>


=head1 METHODS



=head2 t_test

 Title   : t_test
 Usage   : my $t_result = $test->t_test;
 Function: performs a two sample t-test on the two data sets stored in $test of type Statistics::Descriptive
 Example :
 Returns : a hash of the t-value and its corresponding p-value
 Args    : none


=cut

sub t_test {
  my ($s1, $s2) = @_;

  return {} if $s2->count == 0 || $s1->count == 0;

  #if both data sets only contain one data element, no t or p value can be calculated
  return {} if ($s1->count == 1 && $s2->count == 1);

  my $t = ($s1->mean - $s2->mean)/sqrt(($s1->variance/$s1->count)+($s2->variance/$s2->count));

  #if only one of the data sets contain one data element, only the t value can be calculated
  return {t=>$t} if($s1->count == 1 || $s2->count == 1);

  #otherwise calculate and return the t and p value
  my $p = abs(tprob($s1->count - 1, -1 * $t) - tprob($s2->count - 1, $t));
  return {t=>$t, p=>$p};
}

=head2 mann_whitney

 Title   : mann_whitney
 Usage   : my $mw_result = $test->mann_whitney;
 Function: performs a mann whitney test on the two data sets stored in $test of type STatistics::Descriptive
 Example :
 Returns : a hash of the z-value and its corresponding p-value
 Args    : none


=cut

sub mann_whitney {
  
  my ($s1, $s2) = @_;

  my @s1_list = sort {$a <=> $b} $s1->get_data;
  my @s2_list = sort {$a <=> $b} $s2->get_data;

  my $s1_size = scalar(@s1_list);
  my $s2_size = scalar(@s2_list);

  my %s1_unique;
  my %s2_unique;
  my %final_unique;
  my %final_hash;

 #put s1 and s2 lists into a unique hash with each distinct data value as the key and the number of times it occurs as the value
  foreach my $i (@s1_list) {
	if($s1_unique{$i} == undef) {
	  $s1_unique{$i} = 1;
	} else {
	  $s1_unique{$i} = $s1_unique{$i} + 1;
	}
  }
  foreach my $i (@s2_list) {
	if($s2_unique{$i} == undef) {
	  $s2_unique{$i} = 1;
	} else {
	  $s2_unique{$i} = $s2_unique{$i} + 1;
	}
  }

  my @total_list = sort {$a <=> $b} (@s1_list, @s2_list);
  my @unique_list = unique_list(\@total_list);

  foreach my $i (@unique_list) {
	$final_unique{$i} = $s1_unique{$i}+$s2_unique{$i};
  }

  my $unique_size = scalar(@unique_list);
  my $total_size = scalar(@total_list);
  my $i = 1;
  my $rank;
  my $data_set;
  my $i2 = 1;

  while ($i <= $unique_size) {
	my $count = $final_unique{$unique_list[$i-1]};
	if ($count == 1) {
	  #if there is only one occurance of the datum in both lists
	  $rank = $i2;
	  if($s1_unique{$unique_list[$i-1]} == undef) {
		$data_set = 2;
	  } else {
		$data_set = 1;
	  }
	  push(@{$final_hash{$i2}}, ($rank, $data_set));
	  $i2++;
	} else {
	  #otherwise
	  $rank = $i2;
	  my $j = 0;
	  my $rank_avg = (((($rank+$count-1)*($rank+$count)) - (($rank-1)*($rank)))/2)/$count;
	  my $data_set1_count = $s1_unique{$unique_list[$i-1]};
	  my $data_set2_count = $s2_unique{$unique_list[$i-1]};
	  while ($j < $count) {
		if($j < $data_set1_count) {
		  $data_set = 1;
		} else {
		  $data_set = 2;
		}
		push(@{$final_hash{$i2}}, ($rank_avg, $data_set));
		$i2++;
		$j++;
	  }
	}
	$i++;
  }

  my $w1 = 0;
  my $w2 = 0;
  my $n1 = 0;
  my $n2 = 0;

  foreach my $key (keys %final_hash) {
	if(@{$final_hash{$key}}->[1] == 1) {
	  $w1 += @{$final_hash{$key}}->[0];
	  $n1++;
	} else {
	  $w2 += @{$final_hash{$key}}->[0];
	  $n2++;
	}
  }

  my $set1_rank_avg = $w1/$n1;
  my $set2_rank_avg = $w2/$n2;

  my $u1 = $n1*$n2 + (0.5)*$n1*($n1+1) - $w1;
  my $u2 = $n1*$n2 + (0.5)*$n2*($n2+1) - $w2;

  my $u = ($u1 < $u2) ? $u1 : $u2;

  my $mu = $n1*$n2/2;
  my $sigma = sqrt($n1*$n2*($n1+$n2)/12);
  my $z = ($u - $mu)/$sigma;

  my $p = uprob($z);

  return {z=>$z, p=>$p};

}

=head2 wilcoxon

 Title   : wilcoxon
 Usage   : my $w_result = $test->wilcoxon
 Function: performs a wilcoxon test on the two data sets stored in $test of type Statistics::Descriptive
 Example :
 Returns : a hash of the z-value and its corresponding p-value
 Args    : none


=cut

sub wilcoxon {
  my ($s1, $s2) = @_;
  my $size1 = $s1->count;
  my $size2 = $s1->count;
  die "Wilcoxon requires both data sets to be the same size" unless $size1 == $size2;
  return mann_whitney($s1, $s2);
}

=head2 unique_list

 Title   : unique_list
 Usage   :
 Function: internal function that returns the unique values of a list
 Example : my @unique_list = self->unique_list(\@args)
 Returns : an array
 Args    : reference to an array


=cut

sub unique_list {
  my ($list) = @_;

  my @new_list;
  @$list = sort {$a <=> $b} @$list;
  my $temp_var = @$list[0];
  push @new_list, @$list[0];
  my $size = scalar(@$list);
  my $i = 1;
  while ($i < $size) {
	if(@$list[$i] != $temp_var) {
	  push @new_list, @$list[$i];
	  $temp_var = @$list[$i];
	}
	$i++;
  }
  return @new_list;
}

1;
