
require 'pg'
require 'faker'
require 'date'


client_counter = 0
account_counter = 0
investment_counter = 0
loan_counter = 0
transfer_counter = 0
bank_branch_counter = 0
dep_withdr_counter = 0

conn = PG.connect( dbname: 'Main', user:"postgres", password: "111111" ) 

conn.exec("TRUNCATE clients,accounts,investments,loans,transfers,bank_branches,deposits_withdraws;")
conn.exec("ALTER SEQUENCE clients_client_id_seq RESTART WITH 1")
conn.exec("ALTER SEQUENCE accounts_account_id_seq RESTART WITH 1")
conn.exec("ALTER SEQUENCE investments_investment_id_seq RESTART WITH 1")
conn.exec("ALTER SEQUENCE loans_loan_id_seq RESTART WITH 1")
conn.exec("ALTER SEQUENCE transfers_transfer_id_seq RESTART WITH 1")
conn.exec("ALTER SEQUENCE bank_branches_branch_id_seq RESTART WITH 1")
conn.exec("ALTER SEQUENCE deposits_withdraws_dep_withd_id_seq RESTART WITH 1")

branch_gen_count = 10_000
client_gen_count = 5
transfer_gen_count = 10_000_000

branch_gen_count.times do

branch_adress = Faker::Address.full_address.gsub(/\'/, ' ')  
postal_index = Faker::Number.unique.number(digits: 8)

conn.exec("INSERT INTO bank_branches(adress,postal_index) 
           VALUES('#{branch_adress}',#{postal_index})")
bank_branch_counter += 1

    if bank_branch_counter%100==0
        p bank_branch_counter.to_s+" banks."
    end
end

Faker::UniqueGenerator.clear 

output_counter = 0
while transfer_counter < transfer_gen_count do

    first_name = Faker::Name.first_name.gsub(/\'/, ' ')  
    middle_name = Faker::Name.middle_name.gsub(/\'/, ' ')  
    last_name = Faker::Name.last_name.gsub(/\'/, ' ') 
    passport_serial_and_number = Faker::Number.unique.number(digits: 10)
    passport_serial = passport_serial_and_number.digits[0..3].map(&:to_s).join('')
    passport_number = passport_serial_and_number.digits[4..9].map(&:to_s).join('')
    citizenship = Faker::Address.country.gsub(/\'/, ' ')  
    adress = Faker::Address.full_address.gsub(/\'/, ' ')  

    conn.exec("INSERT INTO clients(first_name,middle_name,last_name,passport_serial,passport_number,citizenship,adress) 
                            VALUES('#{first_name}','#{middle_name}','#{last_name}',#{passport_serial},#{passport_number},'#{citizenship}','#{adress}')")
    client_counter += 1

    client_accounts = rand(1..3)

    client_accounts.times do

        account_type = ['credit','debit'].sample
        created_on = Faker::Date.between(from: '1990-01-01', to: '2022-01-01')
        created_time = "#{"%02d" % rand(0..23)}:#{"%02d" % rand(0..59)}:#{"%02d" % rand(0..59)}"
        account_money = Faker::Number.decimal(l_digits: 5, r_digits: 2)
        currency_type = ["RUB"].sample # ,"USD"

        conn.exec("INSERT INTO accounts(client_id,account_type,created_on,account_money,currency_type) 
                                VALUES(#{client_counter},'#{account_type}','#{created_on.to_s+" "+created_time}',#{account_money},'#{currency_type}')")
        account_counter += 1

        if account_counter >= 5

            account_transfer = rand(20..50)

            account_transfer.times do

                account_id_to = rand(1..(account_counter-1))
                transferred_money = Faker::Number.decimal(l_digits: 3, r_digits: 2)
                # todo make dates larger than account(p. done)
                transfer_date = Faker::Date.between(from: created_on, to: '2022-01-01')
                transfer_time = "#{"%02d" % rand(0..23)}:#{"%02d" % rand(0..59)}:#{"%02d" % rand(0..59)}"
                currency_type = ["RUB"].sample # ,"USD"
               
                conn.exec("INSERT INTO transfers(account_id_from,account_id_to,transferred_money,transfer_date,currency_type) 
                VALUES(#{account_counter},'#{account_id_to}',#{transferred_money},'#{transfer_date.to_s+" "+transfer_time}','#{currency_type}')")
                
                transfer_counter += 1

            end

        end


        account_dep_with = rand(20..50)

        account_dep_with.times do

        transferred_money = Faker::Number.decimal(l_digits: 3, r_digits: 2)
        transfer_date = Faker::Date.between(from: created_on, to: '2022-01-01')
        transfer_time = "#{"%02d" % rand(0..23)}:#{"%02d" % rand(0..59)}:#{"%02d" % rand(0..59)}"
        bank_branch_id = rand(1..bank_branch_counter)
        currency_type = ["RUB"].sample # ,"USD"

        conn.exec("INSERT INTO deposits_withdraws(account_id,transferred_money,bank_branch_id,transfer_date,currency_type) 
                                VALUES(#{account_counter},#{transferred_money},'#{bank_branch_id}','#{transfer_date.to_s+" "+transfer_time}','#{currency_type}')")
        dep_withdr_counter += 1

        end

        if account_type == "credit"

            loan_account = rand(0..3)

            loan_account.times do

                loan_type = ['personal','revolving','debt conversion'].sample
                loan_money = Faker::Number.number(digits: 4)
                percent = Faker::Number.between(from: 3.0, to: 20.0).round(2)
                currency_type = ["RUB"].sample # ,"USD"
                loan_start_date = Faker::Date.between(from: created_on, to: '2022-06-01')
                loan_end_date = Faker::Date.between(from: loan_start_date, to: '2025-06-01')
        
        
                conn.exec("INSERT INTO loans(account_id,loan_type,loan_money,percent,currency_type,loan_start,loan_end) 
                                        VALUES(#{account_counter},'#{loan_type}',#{loan_money},#{percent},'#{currency_type}','#{loan_start_date}','#{loan_end_date}')")
                loan_counter += 1

            end
        end
        if account_type == "debit"

            investment_type = ['personal','revolving','debt conversion'].sample
            invested_money = Faker::Number.number(digits: 4)
            percent = Faker::Number.between(from: 3.0, to: 20.0).round(2)
            currency_type = ["RUB"].sample # ,"USD"
            investment_start_date = Faker::Date.between(from: created_on, to: '2022-06-01')
            investment_end_date = Faker::Date.between(from: investment_start_date, to: '2025-06-01')
    


            conn.exec("INSERT INTO investments(account_id,investment_type,invested_money,percent,currency_type,investment_start,investment_end) 
            VALUES(#{account_counter},'#{investment_type}',#{invested_money},#{percent},'#{currency_type}','#{investment_start_date}','#{investment_end_date}')")
            investment_counter += 1
        end 

    end
    output_counter += 1
    if output_counter%50==0
        p transfer_counter.to_s+" transfers."
    end
end


# acc_type = conn.exec("SELECT account_type FROM accounts WHERE account_id = #{2}")

# account_counter.times do |account_id|

#     account = conn.exec("SELECT account_type FROM accounts WHERE account_id = #{account_id}").values[0][0]
#     acc_type = account[0][0]
    


# end

p "Total"
p client_counter
p account_counter
p investment_counter
p loan_counter
p transfer_counter
p bank_branch_counter
p dep_withdr_counter


