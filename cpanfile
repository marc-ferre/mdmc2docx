requires 'JSON::PP';
requires 'File::Spec';
requires 'Getopt::Long';
requires 'FindBin';
requires 'Pandoc';

# Pandoc est utilisé comme binaire ET comme module Perl (Pandoc.pm)
# On installe donc le binaire dans la workflow (apt-get/brew) et le module via cpanm