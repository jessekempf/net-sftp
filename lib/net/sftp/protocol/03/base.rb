require 'net/sftp/protocol/02/base'

module Net; module SFTP; module Protocol; module V03

  # Wraps the low-level SFTP calls for version 3 of the SFTP protocol.
  #
  # None of these protocol methods block--all of them return immediately,
  # requiring the SSH event loop to be run while the server response is
  # pending.
  #
  # You will almost certainly never need to use this driver directly. Please
  # see Net::SFTP::Session for the recommended interface.
  class Base < V02::Base

    # Returns the protocol version implemented by this driver. (3, in this
    # case)
    def version
      3
    end

    # Sends a FXP_READLINK packet to the server to request that the target of
    # the given symlink on the remote host (+path+) be returned.
    def readlink(path)
      send_request(FXP_READLINK, :string, path)
    end

    # Sends a FXP_SYMLINK packet to the server to request that a symlink at the
    # given +path+ be created, pointing at +target+..
    def symlink(path, target)
      send_request(FXP_SYMLINK, :string, path, :string, target)
    end

    # Support for SFTP v3+ vendor extensioning.
    def load_extensions(extensions)
      @extensions = extensions.map { |ext| { ext.fetch(:method_name) => ext } }.reduce(&:merge)
    end

    def parse(request, packet)
      if packet.type == FXP_EXTENDED_REPLY
        parse_extended_packet(request.type, packet)
      else
        super(request, packet)
      end
    end

    private

    def parse_extended_packet(type, packet)
      @extensions.fetch(type).fetch(:protocol_parse_extension_packet).call(packet)
    end
  end

end; end; end; end
