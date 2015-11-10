#!/usr/bin/env ruby
#

require 'rgeo'
require 'csv'

nztm_proj4 = '+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs'
nztm_wkt = <<WKT
  PROJCS["NZGD2000 / New Zealand Transverse Mercator 2000",
      GEOGCS["NZGD2000",
          DATUM["New_Zealand_Geodetic_Datum_2000",
              SPHEROID["GRS 1980",6378137,298.257222101,
                  AUTHORITY["EPSG","7019"]],
              TOWGS84[0,0,0,0,0,0,0],
              AUTHORITY["EPSG","6167"]],
          PRIMEM["Greenwich",0,
              AUTHORITY["EPSG","8901"]],
          UNIT["degree",0.01745329251994328,
              AUTHORITY["EPSG","9122"]],
          AUTHORITY["EPSG","4167"]],
      UNIT["metre",1,
          AUTHORITY["EPSG","9001"]],
      PROJECTION["Transverse_Mercator"],
      PARAMETER["latitude_of_origin",0],
      PARAMETER["central_meridian",173],
      PARAMETER["scale_factor",0.9996],
      PARAMETER["false_easting",1600000],
      PARAMETER["false_northing",10000000],
      AUTHORITY["EPSG","2193"],
      AXIS["Easting",EAST],
      AXIS["Northing",NORTH]]
WKT

nztm_factory = RGeo::Cartesian.factory(:srid => 2193,
  :proj4 => nztm_proj4, :coord_sys => nztm_wkt)

wgs84_proj4 = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'
wgs84_wkt = <<WKT
  GEOGCS["WGS 84",
    DATUM["WGS_1984",
      SPHEROID["WGS 84",6378137,298.257223563,
        AUTHORITY["EPSG","7030"]],
      AUTHORITY["EPSG","6326"]],
    PRIMEM["Greenwich",0,
      AUTHORITY["EPSG","8901"]],
    UNIT["degree",0.01745329251994328,
      AUTHORITY["EPSG","9122"]],
    AUTHORITY["EPSG","4326"]]
WKT

wgs84_factory = RGeo::Geographic.spherical_factory(:srid => 4326,
  :proj4 => wgs84_proj4, :coord_sys => wgs84_wkt)

if ARGV.size != 2
  $stderr.puts "Usage: convert.rb <infile> <outfile>"
  return
end

csv = CSV.open(ARGV.first, 'r', headers: true)
original_rows = csv.read
original_headers = original_rows.headers

output_file = CSV.open(ARGV.last, 'w')
output_file << original_headers + ['nztm_latitude', 'nztm_longitude']

original_rows.each do |row|
  lat = row['latitude']
  lng = row['longitude']

  if lat && lng
    point = wgs84_factory.point(lng, lat)
    nztm_latlng = RGeo::Feature.cast(point, :factory => nztm_factory, :project => true)
    output_file << original_headers.map { |h| row[h] } + [nztm_latlng.y, nztm_latlng.x]
  end
end

output_file.close
