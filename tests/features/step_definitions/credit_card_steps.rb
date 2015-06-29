
#Scenario 1:
Before do
  @mocks = Object.new
  RSpec::Mocks.setup @mocks

	@client = Mundipagg::Gateway.new :test
	@client.log_level = :debug
	@order = Mundipagg::CreateOrderRequest.new
	@order.merchantKey = TestConfiguration::Merchant::MerchantKey
	@transaction = Mundipagg::CreditCardTransaction.new
	@order.creditCardTransactionCollection << @transaction
	@response = Hash.new
    @shoppingCart = Mundipagg::ShoppingCart.new
    @shoppingCartItem = Mundipagg::ShoppingCartItem.new
    @order.shoppingCartCollection << @shoppingCart

end


Given(/^I have purchase three products with a total cost of (\w+) (\d+)$/) do |currency,amount|
	amount = BigDecimal.new(amount.gsub(',', '.'))
	@order.amountInCents = (amount * 100).to_i
	@order.amountInCentsToConsiderPaid = (amount * 100).to_i
	@order.currencyIsoEnum = 'BRL'
end

Given(/^I have purchase three products with Shopping Cart a total cost of (\w+) (\d+)$/) do |currency,amount|
    amount = BigDecimal.new(amount.gsub(',', '.'))
    @order.amountInCents = (amount * 100).to_i
    @order.amountInCentsToConsiderPaid = (amount * 100).to_i
    @order.currencyIsoEnum = 'BRL'

    @shoppingCartItem.itemReference = 'Test'
    @shoppingCartItem.description = 'Test'
    @shoppingCartItem.name = 'Test'
    @shoppingCartItem.quantity = 3
    @shoppingCartItem.totalCostInCents = 3000
    @shoppingCartItem.unitCostInCents = 1000


    @shoppingCart.freightCostInCents = 30
    @shoppingCart.shoppingCartItemCollection << @shoppingCartItem

    @order.shoppingCartCollection << @shoppingCart
end

Given(/^I will pay using a (\w+) credit card in (\d+) installments$/) do |brand,installments|
	@transaction.creditCardBrandEnum = brand
	@transaction.installmentCount = installments
	@transaction.paymentMethodCode = 1
	@transaction.amountInCents = @order.amountInCents
	@transaction.holderName = 'Ruby Unit Test'
	@transaction.creditCardNumber = '41111111111111111'
	@transaction.securityCode = '123'
	@transaction.expirationMonth = 5
	@transaction.expirationYear = 2018
	@transaction.creditCardOperationEnum = Mundipagg::CreditCardTransaction.OperationEnum[:AuthAndCapture]
end

Given(/^I will send to Mundipagg$/) do
  old_stdout = $stdout
  @stdout = StringIO.new
  $stdout = @stdout
  @client.log_level = :debug
  begin
    @response = @client.CreateOrder(@order)
  ensure
    $stdout = old_stdout
  end
end

Then(/^the order amount in cents should be (\d+)$/) do |amountInCents|

	transaction = @response[:create_order_response][:create_order_result][:credit_card_transaction_result_collection][:credit_card_transaction_result]
	transaction[:amount_in_cents].to_s.should == amountInCents
end

Then(/^the transaction status should be (\w+)$/) do |status|
	transaction = @response[:create_order_response][:create_order_result][:credit_card_transaction_result_collection][:credit_card_transaction_result]
	transaction[:credit_card_transaction_status_enum].to_s.downcase.should == status.downcase
end


#Scenario 2:

Given(/^I have purchase three products with a total cost of (\w+) (\d+),(\d+)$/) do |currency, amount, cents|
	amount = amount+'.'+cents
	amount = BigDecimal.new(amount.gsub(',', '.'))
	@order.amountInCents = (amount * 100).to_i
	@order.amountInCentsToConsiderPaid = (amount * 100).to_i
	@order.currencyIsoEnum = currency

end

Given(/^I will pay using a (\w+) credit card without installment$/) do |brand|
	@transaction.creditCardBrandEnum = brand
	@transaction.installmentCount = 1
	@transaction.paymentMethodCode = 1
	@transaction.amountInCents = @order.amountInCents
	@transaction.holderName = 'Ruby Unit Test'
	@transaction.creditCardNumber = '41111111111111111'
	@transaction.securityCode = '123'
	@transaction.expirationMonth = 5
	@transaction.expirationYear = 2018
	@transaction.creditCardOperationEnum = Mundipagg::CreditCardTransaction.OperationEnum[:AuthAndCapture]

end

#Scenario 3:

Then(/^the log file doesn't contain sensible information$/) do
  @stdout.string.should_not include(@transaction.creditCardNumber)
  @stdout.string.should_not include(@transaction.securityCode)
  @stdout.string.should_not include(@order.merchantKey)
end

#Scenario 4:
When(/^I pay another order with the instant buy key$/) do
  @order = Mundipagg::CreateOrderRequest.new
  @order.merchantKey = TestConfiguration::Merchant::MerchantKey
  amount = 100
  @transaction = Mundipagg::CreditCardTransaction.new
  @order.creditCardTransactionCollection << @transaction

  @order.amountInCents = (amount * 100).to_i
  @order.amountInCentsToConsiderPaid = (amount * 100).to_i
  @order.currencyIsoEnum = 'BRL'

  @transaction.creditCardBrandEnum = 'Visa'
  @transaction.instantBuyKey = @response[:create_order_response][:create_order_result][:credit_card_transaction_result_collection][:credit_card_transaction_result][:instant_buy_key]
  @transaction.installmentCount = 1
  @transaction.paymentMethodCode = 1
  @transaction.amountInCents = @order.amountInCents
  @transaction.creditCardOperationEnum = Mundipagg::CreditCardTransaction.OperationEnum[:AuthAndCapture]

  old_stdout = $stdout
  @stdout = StringIO.new
  $stdout = @stdout
  @client.log_level = :debug
  begin
    @response = @client.CreateOrder(@order)
  ensure
    $stdout = old_stdout
  end
end

Given(/^I set SSL certificate file$/) do
  @client.ssl_certificate_file = 'sample_certificate.crt'
end

Given(/^Savon client is mocked$/) do
  savon_client = @mocks.double(call: {}, fetch: {})
  savon_options = {
    wsdl: 'https://transaction.mundipaggone.com/MundiPaggService.svc?wsdl',
    log: true,
    log_level: :debug,
    filters: [:CreditCardNumber, :SecurityCode, :MerchantKey],
    namespaces: { 'xmlns:mun' => 'http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts' },
    ssl_cert_file: 'sample_certificate.crt'
  }

  RSpec::Mocks.allow_message(Savon, :client).and_call_original
  RSpec::Mocks.expect_message(Savon, :client).with(savon_options).
    and_return savon_client
end

Then(/^it must send SSL certificate$/) do
  RSpec::Mocks.verify
end

