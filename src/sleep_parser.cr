require "./sleep_parser/header"

module SleepParser
  # Create a new `Header` in the `Bitfield` configuration.
  def self.create_bitfield : Header
    Header.new(FileType::Bitfield, 3328_u16, HashType::None)
  end

  # Create a new `Header` in the `Signatures` configuration.
  def self.create_signatures : Header
    Header.new(FileType::Signatures, 64_u16, HashType::Ed25519)
  end

  # Create a new `Header` in the `Tree` configuration.
  def self.create_tree : Header
    Header.new(FileType::Tree, 40_u16, HashType::BLAKE2b)
  end
end
