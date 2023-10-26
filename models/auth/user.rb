module Auth
  class User
    attr_reader :username, :password

    MARKS = %[, . : ; ? ! " ' - _]

    def initialize(username, password, is_blocked=false, is_validating=false)
      @username = username
      @password = password

      @is_blocked = is_blocked
      @is_validating = is_validating

      @is_admin = false
    end

    def admin?
      @is_admin
    end

    def blocked?
      @is_blocked
    end

    def block
      @is_blocked = !@is_blocked
    end

    def turn_validate
      @is_validating = !@is_validating
    end

    def validating?
      @is_validating
    end

    def save
      return nil unless Db::Database.find_user username

      Db::Database.save
    end

    def change_password(old_password, new_password)
      return nil unless old_password == @password
      return nil unless password_valid? new_password
      
      @password = new_password
      save
    end

    def login?(password)
      password == @password
    end

    def empty_password?
      @password.empty?
    end

    def password_valid?(password)
      return true unless validating?

      is_lower = false
      is_upper = false
      is_marks = false

      password.each_char do |s|
        is_lower = true if s >= 'a' && s <= 'z'
        is_upper = true if s >= 'A' && s <= 'Z'
        is_marks = true if MARKS.include? s
      end

      puts "RESULTS IS #{is_lower} #{is_upper} #{is_marks}"
      is_lower && is_upper && is_marks
    end

    class << self
      def login(username, password)
        current_user = nil

        Db::Database.users.each do |user|
          current_user = user if username == user.username
        end

        return nil unless current_user
        current_user if current_user.login? password
      end

      def uniq?(username)
        Db::Database.find_user(username) ? false : true 
      end
    end

    def to_hash
      {
        "username" => @username,
        "password" => @password,
        "is_admin" => admin?,
        "is_blocked" => blocked?,
        "is_validating" => validating?
      }
    end

    def to_json
      to_hash.to_json
    end

    def to_s
      @username
    end
  end
end
