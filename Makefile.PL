use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Statistics::Test',
    'VERSION_FROM'	=> 'Test.pm', # finds $VERSION
    'PREREQ_PM'		=> {
						Statistics::Descriptive => 0.0,
						Statistics::Distributions => 0.0
					   }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Test.pm', # retrieve abstract from module
       AUTHOR     => 'James Chen <chenj@seas.ucla.edu>') : ()),
);
