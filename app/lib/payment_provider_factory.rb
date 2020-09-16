class PaymentProviderFactory
  def self.provider
    @provider ||= Provider.new
  end

  def debit_card(user)
  end
end
#
#class Provider
#  def debit_card(user)
#    return user.first_name  + ' ' + user.last_name + " have succussful paid"
#  end
#end