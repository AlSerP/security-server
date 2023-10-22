module Auth
  class Admin < Auth::User
    def initialize(*params)
      super(*params)
      @is_admin = true
    end
  end
end