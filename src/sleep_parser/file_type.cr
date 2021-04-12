require "./hash_type"

# # Type of file.
# `signatures`, `bitfield` and `tree` are the three SLEEP files. There are two
# additional files, `key`, and `data`, which do not contain SLEEP file headers
# and store plain serialized data for easy access. `key` stores the public key
# that is described by the `signatures` file, and `data` stores the raw chunk
# data that the `tree` file contains the hashes and metadata.
enum SleepParser::FileType : UInt8
  # The bitfield describes which pieces of data you have, and which nodes in
  # the tree file have been written.  This file exists as an index of the tree
  # and data to quickly figure out which pieces of data you have or are
  # missing. This file can be regenerated if you delete it, so it is
  # considered a materialized index.
  Bitfield = 0

  # A SLEEP formatted 32 byte header with data entries being 64 byte
  # signatures.
  Signatures = 1

  # A SLEEP formatted 32 byte header with data entries representing a
  # serialized Merkle tree based on the data in the data storage layer. All
  # the fixed size nodes written in in-order tree notation. The header
  # algorithm string for `tree` files is `BLAKE2b`. The entry size is 40
  # bytes.
  Tree = 2

  def valid_entry_size?(entry_size : UInt16) : Bool
    case self
    in .bitfield?   then 3328_u16
    in .signatures? then 64_u16
    in .tree?       then 40_u16
    end == entry_size
  end

  def valid_hash_type?(hash_type : HashType) : Bool
    case self
    in .bitfield?   then hash_type.none?
    in .signatures? then hash_type.ed25519?
    in .tree?       then hash_type.blake2b?
    end
  end
end
