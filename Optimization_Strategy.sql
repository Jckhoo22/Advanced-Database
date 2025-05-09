use RKB_Library_OS;

--------------------------------------------------------------------------
--                        Optimization Strategy                         --
--------------------------------------------------------------------------
--                 (Materialized View / Indexed View)                   --
--------------------------------------------------------------------------
/*======================================================================*/
/* without Optimization Strategy */
-- This query is to counts how many times each book (by ISBN) was loaned
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT TOP 10 bc.ISBN, COUNT(*) AS TotalLoans
FROM Loan l
JOIN BookCopy bc ON l.BookCopy_ID = bc.BookCopy_ID
GROUP BY bc.ISBN
ORDER BY TotalLoans DESC;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
/*======================================================================*/

/* with Optimization Strategy */
-- This view counts how many times each book (by ISBN) was loaned
CREATE VIEW vw_MostFrequentlyLoanedBooks
WITH SCHEMABINDING
AS
SELECT 
    bc.ISBN,
    COUNT_BIG(*) AS TotalLoans
FROM dbo.Loan l
JOIN dbo.BookCopy bc ON l.BookCopy_ID = bc.BookCopy_ID
GROUP BY bc.ISBN;
GO

-- Indexed view requires a unique clustered index
CREATE UNIQUE CLUSTERED INDEX idx_MostFrequentlyLoanedBooks
ON vw_MostFrequentlyLoanedBooks(ISBN);

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT TOP 10 ISBN, TotalLoans
FROM vw_MostFrequentlyLoanedBooks
ORDER BY TotalLoans DESC;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
/*======================================================================*/

drop view vw_MostFrequentlyLoanedBooks;
