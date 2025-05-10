









-- Question 1
SELECT TOP 1 
    t.tag_name AS Category,
    COUNT(b.ISBN) AS TotalBooks
FROM Book b
JOIN Tag t ON b.Tag_ID = t.Tag_ID
GROUP BY t.tag_name
ORDER BY TotalBooks DESC;

-- Question 2
SELECT b.ISBN, b.book_title
FROM Book b
LEFT JOIN BookCopy bc ON b.ISBN = bc.ISBN
LEFT JOIN Loan l ON bc.BookCopy_ID = l.BookCopy_ID
WHERE l.BookCopy_ID IS NULL;


-- Question 3
SELECT u.User_ID, u.first_name, u.last_name, COUNT(*) AS TotalLoans
FROM Loan l
JOIN [User] u ON l.User_ID = u.User_ID
GROUP BY u.User_ID, u.first_name, u.last_name
HAVING COUNT(*) > 2;

-- Question 4
SELECT 
    t.tag_name AS Category,
    g.genre_name AS Genre,
    COUNT(b.ISBN) AS TotalBooks
FROM Book b
JOIN Tag t ON b.Tag_ID = t.Tag_ID
JOIN Genre g ON b.Genre_ID = g.Genre_ID
GROUP BY ROLLUP(t.tag_name, g.genre_name);

-- Question 5 
SELECT 
    u.User_ID,
    u.first_name,
    u.last_name,
    COUNT(*) AS OverdueLoans,
    SUM(l.loan_fine_amount) AS TotalFine
FROM Loan l
JOIN [User] u ON l.User_ID = u.User_ID
JOIN BookCopy bc ON l.BookCopy_ID = bc.BookCopy_ID
JOIN Book b ON bc.ISBN = b.ISBN
JOIN Tag t ON b.Tag_ID = t.Tag_ID
WHERE 
    l.return_date IS NOT NULL AND 
    l.return_date > DATEADD(DAY, t.loan_period, l.loan_created_date)
GROUP BY u.User_ID, u.first_name, u.last_name;


