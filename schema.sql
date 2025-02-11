--Creating the users table


CREATE TABLE "users"(
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "password" TEXT NOT NULL,
    PRIMARY KEY ("id")
);


--Creating accounts table

CREATE TABLE "accounts" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "balance" NUMERIC NOT NULL DEFAULT 0.00,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("user_id") REFERENCES "users"("id")
);

--Creating category table

CREATE TABLE "categories" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    PRIMARY KEY ("id")
);

--Creating Transactions table

CREATE TABLE "transactions" (
    "id" INTEGER,
    "account_id" INTEGER NOT NULL,
    "category_id" INTEGER NOT NULL,
    "amount" NUMERIC NOT NULL,
    "datetime" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "description" TEXT NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("account_id") REFERENCES "accounts"("id"),
    FOREIGN KEY ("category_id") REFERENCES "categories"("id")
);

-- Creating budget table"

CREATE TABLE "budgets" (
    "id" INTEGER,
    "category_id" INTEGER NOT NULL,
    "amount" NUMERIC NOT NULL,
    "start_date" NUMERIC NOT NULL,
    "end_date" NUMERIC NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("category_id") REFERENCES "categories"("id")
);

--Creating user name index

CREATE INDEX "user_name"
ON "users"("name");

--Creating email index

CREATE INDEX "user_email"
ON "users"("email");

--Creating accounts name index

CREATE INDEX "accounts_name"
ON "accounts"("name");

--Create amount index

CREATE INDEX "transaction_amount"
ON "transactions"("amount");

--Create date index

CREATE INDEX "transaction_date"
ON "transactions"("datetime");

--Create category type

CREATE INDEX "category_type"
ON "categories"("name");


--Creating account summary view

CREATE VIEW "user_account_summary" AS
SELECT
    users.id AS user_id,
    users.name AS user_name,
    accounts.id AS account_id,
    accounts.name AS account_name,
    accounts.balance AS account_balance,
    COUNT(transactions.id) AS transaction_count
FROM users
JOIN accounts
ON users.id = accounts.user_id
JOIN transactions
ON accounts.id = transactions.account_id
GROUP BY users.id, users.name, accounts.id, accounts.name, accounts.balance ;


--Creating monthly expenses view

CREATE VIEW "monthly_expenses" AS
SELECT
    accounts.id AS account_id,
    accounts.name AS account_name,
    strftime('%Y-%m', transactions.datetime) AS month,
    SUM(CASE WHEN transactions.amount < 0 THEN transactions.amount ELSE 0 END) AS total_expenses
FROM accounts
JOIN transactions
ON accounts.id = transactions.account_id
GROUP BY accounts.id, accounts.name, month
ORDER BY month DESC;

-- Creating budgetary performance view

CREATE VIEW "budget_performance" AS
SELECT
    budgets.id AS budget_id,
    categories.name AS spent_name,
    budgets.amount AS budget_limit,
    COALESCE(SUM(transactions.amount), 0) AS expenditure,
    budgets.start_date AS start_date,
    budgets.end_date AS end_date,
    CASE
        WHEN COALESCE(SUM(transactions.amount), 0) > budgets.amount THEN 'over_spent'
        ELSE 'within_limit'
    END AS status
FROM budgets
JOIN categories
ON budgets.category_id = categories.id
LEFT JOIN transactions
ON budgets.category_id = transactions.category_id
AND transactions.datetime BETWEEN budgets.start_date AND budgets.end_date
GROUP BY budgets.id, categories.name, budgets.amount, budgets.start_date, budgets.end_date;

--Creating transaction history view

CREATE VIEW "transactions_history" AS
SELECT
    transactions.id AS transaction_id,
    transactions.amount AS amount_spent,
    transactions.datetime AS spent_date,
    categories.name AS spent_type,
    accounts.name AS account_name,
    transactions.description AS spent_description
FROM transactions
JOIN accounts
ON transactions.account_id = accounts.id
LEFT JOIN categories
ON transactions.category_id = categories.id
ORDER BY transactions.datetime DESC;


--Creating spending summary view

CREATE VIEW "spending_summary" AS
SELECT
    users.id AS user_id,
    users.name AS user_name,
    SUM(CASE WHEN transactions.amount > 0 THEN transactions.amount ELSE 0 END) AS total_income,
    SUM(CASE WHEN transactions.amount < 0 THEN transactions.amount ELSE 0 END) AS total_expenditure,
    SUM(transactions.amount) AS net_balance
FROM users
JOIN accounts
ON users.id = accounts.user_id
LEFT JOIN transactions
ON accounts.id = transactions.account_id
GROUP BY users.id, users.name;



