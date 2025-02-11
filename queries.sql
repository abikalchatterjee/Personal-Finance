--Adding new user

INSERT INTO users (name, email, password)
VALUES
    ('Amit', 'amit.sinha@gmail.com', 'password'),
    ('Jai', 'jai.sql@gmail.com', 'smallpassword'),
    ('Nick', 'nick.project@gmail.com', 'bigpassword'),
    ('Adam', 'adam.smith@gmail.com', 'safepassword'),
    ('Shiv', 'shiv.edx@gmail.com', 'onlypassword');


--Adding new account

INSERT INTO accounts (user_id, name, balance)
VALUES
    (1, 'SBI', '10000'),
    (2, 'AXIS', '15000'),
    (3, 'HDFC', '5000'),
    (4, 'SBI', '18000'),
    (5, 'ICICI', '25000');


--Adding new category

INSERT INTO categories (name)
VALUES
    ('Fuel'),
    ('Food'),
    ('Entertainment'),
    ('Grocery'),
    ('MISC'),
    ('Income');





--Adding new transaction

INSERT INTO transactions (account_id, category_id, amount, description)
VALUES
    (1, 1, '-2000', 'Travel'),
    (2, 3, '-1000', 'Movie'),
    (3, 4, '-2500', 'Montly_grocery'),
    (4, 5, '-6000', 'Wifi_recharge'),
    (5, 2, '-3000', 'anniversary_dinner');
    (3, 6, '25000', 'Salary'),
    (2, 6, '30000', 'Salary'),
    (1, 6, '20000', 'Salary'),
    (4, 6, '35000', 'Salary'),
    (5, 6, '28000', 'Salary');


--Adding new budget

INSERT INTO budgets (category_id, amount, start_date, end_date)
VALUES
    (1, '5000', '2025-01-01', '2025-01-31'),
    (2, '4000', '2025-01-01', '2025-01-31'),
    (3, '3000', '2025-01-01', '2025-01-31'),
    (4, '8000', '2025-01-01', '2025-01-31'),
    (5, '6000', '2025-01-01', '2025-01-31');



--Query to view account of a user

SELECT *
FROM accounts
WHERE user_id = 1;


--Query for monthly expenditure

SELECT
    strftime('%Y-%m', transactions.datetime) AS month,
    SUM(CASE WHEN transactions.amount < 0 THEN transactions.amount ELSE 0 END) AS expenditure
FROM transactions
WHERE acoount_id = 1
GROUP BY month;

--Query Budget performance

SELECT
    categories.name AS category,
    budgets.amount AS budget,
    ABS(COALESCE(SUM(transactions.amount), 0)) AS spent,
    budgets.amount - ABS(COALESCE(SUM(transactions.amount), 0)) AS balance
FROM categories
JOIN budgets
ON categories.id = budgets.category_id
LEFT JOIN transactions
ON budgets.category_id  = transactions.category_id
WHERE budgets.start_date <= CURRENT_DATE AND budgets.end_date >= CURRENT_DATE
GROUP BY categories.name, budgets.amount;




--Create query for under budget categories

SELECT
    categories.name AS category,
    budgets.amount AS budget,
    ABS(COALESCE(SUM(transactions.amount), 0)) AS spent
FROM categories
JOIN transactions
ON categories.id = transactions.category_id
JOIN budgets
ON budgets.category_id = transactions.category_id
WHERE budgets.start_date <= CURRENT_DATE AND budgets.end_date >= CURRENT_DATE
GROUP BY category, budget
HAVING spent < budget;


--Creating query for account update with all transactions


SELECT
    users.id AS user_id,
    users.name AS user,
    accounts.name AS account_name,
    accounts.balance AS starting_balance,
    SUM(CASE WHEN transactions.amount > 0 THEN transactions.amount ELSE 0 END) AS total_income,
    ABS(SUM(CASE WHEN transactions.amount < 0 THEN transactions.amount ELSE 0 END)) AS total_expenditure,
    accounts.balance + SUM(CASE WHEN transactions.amount > 0 THEN transactions.amount ELSE 0 END) - ABS(SUM(CASE WHEN transactions.amount < 0 THEN transactions.amount ELSE 0 END)) AS remaining_balance
FROM users
JOIN accounts
ON users.id = accounts.user_id
JOIN transactions
ON accounts.id = transactions.account_id
WHERE transactions.datetime BETWEEN '2025-01-01' AND '2025-01-31'
GROUP BY user_id;
