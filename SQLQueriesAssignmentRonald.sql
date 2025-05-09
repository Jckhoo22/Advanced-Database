USE RKB_Library;
GO

-- Q1
WITH HighestLoanCount AS (
    SELECT l.User_ID, u.first_name, u.last_name, COUNT(*) AS loan_count
    FROM Loan l 
    JOIN [User] u ON l.User_ID = u.User_ID
    GROUP BY l.User_ID, u.first_name, u.last_name
)
SELECT User_ID, first_name, last_name, loan_count
FROM HighestLoanCount
WHERE loan_count = (SELECT MAX(loan_count) FROM HighestLoanCount);

-- Q2
WITH NumberOfBookLoans AS (
    SELECT bc.ISBN, b.book_title, COUNT(*) AS times_loaned
    FROM Loan l 
    JOIN BookCopy bc ON l.BookCopy_id = bc.BookCopy_id
    JOIN Book b ON bc.ISBN = b.ISBN
    GROUP BY bc.ISBN, b.book_title
)
SELECT ISBN, book_title, times_loaned
FROM NumberOfBookLoans
WHERE times_loaned = (SELECT MAX(times_loaned) FROM NumberOfBookLoans);

-- Q3
SELECT b.ISBN, b.book_title, COUNT(ba.author_id) AS author_count
FROM Book b
JOIN BookAuthor ba 
ON b.ISBN = ba.ISBN
GROUP BY b.ISBN, b.book_title
HAVING COUNT(ba.author_id) > 2;

-- Q4
SELECT 
    COALESCE(person_type, 'Total') AS person_type,
    COALESCE(borrower_status, 'Total') AS borrower_status,
    full_name,
    total_borrowers
FROM (
    SELECT 
        person_type,
        borrower_status,
        full_name,
        GROUPING(person_type) AS grp_person_type,
        GROUPING(borrower_status) AS grp_borrower_status,
        COUNT(*) AS total_borrowers
    FROM (
        -- Students
        SELECT 
            s.User_ID,
            'Student' AS person_type,
            CASE 
                WHEN EXISTS (
                    SELECT 1 
                    FROM Loan l 
                    WHERE l.User_ID = s.User_ID
                ) THEN 'Active'
                ELSE 'Inactive'
            END AS borrower_status,
            u.first_name + ' ' + u.last_name AS full_name
        FROM Student s
        JOIN [User] u ON s.User_ID = u.User_ID

        UNION ALL

        -- Staff
        SELECT 
            st.User_ID,
            'Staff' AS person_type,
            CASE 
                WHEN EXISTS (
                    SELECT 1 
                    FROM Loan l 
                    WHERE l.User_ID = st.User_ID
                ) THEN 'Active'
                ELSE 'Inactive'
            END AS borrower_status,
            u.first_name + ' ' + u.last_name AS full_name
        FROM Staff st
        JOIN [User] u ON st.User_ID = u.User_ID
    ) AS categorized_borrowers
    GROUP BY ROLLUP(person_type, borrower_status, full_name)
) AS aggregated
WHERE 
    (grp_person_type = 0 AND grp_borrower_status = 0) -- Detailed rows with individual names
    OR (grp_person_type = 0 AND grp_borrower_status = 1) -- Subtotals by person_type
    OR (grp_person_type = 1 AND grp_borrower_status = 1) -- Grand total
ORDER BY 
    person_type, 
    borrower_status, 
    full_name;

-- Q5 additional sql query (Top 5 Books borrowed per months	from last 6 months)
WITH TopBooks AS (
    -- Step 1: Identify the top 5 most borrowed books in the last 6 months
    SELECT TOP 5 
        bc.ISBN,
        b.book_title,
        COUNT(*) AS total_loans
    FROM LOAN l
    JOIN BOOKCOPY bc ON l.BookCopy_ID = bc.BookCopy_ID
    JOIN BOOK b ON bc.ISBN = b.ISBN
    WHERE l.loan_created_date >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY bc.ISBN, b.book_title
    ORDER BY total_loans DESC
),
MonthlyTrend AS (
    -- Step 2: Get monthly loan counts for the top 5 books
    SELECT 
        tb.book_title,
        FORMAT(l.loan_created_date, 'yyyy-MM') AS loan_month,
        COUNT(*) AS loan_count
    FROM LOAN l
    JOIN BOOKCOPY bc ON l.BookCopy_ID = bc.BookCopy_ID
    JOIN TopBooks tb ON bc.ISBN = tb.ISBN
    WHERE l.loan_created_date >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY tb.book_title, FORMAT(l.loan_created_date, 'yyyy-MM')
)
-- Step 3: Display the results
SELECT 
    book_title,
    loan_month,
    loan_count
FROM MonthlyTrend
GROUP BY book_title, loan_month
ORDER BY loan_count DESC;

-- Q5 additional SQL query (Top 5 Books borrowed per months from last 6 months)
WITH TopBooks AS (
    -- Step 1: Identify the top 5 most borrowed books in the last 6 months
    SELECT TOP 5 
        bc.ISBN,
        b.book_title,
        COUNT(*) AS total_loans
    FROM LOAN l
    JOIN BOOKCOPY bc ON l.BookCopy_ID = bc.BookCopy_ID
    JOIN BOOK b ON bc.ISBN = b.ISBN
    WHERE l.loan_created_date >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY bc.ISBN, b.book_title
    ORDER BY total_loans DESC
),
MonthlyTrend AS (
    -- Step 2: Get monthly loan counts for the top 5 books
    SELECT 
        tb.book_title,
        FORMAT(l.loan_created_date, 'yyyy-MM') AS loan_month,
        COUNT(*) AS loan_count
    FROM LOAN l
    JOIN BOOKCOPY bc ON l.BookCopy_ID = bc.BookCopy_ID
    JOIN TopBooks tb ON bc.ISBN = tb.ISBN
    WHERE l.loan_created_date >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY tb.book_title, FORMAT(l.loan_created_date, 'yyyy-MM')
)
-- Step 3: Display the results with highest loan count at the top
SELECT 
    book_title,
    loan_month,
    loan_count
FROM MonthlyTrend
ORDER BY loan_count DESC, book_title, loan_month;
