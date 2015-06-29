Feature: Credit Card Transaction
	I want to create a order with one credit card transaction.

            Scenario: Pay a order using credit card and installment
                Given I have purchase three products with a total cost of BRL 250
                And I will pay using a Visa credit card in 3 installments
                And I will send to Mundipagg
                Then the order amount in cents should be 25000
                And the transaction status should be Captured

            Scenario: Pay a order using credit card without installment
                Given I have purchase three products with a total cost of BRL 100,29
                And I will pay using a Visa credit card without installment
                And I will send to Mundipagg
                Then the order amount in cents should be 10029
                And the transaction status should be Captured

            Scenario: Keeping sensible information unlogged
                Given I have purchase three products with a total cost of BRL 100,29
                And I will pay using a Visa credit card without installment
                And I will send to Mundipagg
                Then the log file doesn't contain sensible information

            Scenario: Pay a order using credit card using instant buy key
                Given I have purchase three products with a total cost of BRL 100,29
                And I will pay using a Visa credit card without installment
                And I will send to Mundipagg
                When I pay another order with the instant buy key
                Then the transaction status should be Captured


  	Scenario: Pay a order using credit card and installment
	   Given I have purchase three products with Shopping Cart a total cost of BRL 300
	   And I will pay using a Visa credit card in 3 installments
	   And I will send to Mundipagg
	   Then the order amount in cents should be 30000
	   And the transaction status should be Captured

    Scenario: Pay an order setting SSL certificate
      Given I have purchase three products with a total cost of BRL 100,29
      And I set SSL certificate file
      And Savon client is mocked
      And I will pay using a Visa credit card without installment
      And I will send to Mundipagg
      Then it must send SSL certificate
