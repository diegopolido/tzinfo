TZInfo - Ruby Time Zone Library
===============================

[![Gem Version](https://badge.fury.io/rb/tzinfo.svg)](https://badge.fury.io/rb/tzinfo) [![Travis CI Build Status](https://travis-ci.org/tzinfo/tzinfo.svg?branch=master)](https://travis-ci.org/tzinfo/tzinfo) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/btinuu4g8sdachj3/branch/master?svg=true)](https://ci.appveyor.com/project/philr/tzinfo/branch/master)

[TZInfo](https://tzinfo.github.io) is a Ruby library that provides access to
time zone data and allows times to be converted using time zone rules.


Data Sources
------------

TZInfo requires a source of time zone data. There are two options:

1. A zoneinfo directory containing timezone definition files. These files are
   generated from the [IANA Time Zone Database](https://www.iana.org/time-zones)
   using the `zic` utility. Most Unix-like systems include a zoneinfo directory.
2. The TZInfo::Data library (the tzinfo-data gem). TZInfo::Data contains a set
   of Ruby modules that are also generated from the IANA Time Zone Database.

By default, TZInfo will attempt to use TZInfo::Data. If TZInfo::Data is not
available (i.e. if `require 'tzinfo/data'` fails), then TZInfo will search for a
zoneinfo directory instead (using the search path specified by
`TZInfo::ZoneinfoDataSource::DEFAULT_SEARCH_PATH`).

If no data source can be found, a `TZInfo::DataSourceNotFound` exception will be
raised when TZInfo is used. Further information is available
[in the wiki](https://tzinfo.github.io/datasourcenotfound) to help resolve
`TZInfo::DataSourceNotFound` errors.

The default data source selection can be overridden by calling
`TZInfo::DataSource.set`.

Custom data sources can also be used. See the `TZInfo::DataSource.set`
documentation for further details.


Installation
------------

The TZInfo gem can be installed by running `gem install tzinfo` or by adding
to `gem 'tzinfo'` to your `Gemfile` and running `bundle install`.

To use the Ruby modules as the data source, TZInfo::Data will also need to be
installed by running `gem install tzinfo-data` or by adding `gem 'tzinfo-data'`
to your `Gemfile`.


IANA Time Zone Database
-----------------------

The data returned and used by TZInfo is sourced from the
[IANA Time Zone Database](http://www.iana.org/time-zones). The
[Theory and pragmatics of the tz code and data](https://data.iana.org/time-zones/theory.html)
document gives details of how the data is organized and managed.


Example Usage
-------------

To use TZInfo, it must first be required with:

```ruby
require 'tzinfo'
```

The `TZInfo::Timezone` class provides access to time zone data and methods for
converting times.

The `all_identifiers` method returns a list of valid time zone identifiers:

```ruby
identifiers = TZInfo::Timezone.all_identifiers
# => ["Africa/Adibdjan", "Africa/Accra", ..., "Zulu"]
```

A `TZInfo::Timezone` instance representing an individual time zone can be
obtained with `TZInfo::Timezone.get`:

```ruby
tz = TZInfo::Timezone.get('America/New_York')
# => #<TZInfo::DataTimezone: America/New_York>
```

A time can be converted to the local time of the time zone with `to_local`:

```ruby
tz.to_local(Time.utc(2018, 2, 1, 12, 30, 0))
# => 2018-02-01 07:30:00 -0500
tz.to_local(Time.utc(2018, 7, 1, 12, 30, 0))
# => 2018-07-01 08:30:00 -0400
tz.to_local(Time.new(2018, 7, 1, 13, 30, 0, '+01:00'))
# => 2018-07-01 08:30:00 -0400
```

Local times with the appropriate offset for the time zone can be constructed
with `local_time`:

```ruby
tz.local_time(2018, 2, 1, 7, 30, 0)
# => 2018-02-01 07:30:00 -0500
tz.local_time(2018, 7, 1, 8, 30, 0)
# => 2018-07-01 08:30:00 -0400
```

Local times can be converted to UTC by using `local_time` and calling `utc` on
the result:

```ruby
tz.local_time(2018, 2, 1, 7, 30, 0).utc
# => 2018-02-01 12:30:00 UTC
tz.local_time(2018, 7, 1, 8, 30, 0).utc
# => 2018-07-01 12:30:00 UTC
```

The `local_to_utc` method can also be used to convert a time object to UTC. The
offset of the time is ignored - it is treated as if it were a local time for the
time zone:

```ruby
tz.local_to_utc(Time.utc(2018, 2, 1, 7, 30, 0))
# => 2018-02-01 12:30:00 UTC
tz.local_to_utc(Time.new(2018, 2, 1, 7, 30, 0, '+01:00'))
# => 2018-02-01 12:30:00 UTC
```

Information about the time zone can be obtained from returned local times:

```ruby
local_time = tz.to_local(Time.utc(2018, 2, 1, 12, 30, 0))
local_time.utc_offset  # => -18000
local_time.dst?        # => false
local_time.zone        # => "EST"

local_time = tz.to_local(Time.utc(2018, 7, 1, 12, 30, 0))
local_time.utc_offset  # => -14400
local_time.dst?        # => true
local_time.zone        # => "EDT"
```

Time zone information can be included when formatting times with `strftime`
using the `%z` and `%Z` directives:

```ruby
tz.to_local(Time.utc(2018, 2, 1, 12, 30, 0)).strftime('%Y-%m-%d %H:%M:%S %z %Z')
# => "2018-02-01 07:30:00 -0500 EST"
tz.to_local(Time.utc(2018, 7, 1, 12, 30, 0)).strftime('%Y-%m-%d %H:%M:%S %z %Z')
# => "2018-07-01 08:30:00 -0400 EDT"
```

The `period_for` method can be used to obtain information about the observed
time zone information at a particular time as a `TZInfo::TimezonePeriod` object:

```ruby
period = tz.period_for(Time.utc(2018, 7, 1, 12, 30, 0))
period.base_utc_offset          # => -18000
period.std_offset               # => 3600
period.current_utc_offset       # => -14400
period.abbreviation             # => "EDT"
period.dst?                     # => true
period.local_starts_at.to_time  # => 2018-03-11 03:00:00 -0400
period.local_ends_at.to_time    # => 2018-11-04 02:00:00 -0400
```

A list of transitions between periods where different rules are observed can be
obtained with the `transitions_up_to` method. The result is returned as an
`Array` of `TZInfo::TimzoneTransition` objects:

```ruby
transitions = tz.transitions_up_to(Time.utc(2019, 1, 1), Time.utc(2017, 1, 1))
transitions.map do |t|
  [t.local_end_at.to_time, t.offset.current_utc_offset, t.offset.abbreviation]
end
# => [[2017-03-12 02:00:00 -0500, -14400, "EDT"],
#     [2017-11-05 02:00:00 -0400, -18000, "EST"],
#     [2018-03-11 02:00:00 -0500, -14400, "EDT"],
#     [2018-11-04 02:00:00 -0400, -18000, "EST"]]
```

A list of the unique offsets used by a time zone can be obtained with the
`offsets_up_to` method. The result is returned as an `Array` of
`TZInfo::TimezoneOffset` objects:

```ruby
offsets = tz.offsets_up_to(Time.utc(2019, 1, 1))
offsets.map {|o| [o.current_utc_offset, o.abbreviation] }
# => [[-17762, "LMT"],
#     [-18000, "EST"],
#     [-14400, "EDT"],
#     [-14400, "EWT"],
#     [-14400, "EPT"]]
```

All `TZInfo::Timezone` methods that accept a time as a parameter can be used
with either instances of `Time`, `DateTime` or `TZInfo::Timestamp`. Methods that
also return times will return an object with a matching type (actually a
`TZInfo::TimeWithOffset`, `TZInfo::DateTimeWithOffset` or
`TZInfo::TimestampWithOffset` when returning a local time):

```ruby
tz.to_local(Time.utc(2018, 7, 1, 12, 30, 0))
# => 2018-07-01 08:30:00 -0400
tz.to_local(DateTime.new(2018, 7, 1, 12, 30, 0))
# => #<TZInfo::DateTimeWithOffset: 2018-07-01T08:30:00-04:00 ((2458301j,45000s,0n),-14400s,2299161j)>
tz.to_local(TZInfo::Timestamp.create(2018, 7, 1, 12, 30, 0, 0, :utc))
# => #<TZInfo::TimestampWithOffset: @value=1530448200, @sub_second=0, @utc_offset=-14400, @utc=false>
```

In addition to `local_time`, which returns `Time` instances, the
`local_datetime` and `local_timestamp` methods can be used to construct local
`DateTime` and `TZInfo::Timestamp` instances with the appropriate offset:

```ruby
tz.local_time(2018, 2, 1, 7, 30, 0)
# => 2018-02-01 07:30:00 -0500
tz.local_datetime(2018, 2, 1, 7, 30, 0)
# => #<TZInfo::DateTimeWithOffset: 2018-02-01T07:30:00-05:00 ((2458151j,45000s,0n),-18000s,2299161j)>
tz.local_timestamp(2018, 2, 1, 7, 30, 0)
# => #<TZInfo::TimestampWithOffset: @value=1517488200, @sub_second=0, @utc_offset=-18000, @utc=false>
```

The `local_to_utc`, `local_time`, `local_datetime` and `local_timestamp` methods
may raise a `TZInfo::PeriodNotFound` or a `TZInfo::AmbiguousTime` exception.
`TZInfo::PeriodNotFound` signals that there is no equivalent UTC time (for
example, during the transition from standard time to daylight savings time when
the clocks are moved forward and an hour is skipped). `TZInfo::AmbiguousTime`
signals that there is more than one equivalent UTC time (for example, during the
transition from daylight savings time to standard time where the clocks are
moved back and an hour is repeated):

```ruby
tz.local_time(2018, 3, 11, 2, 30, 0, 0)
# raises TZInfo::PeriodNotFound (2018-03-11 02:30:00 is an invalid local time.)
tz.local_time(2018, 11, 4, 1, 30, 0, 0)
# raises TZInfo::AmbiguousTime (2018-11-04 01:30:00 is an ambiguous local time.)
```

`TZInfo::PeriodNotFound` exceptions can only be resolved by adjusting the time,
for example, by advancing an hour:

```ruby
tz.local_time(2018, 3, 11, 3, 30, 0, 0)
# => 2018-03-11 03:30:00 -0400
```

`TZInfo::AmbiguousTime` exceptions can be resolved by setting the `dst`
parameter and/or specifying a block to choose one of the interpretations:

```ruby
tz.local_time(2018, 11, 4, 1, 30, 0, 0, true)
# => 2018-11-04 01:30:00 -0400
tz.local_time(2018, 11, 4, 1, 30, 0, 0, false)
# => 2018-11-04 01:30:00 -0500

tz.local_time(2018, 11, 4, 1, 30, 0, 0) {|p| p.first }
# => 2018-11-04 01:30:00 -0400
tz.local_time(2018, 11, 4, 1, 30, 0, 0) {|p| p.last }
# => 2018-11-04 01:30:00 -0500
```

The default value of the `dst` parameter can also be set globally:

```ruby
TZInfo::Timezone.default_dst = true
tz.local_time(2018, 11, 4, 1, 30, 0, 0)
# => 2018-11-04 01:30:00 -0400
TZInfo::Timezone.default_dst = false
tz.local_time(2018, 11, 4, 1, 30, 0, 0)
# => 2018-11-04 01:30:00 -0500
```

TZInfo also provides information about
[ISO 3166-1](https://www.iso.org/iso-3166-country-codes.html) countries and
their associated time zones via the `TZInfo::Country` class.

A list of valid ISO 3166-1 (alpha-2) country codes can be obtained by calling
`TZInfo::Country.all_codes`:

```ruby
TZInfo::Country.all_codes
# => ["AD", "AE", ..., "ZW"]
```

A `TZInfo::Country` instance representing an individual time zone can be
obtained with `TZInfo::Country.get`:

```ruby
c = TZInfo::Country.get('US')
# => #<TZInfo::Country: US>
c.name
# => "United States"
```

The `zone_identifiers` method returns a list of the time zone identifiers used
in a country:

```ruby
c.zone_identifiers
# => ["America/New_York", "America/Detroit", ..., "Pacific/Honolulu"]
```

The `zone_info` method returns further information about the time zones used in
a country as an `Array` of `TZInfo::CountryTimezone` instances:

```ruby
zi = c.zone_info.first
zi.identifier               # => "America/New_York"
zi.latitude.to_f.round(5)   # => 40.71417
zi.longitude.to_f.round(5)  # => -74.00639
zi.description              # => "Eastern (most areas)"
```

The `zones` method returns an `Array` of `TZInfo::Timezone` instances for a
country. A `TZInfo::Timezone` instance can be obtained from a
`TZInfo::CountryTimezone` using the `timezone` method:

```ruby
zi.timezone.to_local(Time.utc(2018, 2, 1, 12, 30, 0))
# => 2018-02-01 07:30:00 -0500
```

For further detail, please refer to the API documentation for the
`TZInfo::Timezone` and `TZInfo::Country` classes.


Compatibility
-------------

TZInfo v2.0.0 requires a minimum of Ruby MRI 1.9.3, JRuby 1.7 (in 1.9 mode or
later) or Rubinius 3.


Thread-Safety
-------------

The `TZInfo::Country` and `TZInfo::Timezone` classes are thread-safe. It is safe
to use class and instance methods of `TZInfo::Country` and `TZInfo::Timezone` in
concurrently executing threads. Instances of both classes can be shared across
thread boundaries.


Documentation
-------------

API documentation for TZInfo is available on
[RubyDoc.info](http://rubydoc.info/gems/tzinfo/).


License
-------

TZInfo is released under the MIT license, see LICENSE for details.


Source Code
-----------

Source code for TZInfo is available on
[GitHub](https://github.com/tzinfo/tzinfo).


Issue Tracker
-------------

Please post any bugs, issues, feature requests or questions to the
[GitHub issue tracker](https://github.com/tzinfo/tzinfo/issues).
