require "./header"
require "./error"

# Algorithm used for hashing the data.
enum SleepParser::HashType
  # [BLAKE2b](https://blake2.net/) hashing algorithm.
  BLAKE2b
  # [Ed25519](https://ed25519.cr.yp.to/) hashing algorithm.
  Ed25519
  # No hashing used.
  None

  def to_io(io, endianess = ByteFormat::NetworkEndian)
    string = to_s
    io << string.size.to_8
    io << string
    nil
  end

  def to_s
    case self
    in BLAKE2b, Ed25519 then previous_def
    in None             then ""
    end
  end

  def self.from_io(io, endianess = ByteFormat::NetworkEndian)
    length = UInt8.from_io(io, endianess)

    unless length <= ALGORITHM_MAX_LENGTH
      raise Error.new("Algorithm name is too long: #{length} (max: #{ALGORITHM_MAX_LENGTH})")
    end

    if io.post + length > io.size
      raise Error.new("Algorithm name exceed bounds of the buffer")
    end

    algorithm = io.read_string(length)

    case algorithm
    when BLAKE2b.to_s then BLAKE2b
    when Ed25519.to_s then Ed25519
    when None.to_s    then None
    else
      raise Error.new("Unexpected hash algorithm: #{algorithm}")
    end
  end
end
