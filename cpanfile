requires 'JSON::PP';
requires 'File::Spec';
requires 'Getopt::Long';
requires 'FindBin';

# Pandoc est utilisé uniquement comme binaire, pas comme module Perl
# On installe donc le binaire dans la workflow (apt-get/brew)