module TZInfo
  module Data
    # TZInfo::Data version number.
    VERSION = '2.2018.5.test'

    # TZInfo::Data version information.
    module Version
      # The format of the Ruby modules. TZInfo v2.0.0 supports formats 1 and 2.
      FORMAT = 2

      # TZInfo::Data version number.
      STRING = VERSION

      # The version of the {IANA Time Zone Database}[http://www.iana.org/time-zones]
      # used to generate this version of TZInfo::Data.
      TZDATA = '2018e'
    end
  end
end
