require "./error"
require "./file_type"
require "./hash_type"
require "./protocol_version"

struct SleepParser::Header
  # Type of file.
  getter file_type : FileType
  # Version of the SLEEP protocol.
  getter protocol_version : ProtocolVersion
  # Size of each piece of data in the file body.
  getter entry_size : UInt16
  # Algorithm used for hashing the content.
  getter hash_type : HashType

  def valid? : Bool
    file_type.valid_entry_size?(entry_size) && file_type.valid_hash_type?(entry_size)
  end

  def initialize(
    @file_type,
    @entry_size,
    @hash_type,
    @protocol_version = ProtocolVersion::V0
  )
  end

  HEADER_LENGTH        = 32
  ALGORITHM_MAX_LENGTH = HEADER_LENGTH - 8
  INDICATOR            = Slice[5_u8, 2_u8, 87_u8]

  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::NetworkEndian)
    # Write IO to a buffer
    buffer = IO::Memory.new(HEADER_LENGTH)
    io.pipe(buffer)

    raise Error.new("SLEEP header incorrectly sized, got #{slice.size} bytes") unless buffer.size == HEADER_LENGTH

    indicator = Slice.new(INDICATOR.size)
    buffer.read(indicator)

    unless indicator == INDICATOR
      raise Error.new("The indicator bytes of a SLEEP header should be #{INDICATOR}, got #{indicator}")
    end

    file_type = FileType.from_value(UInt8.from_io(buffer))
    protocol_version = ProtocolVersion.from_value(UInt8.from_io(buffer))
    entry_size = UInt16.from_io(buffer, ByteFormat::BigEndian)
    hash_type = HashType.from_io(buffer)

    new(file_type, entry_size, hash_type, protocol_version)
  end

  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::NetworkEndian)
    io << INDICATOR
    io << file_type.to_value
    io << protocol_version.to_value
    entry_size.to_io(io, ByteFormat::BigEndian)
    hash_type.to_io(io)
  end
end
