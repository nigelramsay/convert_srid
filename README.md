Converts a CSV file containing a series of columns including one named `latitude` and other named `longitude` from SRID `4326` into `2193`. New columns named `nztm_latitude` and `nztm_longitude` are added to a new CSV file.

Usage:

bundle exec ruby convert.rb <infile> <outfile>
