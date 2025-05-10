-- Ronald Oh Fu Ming
-- Test the subqueries
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Create subqueries
SELECT 
    bc.BookCopy_ID,
    (SELECT book_title 
     FROM Book 
     WHERE ISBN = bc.ISBN) AS book_title,
    a.author_name
FROM 
    BookCopy bc,
    BookAuthor ba,
    Author a
WHERE 
    bc.BookCopy_ID = 'BC00001'
    AND ba.ISBN = bc.ISBN
    AND a.Author_ID = ba.Author_ID;


SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- Test the join queries
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Create join queries
SELECT 
    bc.BookCopy_ID,
    b.book_title,
    a.author_name
FROM BookCopy bc 
JOIN Book b ON bc.ISBN = b.ISBN
JOIN BookAuthor ba ON b.ISBN = ba.ISBN
JOIN Author a ON ba.Author_ID = a.Author_ID
WHERE bc.BookCopy_ID = 'BC00001';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;