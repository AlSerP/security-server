module Db
  class Cipher
    class << self
      def read(data)
        load_key unless @key

        @key.private_decrypt data
      end

      def encrypt(data)
        load_key unless @key

        # res = []

        # data.bytes.each_slice(128) { |slice| res << @key.public_encrypt(slice) }
        @key.public_encrypt data
        # res
      end

      private

      def load_phrase
        @pass_phrase = File.open('ssl/pass_phrase').read
      end

      def load_key
        load_phrase unless @pass_phrase

        key_pem = File.read 'ssl/private.secure.pem'
        @key = OpenSSL::PKey.read key_pem, @pass_phrase
      end
    end
  end
end