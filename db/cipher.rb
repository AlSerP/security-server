module Db
  require 'stringio'

  class Cipher
    class << self
      SECURE_FILE_PATH = 'ssl/private.secure.pem'
      PHRASE_FILE_PATH = 'ssl/pass_phrase'

      def read(data)
        load_key unless @key

        # decrypted_str = ''

        # decrypted_str

        decrypted_str = ''
        cipher = OpenSSL::Cipher.new('aes-256-cbc')
        cipher.decrypt
        cipher.key = @key
        cipher.iv = @pass_phrase 

        io = StringIO.new(data)
        until io.eof?
          chunk = io.read(128)
          # decrypted_str << @key.private_decrypt(chunk)
          decrypted_str << cipher.update(chunk)
        end
        decrypted_str << cipher.final

        # decrypted_str = cipher.update([data].pack("H*")) + cipher.final

        # buf = ""
        # while data.read(4096, buf)
        #   decrypted_str << cipher.update(buf)
        # end
        # decrypted_str << cipher.final

        # @key.private_decrypt(data)
        decrypted_str
      end

      def encrypt(data)
        load_key unless @key

        encrypted_str = ''
        
        cipher = OpenSSL::Cipher.new('aes-256-cbc')
        cipher.encrypt
        cipher.key = @key
        cipher.iv = @pass_phrase

        # buf = ''
        # while data.read(4096, buf)
        #   encrypted_str << cipher.update(buf)
        # end
        # encrypted_str << cipher.final

        io = StringIO.new(data)
        until io.eof?
          chunk = io.read(128)
          # encrypted_str << @key.public_encrypt(chunk)
          encrypted_str << cipher.update(chunk)
        end
        encrypted_str << cipher.final

        encrypted_str
      end

      private

      def load_phrase
        # @pass_phrase = File.open('ssl/pass_phrase').read
        @pass_phrase = File.open(PHRASE_FILE_PATH).read

        @pass_phrase
      end

      def load_key
        unless File.exist?(SECURE_FILE_PATH)
          cipher = OpenSSL::Cipher.new('aes-256-cbc')
          cipher.encrypt
          key = cipher.random_key
          iv = cipher.random_iv

          File.open(SECURE_FILE_PATH, 'wb') do |outf|
            outf << key
          end
          File.open(PHRASE_FILE_PATH, 'wb') do |outf|
            outf << iv
          end
        end

        load_phrase unless @pass_phrase

        @key = File.open(SECURE_FILE_PATH).read
        # @key = OpenSSL::PKey.read key_pem, @pass_phrase
          
        @key
      end
    end
  end
end