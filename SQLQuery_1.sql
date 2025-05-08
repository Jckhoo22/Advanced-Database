USE RKB_Library;



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
--                               Trigger                                --
--------------------------------------------------------------------------
/*======================================================================*/
-- Enforce Max Loan Limit <10 --
CREATE TRIGGER TRG_Loan_INS_MaxLoanLimit
ON Loan
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if any user exceeds 10 active loans
    IF EXISTS (
        SELECT i.user_id
        FROM inserted i
        JOIN Loan l ON i.user_id = l.user_id
        WHERE l.return_date IS NULL
        GROUP BY i.user_id
        HAVING COUNT(*) > 10
    )
    BEGIN
        RAISERROR ('User has exceeded the maximum allowed number of active loans (10).', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
/*======================================================================*/

-- Automatically set expiry after 3 days --
CREATE TRIGGER TRG_Reservation_INS_SetExpiryDate
ON Reservation
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update expiry_date to 3 days after reservation_created_date
    UPDATE r
    SET r.expiry_date = DATEADD(DAY, 3, i.reservation_created_date)
    FROM Reservation r
    JOIN inserted i ON r.reservation_id = i.reservation_id;
END;
/*======================================================================*/

-- Auto expire outdated reservations --
CREATE TRIGGER TRG_Reservation_UPD_ExpireStatus
ON Reservation
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Set related BookCopy to 'Available' if reservation has expired
    UPDATE bc
    SET bc.availability_status = 'Available'
    FROM BookCopy bc
    JOIN Reservation r ON bc.bookcopy_id = r.bookcopy_id
    JOIN inserted i ON r.reservation_id = i.reservation_id
    WHERE r.expiry_date < GETDATE();
END;
/*======================================================================*/

-- Set BookCopy to “Loaned” on loan --
CREATE TRIGGER TRG_Loan_INS_SetCopyToLoaned
ON Loan
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update BookCopy availability to 'Loaned' after loan is inserted
    UPDATE bc
    SET bc.availability_status = 'Loaned'
    FROM BookCopy bc
    JOIN inserted i ON bc.bookcopy_id = i.bookcopy_id;
END;
/*======================================================================*/

-- Set BookCopy to “Available” on return --
CREATE TRIGGER TRG_Loan_UPD_SetCopyToAvailable
ON Loan
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Update BookCopy to 'Available' when return_date is set
    UPDATE bc
    SET bc.availability_status = 'Available'
    FROM BookCopy bc
    JOIN inserted i ON bc.bookcopy_id = i.bookcopy_id
    JOIN deleted d ON i.loan_id = d.loan_id
    WHERE i.return_date IS NOT NULL AND d.return_date IS NULL;
END;
/*======================================================================*/

-- Restrict non-lecturers from reference books --
CREATE TRIGGER TRG_Loan_INS_RefBookLecturerOnly
ON Loan
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Allow insert only if either:
    -- (a) The book is loanable, OR
    -- (b) The user is a lecturer if the book is non-loanable
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN BookCopy bc ON i.bookcopy_id = bc.bookcopy_id
        JOIN Book b ON bc.isbn = b.isbn
        JOIN Tag t ON b.tag_id = t.tag_id
        WHERE t.loanable_status = 'Non-Loanable'
          AND NOT EXISTS (
              SELECT 1
              FROM Lecturer l
              JOIN Staff s ON l.user_id = s.user_id
              WHERE s.user_id = i.user_id
          )
    )
    BEGIN
        RAISERROR ('Only lecturers are allowed to loan reference (non-loanable) books.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- If passed, allow the original insert
    INSERT INTO Loan (loan_id, user_id, bookcopy_id, loan_created_date, return_date, loan_fine_amount)
    SELECT loan_id, user_id, bookcopy_id, loan_created_date, return_date, loan_fine_amount
    FROM inserted;
END;
/*======================================================================*/

-- Prevent book deletion if copies exist --
CREATE TRIGGER TRG_Book_DEL_CheckCopyExists
ON Book
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Prevent deletion if there are existing BookCopies or BookAuthors for this Book
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN BookCopy bc ON d.isbn = bc.isbn
    ) OR EXISTS (
        SELECT 1
        FROM deleted d
        JOIN BookAuthor ba ON d.isbn = ba.isbn
    )
    BEGIN
        RAISERROR ('Cannot delete book. Existing book copies or author associations found.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- If safe, allow deletion
    DELETE FROM Book
    WHERE isbn IN (SELECT isbn FROM deleted);
END;
/*======================================================================*/

-- One room booking per user at a time & Validate Duration <= 3 hours --
CREATE TRIGGER TRG_RoomBooking_INS_ValidateDurationAndCheckOverlap
ON RoomBooking
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Rule 1: Reject if duration > 3 hours (180 minutes)
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE DATEDIFF(MINUTE, room_booking_created_time, end_time) > 180
    )
    BEGIN
        RAISERROR ('Room bookings must not exceed 3 hours.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Rule 2: Reject if booking overlaps with another booking by the same user
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN RoomBooking rb
          ON rb.user_id = i.user_id
         AND rb.end_time > i.room_booking_created_time
         AND rb.room_booking_created_time < i.end_time
    )
    BEGIN
        RAISERROR ('User already has a room booking that overlaps with the requested time.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Passed both checks: allow insertion
    INSERT INTO RoomBooking (RoomBooking_ID, user_id, room_id, room_booking_created_time, end_time)
    SELECT RoomBooking_ID, user_id, room_id, room_booking_created_time, end_time
    FROM inserted;
END;
/*======================================================================*/

-- Prevent duplicate reservation for same copy by user --
CREATE TRIGGER TRG_Reservation_INS_NoDuplicateCopy
ON Reservation
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Prevent duplicate reservation for the same BookCopy by the same user
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Reservation r
          ON r.user_id = i.user_id
         AND r.bookcopy_id = i.bookcopy_id
    )
    BEGIN
        RAISERROR ('Duplicate reservation is not allowed for the same book copy by the same user.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- If not duplicate, allow insert
    INSERT INTO Reservation (Reservation_ID, user_id, bookcopy_id, reservation_created_date, expiry_date)
    SELECT Reservation_ID, user_id, bookcopy_id, reservation_created_date, expiry_date
    FROM inserted;
END;
/*======================================================================*/



--------------------------------------------------------------------------
--                        SQL Query Question 2                          --
--------------------------------------------------------------------------
/*======================================================================*/
-- 1) Find the presentation room which has the greatest number of bookings
SELECT TOP 1 rb.room_id, r.room_name, COUNT(*) AS total_bookings
FROM RoomBooking rb
JOIN Room r ON rb.room_id = r.room_id
GROUP BY rb.room_id, r.room_name
ORDER BY total_bookings DESC;
/*======================================================================*/

-- 2) Show the person who have never made any loan.
SELECT u.user_id, u.first_name, u.email
FROM [User] u
LEFT JOIN Loan l ON u.user_id = l.user_id
WHERE l.loan_id IS NULL;
/*======================================================================*/

-- 3) Find the person who paid the highest total fine.
SELECT TOP 1 u.user_id, u.first_name, u.email, SUM(l.loan_fine_amount) AS total_fines
FROM [User] u
JOIN Loan l ON u.user_id = l.user_id
GROUP BY u.user_id, u.first_name, u.email
ORDER BY total_fines DESC;
/*======================================================================*/

-- 4) Create a query which provides, 
--    for the loan, the total amount of fine 
--    from different types of persons in the university 
--    such as staff and student.
SELECT 
    PersonType,
    SUM(loan_fine_amount) AS total_fine
FROM (
    SELECT 
        u.user_id,
        CASE 
            WHEN s.user_id IS NOT NULL THEN 'Student'
            WHEN lec.user_id IS NOT NULL THEN 'Lecturer'
            WHEN lib.user_id IS NOT NULL THEN 'Librarian'
            WHEN sta.user_id IS NOT NULL THEN 'Staff'
            ELSE 'Unknown'
        END AS PersonType,
        l.loan_fine_amount
    FROM Loan l
    JOIN [User] u ON l.user_id = u.user_id
    LEFT JOIN Student s ON u.user_id = s.user_id
    LEFT JOIN Lecturer lec ON u.user_id = lec.user_id
    LEFT JOIN Librarian lib ON u.user_id = lib.user_id
    LEFT JOIN Staff sta ON u.user_id = sta.user_id
) AS fine_data
GROUP BY ROLLUP(PersonType);
/*======================================================================*/

-- 5) Develop one additional query of your own 
--    which provides information that would be useful 
--    for the business. 
SELECT TOP 5 
    b.isbn,
    b.book_title,
    COUNT(r.reservation_id) AS total_reservations
FROM Reservation r
JOIN BookCopy bc ON r.BookCopy_ID = bc.BookCopy_ID
JOIN Book b ON bc.isbn = b.isbn
GROUP BY b.isbn, b.book_title
ORDER BY total_reservations DESC;
/*
- This query identifies the top 5 most reserved books.
- Library staff analyze demand trends.
- Understand which books should be prioritized 
  for future acquisitions or promotions.
*/
/*======================================================================*/
