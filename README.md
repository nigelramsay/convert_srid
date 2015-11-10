Converts a CSV file containing a series of columns including one named `latitude` and another named `longitude` from WGS84 with SRID `4326` into NZTM with SRID `2193`. New columns named `nztm_latitude` and `nztm_longitude` are added to a new CSV file.

Usage:

```
bundle exec ruby convert.rb <infile> <outfile>
```
