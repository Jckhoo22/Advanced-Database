USE RKB_Library
GO

/*
  ____          _          _                            ____                    _    _               
 |  _ \   __ _ | |_  __ _ | |__    __ _  ___   ___     / ___| _ __  ___   __ _ | |_ (_)  ___   _ __  
 | | | | / _` || __|/ _` || '_ \  / _` |/ __| / _ \   | |    | '__|/ _ \ / _` || __|| | / _ \ | '_ \ 
 | |_| || (_| || |_| (_| || |_) || (_| |\__ \|  __/   | |___ | |  |  __/| (_| || |_ | || (_) || | | |
 |____/  \__,_| \__|\__,_||_.__/  \__,_||___/ \___|    \____||_|   \___| \__,_| \__||_| \___/ |_| |_|                                                                                                  

*/


CREATE TABLE [User]
(
    User_ID VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    contact_number VARCHAR(20),
    email VARCHAR(100),
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    -- only 3 
    address VARCHAR(255),
    account_status VARCHAR(20) CHECK (account_status IN ('active', 'suspended', 'terminated'))
    -- For Achieving Enum Status
);

CREATE TABLE LoginCredentials
(
    User_ID VARCHAR(10) PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(100),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);

CREATE TABLE Student
(
    User_ID VARCHAR(10) PRIMARY KEY,
    program VARCHAR(100),
    faculty VARCHAR(100),
    enrollment_date DATE,
    CGPA DECIMAL(3,2) CHECK (CGPA >= 0 AND CGPA <= 4),
    -- Check Between 0 and 4 and conditional 3 digits max & 2 decimals max
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);

CREATE TABLE Staff
(
    User_ID VARCHAR(10) PRIMARY KEY,
    start_working_date DATE,
    salary DECIMAL(10,2) CHECK (salary >= 0),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);

CREATE TABLE Librarian
(
    User_ID VARCHAR(10) PRIMARY KEY,
    shift_starting_time TIME,
    shift_ending_time TIME,
    shift_branch VARCHAR(100),
    shift_task TEXT,
    -- description based use Text just in case too long
    FOREIGN KEY (User_ID) REFERENCES Staff(User_ID)
);

CREATE TABLE Lecturer
(
    User_ID VARCHAR(10) PRIMARY KEY,
    department VARCHAR(100),
    specialization VARCHAR(100),
    office_hour VARCHAR(50),
    office_location VARCHAR(100),
    FOREIGN KEY (User_ID) REFERENCES Staff(User_ID)
);

CREATE TABLE AgeSuggestion
(
    AgeSuggestion_ID VARCHAR(10) PRIMARY KEY,
    rating_label VARCHAR(50),
    min_age INT,
    description TEXT
    -- description based use Text just in case too long
);

CREATE TABLE Genre
(
    Genre_ID VARCHAR(10) PRIMARY KEY,
    genre_name VARCHAR(100),
    genre_description TEXT
    -- description based use Text just in case too long
);

CREATE TABLE Tag
(
    Tag_ID VARCHAR(10) PRIMARY KEY,
    tag_name VARCHAR(50),
    fine_rate DECIMAL(5,2),
    loan_period INT,
    loanable_status VARCHAR(20) CHECK (loanable_status IN ('loanable', 'non loanable'))
);

CREATE TABLE Book
(
    ISBN VARCHAR(20) PRIMARY KEY,
    book_title VARCHAR(255),
    Genre_ID VARCHAR(10),
    AgeSuggestion_ID VARCHAR(10),
    Tag_ID VARCHAR(10),
    FOREIGN KEY (Genre_ID) REFERENCES Genre(Genre_ID),
    FOREIGN KEY (AgeSuggestion_ID) REFERENCES AgeSuggestion(AgeSuggestion_ID),
    FOREIGN KEY (Tag_ID) REFERENCES Tag(Tag_ID)
);

CREATE TABLE BookDescription
(
    ISBN VARCHAR(20) PRIMARY KEY,
    description TEXT,
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN)
);

CREATE TABLE Author
(
    Author_ID VARCHAR(10) PRIMARY KEY,
    author_name VARCHAR(100)
);

CREATE TABLE BookAuthor
(
    ISBN VARCHAR(20),
    Author_ID VARCHAR(10),
    PRIMARY KEY (ISBN, Author_ID),
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN),
    FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID)
);

CREATE TABLE BookCopy
(
    BookCopy_ID VARCHAR(10) PRIMARY KEY,
    ISBN VARCHAR(20),
    availability_status VARCHAR(20) CHECK (availability_status IN ('available', 'loaned', 'reserved')),
    -- Store Reservation & Loan Status
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN)
);

CREATE TABLE Loan
(
    Loan_ID VARCHAR(10) PRIMARY KEY,
    BookCopy_ID VARCHAR(10),
    User_ID VARCHAR(10),
    loan_fine_amount DECIMAL(6,2) CHECK (loan_fine_amount >= 0),
    -- max 6 digits so can be up to thousand (e.g. Rm9999.99)
    loan_created_date DATE,
    return_date DATE,
    FOREIGN KEY (BookCopy_ID) REFERENCES BookCopy(BookCopy_ID),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);

CREATE TABLE Reservation
(
    Reservation_ID VARCHAR(10) PRIMARY KEY,
    BookCopy_ID VARCHAR(10),
    User_ID VARCHAR(10),
    reservation_created_date DATE,
    expiry_date DATE,
    FOREIGN KEY (BookCopy_ID) REFERENCES BookCopy(BookCopy_ID),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);

CREATE TABLE Room
(
    Room_ID VARCHAR(10) PRIMARY KEY,
    room_name VARCHAR(100)
);

CREATE TABLE RoomDetails
(
    Room_ID VARCHAR(10) PRIMARY KEY,
    room_capacity INT,
    room_floor INT,
    maintenance_status VARCHAR(20) CHECK (maintenance_status IN ('available', 'under maintenance', 'closed')),
    FOREIGN KEY (Room_ID) REFERENCES Room(Room_ID)
);

CREATE TABLE RoomBooking
(
    RoomBooking_ID VARCHAR(10) PRIMARY KEY,
    Room_ID VARCHAR(10),
    User_ID VARCHAR(10),
    room_booking_created_time DATETIME,
    end_time DATETIME,
    FOREIGN KEY (Room_ID) REFERENCES Room(Room_ID),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);

/*
  _   _                    ____         _        
 | | | | ___   ___  _ __  |  _ \  ___  | |  ___  
 | | | |/ __| / _ \| '__| | |_) |/ _ \ | | / _ \ 
 | |_| |\__ \|  __/| |    |  _ <| (_) || ||  __/ 
  \___/ |___/ \___||_|    |_| \_\\___/ |_| \___| 

*/


-- User Access Roles (Librarian) 
CREATE LOGIN Lib WITH PASSWORD = '1';
-- Create Login to Sql Server

USE RKB_Library

CREATE USER librarian FOR LOGIN Lib;
-- Create User within that "Lib" Server

-- Access 1: For handling book loans (issue, return, fine)
GRANT SELECT, INSERT, UPDATE ON Loan TO librarian;

-- Access 2: For monitoring and updating reservations
GRANT SELECT, UPDATE ON Reservation TO librarian;

-- Access 3: For changing real-time book status (available, loaned, etc.)
GRANT SELECT, UPDATE ON BookCopy TO librarian;

-- Access 4: Allow librarians to read and modify tag
GRANT SELECT, UPDATE ON Tag TO librarian;

-- For explaining inquiries related to Book
GRANT SELECT ON Book to librarian;
GRANT SELECT ON BookDescription TO librarian;
GRANT SELECT ON Author TO librarian;
GRANT SELECT ON Genre TO librarian;

-- User Access (Student)
CREATE LOGIN Stud WITH PASSWORD = '1';
-- Create Login to Sql Server

USE RKB_Library

CREATE USER student FOR LOGIN Stud;
-- Create User within that "Stud" Server

-- Access 1: For Student to Search what is the book about
GRANT SELECT ON Book TO student;
GRANT SELECT ON BookDescription TO student;
GRANT SELECT ON Author TO student;
GRANT SELECT ON Genre TO student;

-- Access 2: For Student to Check Book Availability
GRANT SELECT ON BookCopy TO student;

-- Access 3: Reserve Books 
GRANT SELECT, INSERT ON Reservation TO student;

-- Access 4: Student View Own loans
GRANT SELECT ON Loan TO student;

-- Access 5: For Student to Book Presentation Room
GRANT SELECT, INSERT ON RoomBooking TO student;

-- Access 6: View room details
GRANT SELECT ON Room TO student;
GRANT SELECT ON RoomDetails TO student;

-- User Access (Lecturer)
CREATE LOGIN Lect WITH PASSWORD = '1';

USE RKB_Library;

CREATE USER lecturer FOR LOGIN Lect;
-- DB user name = 'lecturer'

-- Access 1: Lecturer can browse books, view genres, authors, and descriptions
GRANT SELECT ON Book TO lecturer;
GRANT SELECT ON BookDescription TO lecturer;
GRANT SELECT ON Author TO lecturer;
GRANT SELECT ON Genre TO lecturer;

-- Access 2: View copy availability (available, loaned, reserved, etc.)
GRANT SELECT ON BookCopy TO lecturer;

-- Access 3: View Tag details (so they can know which books are reference/non-loanable)
GRANT SELECT ON Tag TO lecturer;

-- Reservations
GRANT SELECT, INSERT ON Reservation TO lecturer;

-- View own loan history
GRANT SELECT ON Loan TO lecturer;

-- Room booking
GRANT SELECT, INSERT ON RoomBooking TO lecturer;
GRANT SELECT ON Room TO lecturer;
GRANT SELECT ON RoomDetails TO lecturer;

 /*
  ____   _                         _      ____                              _                   
 / ___| | |_  ___   _ __  ___   __| |    |  _ \  _ __  ___    ___  ___   __| | _   _  _ __  ___ 
 \___ \ | __|/ _ \ | '__|/ _ \ / _` |    | |_) || '__|/ _ \  / __|/ _ \ / _` || | | || '__|/ _ \
  ___) || |_| (_) || |  |  __/| (_| |    |  __/ | |  | (_) || (__|  __/| (_| || |_| || |  |  __/
 |____/  \__|\___/ |_|   \___| \__,_|    |_|    |_|   \___/  \___|\___| \__,_| \__,_||_|   \___|
                                                                                               
 */

-- SP1 -- Invoke Trigger 1
GO
CREATE PROCEDURE SP_Loan_Book
    @User_ID VARCHAR(10),
    @BookCopy_ID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if user has 10 or more active loans (no return_date yet)
    IF (
        SELECT COUNT(*) 
        FROM Loan 
        WHERE User_ID = @User_ID AND return_date IS NULL
    ) >= 10
    BEGIN
        RAISERROR('User already has 10 active loans.', 16, 1);
        RETURN;
    END

    -- Check if book copy is available
    IF (
        SELECT availability_status 
        FROM BookCopy 
        WHERE BookCopy_ID = @BookCopy_ID 
    ) != 'available' 
    BEGIN
        RAISERROR('Book copy is not available.', 16, 1);
        RETURN;
    END

    -- Check if the book is loanable via its Tag
    IF EXISTS (
        SELECT 1
        FROM Book b
        JOIN Tag t ON b.Tag_ID = t.Tag_ID
        JOIN BookCopy bc ON b.ISBN = bc.ISBN
        WHERE bc.BookCopy_ID = @BookCopy_ID AND t.loanable_status != 'loanable'
    )
    BEGIN
        RAISERROR('Book is not loanable.', 16, 1);
        RETURN;
    END

    -- All checks passed: insert into Loan
    INSERT INTO Loan (BookCopy_ID, User_ID, loan_fine_amount, loan_created_date)
    VALUES (@BookCopy_ID, @User_ID, 0, GETDATE());

    -- Update the book copy's availability to 'unavailable'
    UPDATE BookCopy
    SET availability_status = 'loaned'
    WHERE BookCopy_ID = @BookCopy_ID;
END;
GO

-- SP2 -- Invoke Trigger 2

GO
CREATE PROCEDURE SP_Return_Book
    @Loan_ID INT,
    @return_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BookCopy_ID VARCHAR(10);
    DECLARE @loan_created_date DATE;
    DECLARE @ISBN VARCHAR(20);
    DECLARE @Tag_ID VARCHAR(10);
    DECLARE @loan_period INT;
    DECLARE @fine_rate DECIMAL(10, 2);
    DECLARE @overdue_days INT;
    DECLARE @fine_amount DECIMAL(10, 2);

    -- Get loan details
    SELECT 
        @BookCopy_ID = BookCopy_ID,
        @loan_created_date = loan_created_date
    FROM Loan
    WHERE Loan_ID = @Loan_ID;

    -- Get ISBN from BookCopy
    SELECT @ISBN = ISBN
    FROM BookCopy
    WHERE BookCopy_ID = @BookCopy_ID;

    -- Get Tag_ID from Book
    SELECT @Tag_ID = Tag_ID
    FROM Book
    WHERE ISBN = @ISBN;

    -- Get loan_period and fine_rate from Tag
    SELECT 
        @loan_period = loan_period,
        @fine_rate = fine_rate
    FROM Tag
    WHERE Tag_ID = @Tag_ID;

    -- Calculate overdue days
    SET @overdue_days = DATEDIFF(DAY, @loan_created_date, @return_date) - @loan_period;
    IF @overdue_days < 0
        SET @overdue_days = 0;

    -- Calculate fine
    SET @fine_amount = @overdue_days * @fine_rate;

    -- Update Loan with return_date and fine
    UPDATE Loan
    SET 
        return_date = @return_date,
        loan_fine_amount = @fine_amount
    WHERE Loan_ID = @Loan_ID;
END;
GO

-- SP3 -- Invoke Trigger 3
CREATE PROCEDURE SP_Reserve_Book
    @User_ID VARCHAR(10),
    @BookCopy_ID VARCHAR(10),
    @reservation_created_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @loan_created_date DATE;
    DECLARE @expiry_date DATE;

    -- Check if book copy is currently unavailable (i.e., loaned out)
    IF (
        SELECT availability_status
        FROM BookCopy
        WHERE BookCopy_ID = @BookCopy_ID
    ) != 'Loaned'
    BEGIN
        RAISERROR('Book copy is not currently loaned out and cannot be reserved.', 16, 1);
        RETURN;
    END

    -- Get loan_created_date for the active loan of this book copy
    SELECT TOP 1 @loan_created_date = loan_created_date
    FROM Loan
    WHERE BookCopy_ID = @BookCopy_ID AND return_date IS NULL;

    -- If loan not found (shouldn't happen, but for safety)
    IF @loan_created_date IS NULL
    BEGIN
        RAISERROR('No active loan found for this book copy.', 16, 1);
        RETURN;
    END

    -- Insert reservation record
    INSERT INTO Reservation (BookCopy_ID, User_ID, reservation_created_date, expiry_date)
    VALUES (@BookCopy_ID, @User_ID, @reservation_created_date, @expiry_date);

    -- Update book copy status to reserved
    UPDATE BookCopy
    SET availability_status = 'reserved'
    WHERE BookCopy_ID = @BookCopy_ID;
END;

 /*
  _____       _                           
 |_   _|_ __ (_)  __ _   __ _   ___  _ __ 
   | | | '__|| | / _` | / _` | / _ \| '__|
   | | | |   | || (_| || (_| ||  __/| |   
   |_| |_|   |_| \__, | \__, | \___||_|   
                 |___/  |___/             
 */

-- Invoke after SP1
GO
CREATE TRIGGER TRG_Loan_INS_SetCopyToLoaned
ON Loan
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update BookCopy availability to 'Loaned' after loan is inserted
    UPDATE bc
    SET bc.availability_status = 'loaned'
    FROM BookCopy bc
    JOIN inserted i ON bc.bookcopy_id = i.bookcopy_id;
END;
GO

-- Invoke after SP2
GO
CREATE TRIGGER TRG_Loan_UPD_SetCopyToAvailable
ON Loan
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Update BookCopy to 'Available' when return_date is set
    UPDATE bc
    SET bc.availability_status = 'available'
    FROM BookCopy bc
    JOIN inserted i ON bc.bookcopy_id = i.bookcopy_id
    JOIN deleted d ON i.loan_id = d.loan_id
    WHERE i.return_date IS NOT NULL AND d.return_date IS NULL;
END;
GO

-- Invoke after SP3
GO
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
GO


