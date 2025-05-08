USE RKB_Library_OS;

--------------------------------------------------------------------------
--                             Create Table                             --
--------------------------------------------------------------------------
/*======================================================================*/
CREATE TABLE [User] (
    User_ID VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    contact_number VARCHAR(20),
    email VARCHAR(100),
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')), -- only 3 
    address VARCHAR(255),
    account_status VARCHAR(20) CHECK (account_status IN ('active', 'suspended', 'terminated')) -- For Achieving Enum Status
);
/*======================================================================*/

CREATE TABLE LoginCredentials (
    User_ID VARCHAR(10) PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(100),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);
/*======================================================================*/

CREATE TABLE Student (
    User_ID VARCHAR(10) PRIMARY KEY,
    program VARCHAR(100),
    faculty VARCHAR(100),
    enrollment_date DATE,
    CGPA DECIMAL(3,2) CHECK (CGPA >= 0 AND CGPA <= 4), -- Check Between 0 and 4 and conditional 3 digits max & 2 decimals max
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);
/*======================================================================*/

CREATE TABLE Staff (
    User_ID VARCHAR(10) PRIMARY KEY,
    start_working_date DATE,
    salary DECIMAL(10,2) CHECK (salary >= 0), 
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);
/*======================================================================*/

CREATE TABLE Librarian (
    User_ID VARCHAR(10) PRIMARY KEY,
    shift_starting_time TIME,
    shift_ending_time TIME,
    shift_branch VARCHAR(100),
    shift_task TEXT, -- description based use Text just in case too long
    FOREIGN KEY (User_ID) REFERENCES Staff(User_ID)
);
/*======================================================================*/

CREATE TABLE Lecturer (
    User_ID VARCHAR(10) PRIMARY KEY,
    department VARCHAR(100),
    specialization VARCHAR(100),
    office_hour VARCHAR(50),
    office_location VARCHAR(100),
    FOREIGN KEY (User_ID) REFERENCES Staff(User_ID)
);
/*======================================================================*/

CREATE TABLE AgeSuggestion (
    AgeSuggestion_ID VARCHAR(10) PRIMARY KEY,
    rating_label VARCHAR(50),
    min_age INT,
    description TEXT -- description based use Text just in case too long
);
/*======================================================================*/

CREATE TABLE Genre (
    Genre_ID VARCHAR(10) PRIMARY KEY,
    genre_name VARCHAR(100),
    genre_description TEXT -- description based use Text just in case too long
);
/*======================================================================*/

CREATE TABLE Tag (
    Tag_ID VARCHAR(10) PRIMARY KEY,
    tag_name VARCHAR(50),
    fine_rate DECIMAL(5,2),
    loan_period INT,
    loanable_status VARCHAR(20) CHECK (loanable_status IN ('loanable', 'non loanable'))
);
/*======================================================================*/

CREATE TABLE Book (
    ISBN VARCHAR(20) PRIMARY KEY,
    book_title VARCHAR(255),
    Genre_ID VARCHAR(10),
    AgeSuggestion_ID VARCHAR(10),
    Tag_ID VARCHAR(10),
    FOREIGN KEY (Genre_ID) REFERENCES Genre(Genre_ID),
    FOREIGN KEY (AgeSuggestion_ID) REFERENCES AgeSuggestion(AgeSuggestion_ID),
    FOREIGN KEY (Tag_ID) REFERENCES Tag(Tag_ID)
);
/*======================================================================*/

CREATE TABLE BookDescription (
    ISBN VARCHAR(20) PRIMARY KEY,
    description TEXT,
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN)
);
/*======================================================================*/

CREATE TABLE Author (
    Author_ID VARCHAR(10) PRIMARY KEY,
    author_name VARCHAR(100)
);
/*======================================================================*/

CREATE TABLE BookAuthor (
    ISBN VARCHAR(20),
    Author_ID VARCHAR(10),
    PRIMARY KEY (ISBN, Author_ID),
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN),
    FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID)
);
/*======================================================================*/

CREATE TABLE BookCopy (
    BookCopy_ID VARCHAR(10) PRIMARY KEY,
    ISBN VARCHAR(20),
    availability_status VARCHAR(20) CHECK (availability_status IN ('Available', 'Loaned', 'Reserved')), -- Store Reservation & Loan Status
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN)
);
/*======================================================================*/

CREATE TABLE Loan (
    Loan_ID VARCHAR(10) PRIMARY KEY,
    BookCopy_ID VARCHAR(10),
    User_ID VARCHAR(10),
    loan_fine_amount DECIMAL(6,2) CHECK (loan_fine_amount >= 0), -- max 6 digits so can be up to thousand (e.g. Rm9999.99)
    loan_created_date DATE,
    return_date DATE,
    FOREIGN KEY (BookCopy_ID) REFERENCES BookCopy(BookCopy_ID),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);
/*======================================================================*/

CREATE TABLE Reservation (
    Reservation_ID VARCHAR(10) PRIMARY KEY,
    BookCopy_ID VARCHAR(10),
    User_ID VARCHAR(10),
    reservation_created_date DATE,
    expiry_date DATE,
    FOREIGN KEY (BookCopy_ID) REFERENCES BookCopy(BookCopy_ID),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);
/*======================================================================*/

CREATE TABLE Room (
    Room_ID VARCHAR(10) PRIMARY KEY,
    room_name VARCHAR(100)
);
/*======================================================================*/

CREATE TABLE RoomDetails (
    Room_ID VARCHAR(10) PRIMARY KEY,
    room_capacity INT,
    room_floor INT,
    maintenance_status VARCHAR(20) CHECK (maintenance_status IN ('available', 'under maintenance', 'closed')),
    FOREIGN KEY (Room_ID) REFERENCES Room(Room_ID)
);
/*======================================================================*/

CREATE TABLE RoomBooking (
    RoomBooking_ID VARCHAR(10) PRIMARY KEY,
    Room_ID VARCHAR(10),
    User_ID VARCHAR(10),
    room_booking_created_time DATETIME,
    end_time DATETIME,
    FOREIGN KEY (Room_ID) REFERENCES Room(Room_ID),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);
/*======================================================================*/



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

SELECT TOP 5 bc.ISBN, COUNT(*) AS TotalLoans
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

SELECT TOP 5 ISBN, TotalLoans
FROM vw_MostFrequentlyLoanedBooks
ORDER BY TotalLoans DESC;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
/*======================================================================*/



--------------------------------------------------------------------------
--                        Add Data Into Table                           --
--------------------------------------------------------------------------
