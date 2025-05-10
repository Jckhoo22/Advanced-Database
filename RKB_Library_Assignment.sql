USE RKB_Library;

-------------------------------------------------------------------------------------------------------------
--    ____          _          _                            ____                    _    _                 --
--   |  _ \   __ _ | |_  __ _ | |__    __ _  ___   ___     / ___| _ __  ___   __ _ | |_ (_)  ___   _ __    --
--   | | | | / _` || __|/ _` || '_ \  / _` |/ __| / _ \   | |    | '__|/ _ \ / _` || __|| | / _ \ | '_ \   --
--   | |_| || (_| || |_| (_| || |_) || (_| |\__ \|  __/   | |___ | |  |  __/| (_| || |_ | || (_) || | | |  --
--   |____/  \__,_| \__|\__,_||_.__/  \__,_||___/ \___|    \____||_|   \___| \__,_| \__||_| \___/ |_| |_|  --
--                                                                                                         --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/

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
/*=========================================================================================================*/

CREATE TABLE LoginCredentials (
    User_ID VARCHAR(10) PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(100),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);
/*=========================================================================================================*/

CREATE TABLE Student (
    User_ID VARCHAR(10) PRIMARY KEY,
    program VARCHAR(100),
    faculty VARCHAR(100),
    enrollment_date DATE,
    CGPA DECIMAL(3,2) CHECK (CGPA >= 0 AND CGPA <= 4), -- Check Between 0 and 4 and conditional 3 digits max & 2 decimals max
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);
/*=========================================================================================================*/

CREATE TABLE Staff (
    User_ID VARCHAR(10) PRIMARY KEY,
    start_working_date DATE,
    salary DECIMAL(10,2) CHECK (salary >= 0), 
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);
/*=========================================================================================================*/

CREATE TABLE Librarian (
    User_ID VARCHAR(10) PRIMARY KEY,
    shift_starting_time TIME,
    shift_ending_time TIME,
    shift_branch VARCHAR(100),
    shift_task TEXT, -- description based use Text just in case too long
    FOREIGN KEY (User_ID) REFERENCES Staff(User_ID)
);
/*=========================================================================================================*/

CREATE TABLE Lecturer (
    User_ID VARCHAR(10) PRIMARY KEY,
    department VARCHAR(100),
    specialization VARCHAR(100),
    office_hour VARCHAR(50),
    office_location VARCHAR(100),
    FOREIGN KEY (User_ID) REFERENCES Staff(User_ID)
);
/*=========================================================================================================*/

CREATE TABLE AgeSuggestion (
    AgeSuggestion_ID VARCHAR(10) PRIMARY KEY,
    rating_label VARCHAR(50),
    min_age INT,
    description TEXT -- description based use Text just in case too long
);
/*=========================================================================================================*/

CREATE TABLE Genre (
    Genre_ID VARCHAR(10) PRIMARY KEY,
    genre_name VARCHAR(100),
    genre_description TEXT -- description based use Text just in case too long
);
/*=========================================================================================================*/

CREATE TABLE Tag (
    Tag_ID VARCHAR(10) PRIMARY KEY,
    tag_name VARCHAR(50),
    fine_rate DECIMAL(5,2),
    loan_period INT,
    loanable_status VARCHAR(20) CHECK (loanable_status IN ('loanable', 'non loanable'))
);
/*=========================================================================================================*/

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
/*=========================================================================================================*/

CREATE TABLE BookDescription (
    ISBN VARCHAR(20) PRIMARY KEY,
    description TEXT,
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN)
);
/*=========================================================================================================*/

CREATE TABLE Author (
    Author_ID VARCHAR(10) PRIMARY KEY,
    author_name VARCHAR(100)
);
/*=========================================================================================================*/

CREATE TABLE BookAuthor (
    ISBN VARCHAR(20),
    Author_ID VARCHAR(10),
    PRIMARY KEY (ISBN, Author_ID),
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN),
    FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID)
);
/*=========================================================================================================*/

CREATE TABLE BookCopy (
    BookCopy_ID VARCHAR(10) PRIMARY KEY,
    ISBN VARCHAR(20),
    availability_status VARCHAR(20) CHECK (availability_status IN ('Available', 'Loaned', 'Reserved')), -- Store Reservation & Loan Status
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN)
);
/*=========================================================================================================*/

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
/*=========================================================================================================*/

CREATE TABLE Reservation (
    Reservation_ID VARCHAR(10) PRIMARY KEY,
    BookCopy_ID VARCHAR(10),
    User_ID VARCHAR(10),
    reservation_created_date DATE,
    expiry_date DATE,
    FOREIGN KEY (BookCopy_ID) REFERENCES BookCopy(BookCopy_ID),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);
/*=========================================================================================================*/

CREATE TABLE Room (
    Room_ID VARCHAR(10) PRIMARY KEY,
    room_name VARCHAR(100)
);
/*=========================================================================================================*/

CREATE TABLE RoomDetails (
    Room_ID VARCHAR(10) PRIMARY KEY,
    room_capacity INT,
    room_floor INT,
    maintenance_status VARCHAR(20) CHECK (maintenance_status IN ('available', 'under maintenance', 'closed')),
    FOREIGN KEY (Room_ID) REFERENCES Room(Room_ID)
);
/*=========================================================================================================*/

CREATE TABLE RoomBooking (
    RoomBooking_ID VARCHAR(10) PRIMARY KEY,
    Room_ID VARCHAR(10),
    User_ID VARCHAR(10),
    room_booking_created_time DATETIME,
    end_time DATETIME,
    FOREIGN KEY (Room_ID) REFERENCES Room(Room_ID),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);
/*=========================================================================================================*/



-------------------------------------------------------------------------------------------------------------
--                       ___                          _     ____          _                                --
--                      |_ _| _ __   ___   ___  _ __ | |_  |  _ \   __ _ | |_  __ _                        --
--                       | | | '_ \ / __| / _ \| '__|| __| | | | | / _` || __|/ _` |                       --
--                       | | | | | |\__ \|  __/| |   | |_  | |_| || (_| || |_| (_| |                       --
--                      |___||_| |_||___/ \___||_|    \__| |____/  \__,_| \__|\__,_|                       --
--                                                                                                         --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/

--Insert Data into Genre Table
INSERT INTO Genre (Genre_ID, genre_name, genre_description)
VALUES
('G001', 'Fiction', 'Literary works invented by the imagination, such as novels or short stories'),
('G002', 'Non-Fiction', 'Literary works based on facts and real events'),
('G003', 'Reference', 'Books like dictionaries, encyclopedias, not usually for loan'),
('G004', 'Student Project', 'Academic projects or theses by students'),
('G005', 'Science', 'Books related to scientific studies and discoveries'),
('G006', 'Technology', 'Books covering technical and IT subjects'),
('G007', 'History', 'Books discussing historical events and figures'),
('G008', 'Biography', 'Books telling the life stories of individuals'),
('G009', 'Children', 'Books intended for young readers');
/*=========================================================================================================*/

--Insert Data into Tag Table
INSERT INTO Tag (Tag_ID, tag_name, fine_rate, loan_period, loanable_status)
VALUES
('T001', 'Yellow', 2.00, 14, 'loanable'),
('T002', 'Red', 3.00, 7, 'non loanable'),
('T003', 'Green', 1.00, 21, 'loanable');
/*=========================================================================================================*/

--Insert Data into AgeSuggestion Table
INSERT INTO AgeSuggestion (AgeSuggestion_ID, rating_label, min_age, description)
VALUES
('AS001', 'All Ages', 0, 'Suitable for all readers, including children'),
('AS002', 'Children', 7, 'Content suitable for young readers aged 7 and above'),
('AS003', 'Teen', 13, 'Recommended for teenagers aged 13 and older'),
('AS004', 'Young Adult', 16, 'Content ideal for young adults aged 16+'),
('AS005', 'Adult', 18, 'Content intended for mature readers aged 18 and above'),
('AS006', 'Academic Only', 21, 'Recommended for academic and research purposes, typically university students and staff');
/*=========================================================================================================*/

--Insert Data into Room Table
INSERT INTO Room (Room_ID, room_name)
VALUES
('R001', 'Presentation Room 1'),
('R002', 'Presentation Room 2'),
('R003', 'Presentation Room 3'),
('R004', 'Presentation Room 4'),
('R005', 'Presentation Room 5');
/*=========================================================================================================*/

--Insert Data into RoomDetails Table
INSERT INTO RoomDetails (Room_ID, room_capacity, room_floor, maintenance_status)
VALUES
('R001', 30, 4, 'available'),
('R002', 25, 4, 'under maintenance'),
('R003', 40, 4, 'available'),
('R004', 20, 5, 'closed'),
('R005', 35, 5, 'available');
/*=========================================================================================================*/

--Insert 20 Student into User Table
DECLARE @counter INT = 1;
DECLARE @StuID VARCHAR(10);
DECLARE @FName VARCHAR(50);
DECLARE @LName VARCHAR(50);
DECLARE @DOB DATE;
DECLARE @Email VARCHAR(100);
DECLARE @Gender VARCHAR(10);
DECLARE @Address VARCHAR(255);
DECLARE @Contact VARCHAR(20);
DECLARE @AccountStatus VARCHAR(20);
DECLARE @Program VARCHAR(100);
DECLARE @Faculty VARCHAR(100);
DECLARE @EnrollmentDate DATE;
DECLARE @CGPA DECIMAL(3,2);

WHILE @counter <= 20
BEGIN
    SET @StuID = 'U' + RIGHT('0000' + CAST(@counter AS VARCHAR), 4);
    SET @FName = 'Student_' + CAST(@counter AS VARCHAR);
    SET @LName = 'APU_' + CAST(@counter AS VARCHAR);
    SET @DOB = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 8000), GETDATE());
    SET @Email = LOWER(@FName + @LName + '@mail.com');
    SET @Gender = CASE WHEN @counter % 3 = 0 THEN 'male' WHEN @counter % 3 = 1 THEN 'female' ELSE 'other' END;
    SET @Address = 'Address ' + CAST(@counter AS VARCHAR);
    SET @Contact = '010' + CAST(1000000 + @counter AS VARCHAR);
    SET @AccountStatus = CASE WHEN @counter % 50 = 0 THEN 'suspended' ELSE 'active' END;

    INSERT INTO [User] (User_ID, first_name, last_name, date_of_birth, contact_number, email, gender, address, account_status)
    VALUES (@StuID, @FName, @LName, @DOB, @Contact, @Email, @Gender, @Address, @AccountStatus);

	-- Insert into LoginCredentials // added
	INSERT INTO LoginCredentials (User_ID, username, password)
    VALUES (@StuID, LOWER(@FName + CAST(@counter AS VARCHAR)), 'P@ssStudent!');

    -- Student Table
    SET @Program = 'Program ' + CAST((@counter % 5 + 1) AS VARCHAR);
    SET @Faculty = 'Faculty ' + CAST((@counter % 4 + 1) AS VARCHAR);
    SET @EnrollmentDate = DATEADD(YEAR, -1 * (ABS(CHECKSUM(NEWID())) % 5), GETDATE());
    SET @CGPA = ROUND(RAND() * 4.0, 2);

    INSERT INTO Student (User_ID, program, faculty, enrollment_date, CGPA)
    VALUES (@StuID, @Program, @Faculty, @EnrollmentDate, @CGPA);

    SET @counter = @counter + 1;
END;
/*=========================================================================================================*/

--Insert 20 Lecturer into User Table (Staff Table)
DECLARE @counter1 INT = 21;
DECLARE @LecID VARCHAR(10);
DECLARE @LecFName VARCHAR(50);
DECLARE @LecLName VARCHAR(50);
DECLARE @LecDOB DATE;
DECLARE @LecEmail VARCHAR(100);
DECLARE @LecGender VARCHAR(10);
DECLARE @LecAddress VARCHAR(255);
DECLARE @LecContact VARCHAR(20);
DECLARE @LecAccountStatus VARCHAR(20);

DECLARE @LecStartDate DATE;
DECLARE @LecSalary DECIMAL(10,2);

DECLARE @Department VARCHAR(100);
DECLARE @Specialization VARCHAR(100);
DECLARE @OfficeHour VARCHAR(50);
DECLARE @OfficeLocation VARCHAR(100);

WHILE @counter1 <= 40
BEGIN
    SET @LecID = 'U' + RIGHT('0000' + CAST(@counter1 AS VARCHAR), 4);
    SET @LecFName = 'Lecturer_' + CAST(@counter1 AS VARCHAR);
    SET @LecLName = 'APU_' + CAST(@counter1 AS VARCHAR);
    SET @LecDOB = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 12000), GETDATE());
    SET @LecEmail = LOWER(@LecFName + @LecLName + '@university.edu');
    SET @LecGender = CASE WHEN @counter1 % 2 = 0 THEN 'male' ELSE 'female' END;
    SET @LecAddress = 'Lecturer Address ' + CAST(@counter1 AS VARCHAR);
    SET @LecContact = '011' + CAST(2000000 + @counter1 AS VARCHAR);
    SET @LecAccountStatus = 'active';

    INSERT INTO [User] (User_ID, first_name, last_name, date_of_birth, contact_number, email, gender, address, account_status)
    VALUES (@LecID, @LecFName, @LecLName, @LecDOB, @LecContact, @LecEmail, @LecGender, @LecAddress, @LecAccountStatus);

	INSERT INTO LoginCredentials (User_ID, username, password)
    VALUES (@LecID, LOWER(@LecFName + CAST(@counter1 AS VARCHAR)), 'P@ssLecturer!');

    -- Staff
    SET @LecStartDate = DATEADD(YEAR, -1 * (ABS(CHECKSUM(NEWID())) % 20), GETDATE());
    SET @LecSalary = ROUND(4000 + (RAND() * 3000), 2);

    INSERT INTO Staff (User_ID, start_working_date, salary)
    VALUES (@LecID, @LecStartDate, @LecSalary);


    -- Lecturer
    SET @Department = 'Department ' + CAST((@counter1 % 5 + 1) AS VARCHAR);
    SET @Specialization = 'Specialization ' + CAST((@counter1 % 10 + 1) AS VARCHAR);
    SET @OfficeHour = 'Mon-Fri 9AM-5PM';
    SET @OfficeLocation = 'Block ' + CHAR(65 + (@counter1 % 5)) + '-' + CAST((@counter1 % 10 + 1) AS VARCHAR);

    INSERT INTO Lecturer (User_ID, department, specialization, office_hour, office_location)
    VALUES (@LecID, @Department, @Specialization, @OfficeHour, @OfficeLocation);

    SET @counter1 = @counter1 + 1;
END;
/*=========================================================================================================*/

--Insert 20 Librarian into User Table (Staff Table)
DECLARE @counter2 INT = 41;
DECLARE @LibID VARCHAR(10);
DECLARE @LibFName VARCHAR(50);
DECLARE @LibLName VARCHAR(50);
DECLARE @LibDOB DATE;
DECLARE @LibEmail VARCHAR(100);
DECLARE @LibGender VARCHAR(10);
DECLARE @LibAddress VARCHAR(255);
DECLARE @LibContact VARCHAR(20);
DECLARE @LibAccountStatus VARCHAR(20);

DECLARE @LibStartDate DATE;
DECLARE @LibSalary DECIMAL(10,2);

DECLARE @ShiftStart TIME;
DECLARE @ShiftEnd TIME;
DECLARE @Branch VARCHAR(100);
DECLARE @Task NVARCHAR(MAX);

WHILE @counter2 <= 60
BEGIN
    SET @LibID = 'U' + RIGHT('0000' + CAST(@counter2 AS VARCHAR), 4);
    SET @LibFName = 'Librarian_' + CAST(@counter2 AS VARCHAR);
    SET @LibLName = 'APU_' + CAST(@counter2 AS VARCHAR);
    SET @LibDOB = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 12000), GETDATE());
    SET @LibEmail = LOWER(@LibFName + @LibLName + '@university.edu');
    SET @LibGender = CASE WHEN @counter2 % 2 = 0 THEN 'male' ELSE 'female' END;
    SET @LibAddress = 'Librarian Address ' + CAST(@counter2 AS VARCHAR);
    SET @LibContact = '012' + CAST(3000000 + @counter2 AS VARCHAR);
    SET @LibAccountStatus = 'active';

    INSERT INTO [User] (User_ID, first_name, last_name, date_of_birth, contact_number, email, gender, address, account_status)
    VALUES (@LibID, @LibFName, @LibLName, @LibDOB, @LibContact, @LibEmail, @LibGender, @LibAddress, @LibAccountStatus);

	INSERT INTO LoginCredentials (User_ID, username, password)
    VALUES (@LibID, LOWER(@LibFName + CAST(@counter2 AS VARCHAR)), 'P@ssLibrarian!');

    -- Staff
    SET @LibStartDate = DATEADD(YEAR, -1 * (ABS(CHECKSUM(NEWID())) % 10), GETDATE());
    SET @LibSalary = ROUND(2500 + (RAND() * 2000), 2);

    INSERT INTO Staff (User_ID, start_working_date, salary)
    VALUES (@LibID, @LibStartDate, @LibSalary);

    -- Librarian
    SET @ShiftStart = '08:00:00';
    SET @ShiftEnd = '17:00:00';
    SET @Branch = 'Library Block ' + CHAR(65 + (@counter2 % 5));
    SET @Task = 'Assist users, manage book circulation and maintain library records.';

    INSERT INTO Librarian (User_ID, shift_starting_time, shift_ending_time, shift_branch, shift_task)
    VALUES (@LibID, @ShiftStart, @ShiftEnd, @Branch, @Task);

    SET @counter2 = @counter2 + 1;
END;
/*=========================================================================================================*/

--Insert 5 Student as Librarians
DECLARE @studentCounter INT = 1;
DECLARE @studentUserID VARCHAR(10);

WHILE @studentCounter <= 5
BEGIN
    SET @studentUserID = 'U' + RIGHT('0000' + CAST(@studentCounter AS VARCHAR), 4);

    -- Assume these student users already exist
    -- We just need to make them staff and librarians

    -- Insert as staff
    INSERT INTO Staff (User_ID, start_working_date, salary)
    VALUES (@studentUserID, DATEADD(YEAR, -1 * (ABS(CHECKSUM(NEWID())) % 5), GETDATE()), ROUND(1800 + (RAND() * 1200), 2));

    -- Insert as librarian
    INSERT INTO Librarian (User_ID, shift_starting_time, shift_ending_time, shift_branch, shift_task)
    VALUES (@studentUserID, '09:00:00', '13:00:00', 'Student Branch A', 'Support library services part-time');

    SET @studentCounter = @studentCounter + 1;
END;
/*=========================================================================================================*/

--Insert Data into Author Table
DECLARE @counter3 INT = 1;
DECLARE @AuthorID VARCHAR(10);
DECLARE @AuthorName VARCHAR(100);

WHILE @counter3 <= 5
BEGIN
    SET @AuthorID = 'A' + RIGHT('0000' + CAST(@counter3 AS VARCHAR), 4);
    SET @AuthorName = 'Author_' + CAST(@counter3 AS VARCHAR);

    INSERT INTO Author (Author_ID, author_name)
    VALUES (@AuthorID, @AuthorName);

    SET @counter3 = @counter3 + 1;
END;
/*=========================================================================================================*/

--Insert Data into Book Table
DECLARE @counter4 INT = 1;
DECLARE @ISBN VARCHAR(20);
DECLARE @Title VARCHAR(255);
DECLARE @GenreID VARCHAR(10);
DECLARE @AgeID VARCHAR(10);
DECLARE @TagID VARCHAR(10);

WHILE @counter4 <= 20
BEGIN
    SET @ISBN = 'ISBN' + RIGHT('000000000000' + CAST(@counter4 AS VARCHAR), 12);
    SET @Title = 'Book Title ' + CAST(@counter4 AS VARCHAR);

    -- Rotate GenreID (G001 to G009)
    SET @GenreID = 'G00' + CAST(((@counter4 - 1) % 9) + 1 AS VARCHAR);

    -- Rotate AgeSuggestion_ID (AS001 to AS006)
    SET @AgeID = 'AS00' + CAST(((@counter4 - 1) % 6) + 1 AS VARCHAR);

    -- Rotate Tag_ID (T001 to T003)
    SET @TagID = 'T00' + CAST(((@counter4 - 1) % 3) + 1 AS VARCHAR);

    INSERT INTO Book (ISBN, book_title, Genre_ID, AgeSuggestion_ID, Tag_ID)
    VALUES (@ISBN, @Title, @GenreID, @AgeID, @TagID);

    SET @counter4 = @counter4 + 1;
END;
/*=========================================================================================================*/

--Insert Data into BookDescription Table
DECLARE @counter5 INT = 1;
DECLARE @ISBN1 VARCHAR(20);
DECLARE @Desc NVARCHAR(MAX);  -- Use NVARCHAR(MAX) since TEXT can't be declared

WHILE @counter5 <= 20
BEGIN
    SET @ISBN1 = 'ISBN' + RIGHT('000000000000' + CAST(@counter5 AS VARCHAR), 12);
    SET @Desc = 'This is the description for Book Title ' + CAST(@counter5 AS VARCHAR);

    INSERT INTO BookDescription (ISBN, description)
    VALUES (@ISBN1, @Desc);

    SET @counter5 = @counter5 + 1;
END;
/*=========================================================================================================*/

--Insert Data into BookCopy Table
DECLARE @counter6 INT = 1;
DECLARE @BookCopyID VARCHAR(10);
DECLARE @ISBN2 VARCHAR(20);
DECLARE @Status VARCHAR(20);

WHILE @counter6 <= 40
BEGIN
    SET @BookCopyID = 'BC' + RIGHT('00000' + CAST(@counter6 AS VARCHAR), 5);

    -- Cycle through 20 ISBNs
    SET @ISBN2 = 'ISBN' + RIGHT('000000000000' + CAST(((@counter6 - 1) % 20) + 1 AS VARCHAR), 12);

    -- Rotate availability status
    SET @Status = CASE (@counter6 % 3)
                    WHEN 1 THEN 'available'
                    WHEN 2 THEN 'loaned'
                    ELSE 'reserved'
                  END;

    INSERT INTO BookCopy (BookCopy_ID, ISBN, availability_status)
    VALUES (@BookCopyID, @ISBN2, @Status);

    SET @counter6 = @counter6 + 1;
END;
/*=========================================================================================================*/

--Insert Data into BookAuthor Table
DECLARE @counter7 INT = 1;
DECLARE @ISBN3 VARCHAR(20);
DECLARE @AuthorID1 VARCHAR(10);

WHILE @counter7 <= 20
BEGIN
    SET @ISBN3 = 'ISBN' + RIGHT('000000000000' + CAST(@counter7 AS VARCHAR), 12);
    SET @AuthorID1 = 'A' + RIGHT('0000' + CAST((@counter7 % 5) + 1 AS VARCHAR), 4);

    INSERT INTO BookAuthor (ISBN, Author_ID)
    VALUES (@ISBN3, @AuthorID1);

    SET @counter7 = @counter7 + 1;
END;
--Second pass: add 10 more (random books get 2nd/3rd authors)
SET @counter7 = 1;
WHILE @counter7 <= 10
BEGIN
    SET @ISBN3 = 'ISBN' + RIGHT('000000000000' + CAST(((@counter7 * 4) % 20 + 1) AS VARCHAR), 12);  -- spread across books
    SET @AuthorID1 = 'A' + RIGHT('0000' + CAST(((1234 + @counter7) % 5 + 1) AS VARCHAR), 4);

    -- Ensure no duplicate (optional safety)
    IF NOT EXISTS (
        SELECT 1 FROM BookAuthor WHERE ISBN = @ISBN3 AND Author_ID = @AuthorID1
    )
    BEGIN
        INSERT INTO BookAuthor (ISBN, Author_ID)
        VALUES (@ISBN3, @AuthorID1);
    END

    SET @counter7 = @counter7 + 1;
END;
/*=========================================================================================================*/

-- Insert 30 Loan Records (mix of students and lecturers)
DECLARE @loanCounter INT = 1;
DECLARE @LoanID VARCHAR(10);
DECLARE @BookCopyID1 VARCHAR(10);
DECLARE @UserID VARCHAR(10);
DECLARE @FineAmount DECIMAL(6,2);
DECLARE @LoanDate DATE;
DECLARE @ReturnDate DATE;

WHILE @loanCounter <= 30
BEGIN
    SET @LoanID = 'L' + RIGHT('0000' + CAST(@loanCounter AS VARCHAR), 4);
    SET @BookCopyID1 = 'BC' + RIGHT('00000' + CAST(((@loanCounter - 1) % 40 + 1) AS VARCHAR), 5);

    -- Use student IDs for first 20, lecturers for next 10
    IF @loanCounter <= 20
        SET @UserID = 'U' + RIGHT('0000' + CAST(@loanCounter AS VARCHAR), 4);  -- Students U0001–U0020
    ELSE
        SET @UserID = 'U' + RIGHT('0000' + CAST((@loanCounter + 1) AS VARCHAR), 4);  -- Lecturers U0022–U0031

    -- Random loan date in the last 60 days
    SET @LoanDate = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 60), GETDATE());

    -- Random return date (some NULL to simulate active loans)
    IF @loanCounter % 5 = 0
        SET @ReturnDate = NULL;  -- Not yet returned
    ELSE
        SET @ReturnDate = DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 15), @LoanDate);

    -- Random fine (some will be 0, some small overdue fines)
    SET @FineAmount = CASE WHEN @ReturnDate IS NULL THEN 0 ELSE ROUND(RAND() * 5.00, 2) END;

    INSERT INTO Loan (Loan_ID, BookCopy_ID, User_ID, loan_fine_amount, loan_created_date, return_date)
    VALUES (@LoanID, @BookCopyID1, @UserID, @FineAmount, @LoanDate, @ReturnDate);

    SET @loanCounter = @loanCounter + 1;
END;
/*=========================================================================================================*/

-- Insert 15 Reservations (mix of students and lecturers)
DECLARE @resCounter INT = 1;
DECLARE @ResID VARCHAR(10);
DECLARE @ResBookCopyID VARCHAR(10);
DECLARE @ResUserID VARCHAR(10);
DECLARE @ResDate DATE;
DECLARE @ExpiryDate DATE;

WHILE @resCounter <= 15
BEGIN
    SET @ResID = 'RS' + RIGHT('0000' + CAST(@resCounter AS VARCHAR), 4);
    SET @ResBookCopyID = 'BC' + RIGHT('00000' + CAST((@resCounter % 30 + 1) AS VARCHAR), 5); -- Spread across first 30 book copies

    -- Use students for first 10, lecturers for the rest
    IF @resCounter <= 10
        SET @ResUserID = 'U' + RIGHT('0000' + CAST(@resCounter AS VARCHAR), 4);  -- Students U0001–U0010
    ELSE
        SET @ResUserID = 'U' + RIGHT('0000' + CAST((@resCounter + 10) AS VARCHAR), 4); -- Lecturers U0021–U0025

    -- Reservation date within the past 10 days
    SET @ResDate = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 10), GETDATE());
    SET @ExpiryDate = DATEADD(DAY, 3, @ResDate); -- Always 3 days ahead

    INSERT INTO Reservation (Reservation_ID, BookCopy_ID, User_ID, reservation_created_date, expiry_date)
    VALUES (@ResID, @ResBookCopyID, @ResUserID, @ResDate, @ExpiryDate);

    SET @resCounter = @resCounter + 1;
END;
/*=========================================================================================================*/

-- Insert 10 RoomBooking records (spread across 5 rooms, students and lecturers)
DECLARE @rbCounter INT = 1;
DECLARE @RBID VARCHAR(10);
DECLARE @RoomID VARCHAR(10);
DECLARE @RBUserID VARCHAR(10);
DECLARE @RBStart DATETIME;
DECLARE @RBEnd DATETIME;

WHILE @rbCounter <= 10
BEGIN
    SET @RBID = 'RB' + RIGHT('0000' + CAST(@rbCounter AS VARCHAR), 4);
    SET @RoomID = 'R00' + CAST(((@rbCounter - 1) % 5 + 1) AS VARCHAR); -- R001 to R005 loop

    -- Use student U0001–U0005, lecturer U0021–U0025
    IF @rbCounter <= 5
        SET @RBUserID = 'U' + RIGHT('0000' + CAST(@rbCounter AS VARCHAR), 4); -- Student
    ELSE
        SET @RBUserID = 'U' + RIGHT('0000' + CAST((@rbCounter + 16) AS VARCHAR), 4); -- Lecturer

    -- Random start datetime within the last 5 days, between 8AM–3PM
    SET @RBStart = DATEADD(HOUR, 8 + (ABS(CHECKSUM(NEWID())) % 8), DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 5), GETDATE()));

    -- Add 1 to 3 hours duration (max allowed)
    SET @RBEnd = DATEADD(HOUR, (ABS(CHECKSUM(NEWID())) % 3) + 1, @RBStart);

    INSERT INTO RoomBooking (RoomBooking_ID, Room_ID, User_ID, room_booking_created_time, end_time)
    VALUES (@RBID, @RoomID, @RBUserID, @RBStart, @RBEnd);

    SET @rbCounter = @rbCounter + 1;
END;
/*=========================================================================================================*/



-------------------------------------------------------------------------------------------------------------
--                             _   _                    ____         _                                     --
--                            | | | | ___   ___  _ __  |  _ \  ___  | |  ___                               --
--                            | | | |/ __| / _ \| '__| | |_) |/ _ \ | | / _ \                              --
--                            | |_| |\__ \|  __/| |    |  _ <| (_) || ||  __/                              --
--                             \___/ |___/ \___||_|    |_| \_\\___/ |_| \___|                              --
--                                                                                                         --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/

-- User Access Roles (Librarian) (Ronald)
CREATE LOGIN Lib WITH PASSWORD = '1'; -- Create Login to Sql Server

USE RKB_Library

CREATE USER librarian FOR LOGIN Lib; -- Create User within that "Lib" Server
 
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


/*=========================================================================================================*/
-- User Access (Student) (JC)
CREATE LOGIN Stud WITH PASSWORD = '1'; -- Create Login to Sql Server

USE RKB_Library

CREATE USER student FOR LOGIN Stud; -- Create User within that "Stud" Server

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

-- GRANT STORED PROCEDURE
GRANT EXECUTE ON SP_Reserve_Book TO student;
/*=========================================================================================================*/
-- User Access (Lecturer) (Bryan)
CREATE LOGIN Lect WITH PASSWORD = '1';

USE RKB_Library;

CREATE USER lecturer FOR LOGIN Lect; -- DB user name = 'lecturer'

-- Access 1: Lecturer can browse books, view genres, authors, and descriptions
GRANT SELECT ON Book TO lecturer;
GRANT SELECT ON BookDescription TO lecturer;
GRANT SELECT ON BookAuthor TO lecturer;
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

/*=========================================================================================================*/



-------------------------------------------------------------------------------------------------------------
--                        _      _  _                        _                                             --
--                       | |    (_)| |__   _ __  __ _  _ __ (_)  __ _  _ __                                --
--                       | |    | || '_ \ | '__|/ _` || '__|| | / _` || '_ \                               --
--                       | |___ | || |_) || |  | (_| || |   | || (_| || | | |                              --
--                       |_____||_||_.__/ |_|   \__,_||_|   |_| \__,_||_| |_|                              --
--                                                                                                         --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/

-- Ronald Oh Fu Ming
USE RKB_Library;
-- For handling loan
Select * From Loan;

INSERT INTO Loan (Loan_ID, BookCopy_ID, User_ID, loan_fine_amount, loan_created_date, return_date) VALUES
('L0046', 'BC001', 'U020', 0.00, '2025-05-01', NULL);

UPDATE Loan
SET return_date = '2025-05-03', loan_fine_amount = 50
WHERE User_ID = 'U020' AND BookCopy_ID = 'BC001';

-- For handling and managing reservations
SELECT * FROM Reservation;

UPDATE Reservation
SET BookCopy_ID = 'BC002', User_ID = 'U003', reservation_created_date = '2025-05-10' 
WHERE Reservation_ID = 'R001';

-- For updating real-time book status on book copy
SELECT * FROM BookCopy;

UPDATE BookCopy
SET availability_status = 'available' 
WHERE BookCopy_ID = 'BC001';

-- For updating and viewing the book tag
SELECT * FROM Tag;

UPDATE Tag
SET loanable_status = 'non loanable', loan_period = 10, fine_rate = 2.0 
WHERE Tag_ID = 'T001';

-- For displaying all book details
Select * From Book;

Select * From BookDescription;

Select * From BookAuthor;

Select * From Author;

Select * From Genre;

-- For displaying and showing the room details and the booking information
Select * From Room

Select * From RoomDetails

Select * From RoomBooking

UPDATE RoomBooking
SET room_booking_created_time = '2025-05-01 09:00:00.000', end_time = '2025-05-01 11:00:00.000'
WHERE RoomBooking_ID = 'RB001';

Delete From Room where Room_ID = 'RM01';

Update Room 
SET room_name = 'Science room'
where Room_ID = 'RM01';

INSERT INTO Room (Room_ID, room_name) VALUES
('RM072', 'Science room');
/*=========================================================================================================*/



-------------------------------------------------------------------------------------------------------------
--                              _                 _                                                        --
--                             | |     ___   ___ | |_  _   _  _ __  ___  _ __                              --
--                             | |    / _ \ / __|| __|| | | || '__|/ _ \| '__|                             --
--                             | |___|  __/| (__ | |_ | |_| || |  |  __/| |                                --
--                             |_____|\___| \___| \__| \__,_||_|   \___||_|                                --
--                                                                                                         --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/
-- Bryan Tee Ming Jun
USE RKB_Library;
--------------------------------------------------------------------------
--                              Can Be Access                           --
--------------------------------------------------------------------------
/*======================================================================*/

-- Lecturer can browse books, view genres, authors, and descriptions
SELECT * FROM Book;
SELECT * FROM BookDescription;
SELECT * FROM BookAuthor;
SELECT * FROM Author;
SELECT * FROM Genre;

SELECT 
    b.ISBN,
    b.book_title,
    bd.Description,
    g.Genre_Name,
    a.Author_ID,
    a.Author_Name
FROM Book b
JOIN BookDescription bd ON b.ISBN = bd.ISBN
JOIN Genre g ON b.Genre_ID = g.Genre_ID
JOIN BookAuthor ba ON b.ISBN = ba.ISBN
JOIN Author a ON ba.Author_ID = a.Author_ID;
/*======================================================================*/

-- Lecturer can view copy availability (available, loaned, reserved, etc.)
SELECT * FROM BookCopy WHERE availability_status = 'available';
/*======================================================================*/

-- Lecturer  can view Tag details (so they can know which books are reference/non-loanable)
SELECT 
	b.ISBN, 
	t.Tag_ID, 
	t.tag_name, 
	t.loanable_status 
FROM Book b
JOIN Tag t on t.Tag_ID = b.Tag_ID
/*======================================================================*/

-- Lecturer can view and make reservation
SELECT * FROM Reservation;
INSERT INTO Reservation (Reservation_ID, reservation_created_date)
VALUES('RS0016', GETDATE());
/*======================================================================*/

-- Lecturer can view own loan history
SELECT * FROM Loan WHERE User_ID = 'U0022';
/*======================================================================*/

-- Lecturer can view room details, room booking status and make booking for a room
SELECT * FROM Room;
SELECT * FROM RoomDetails;
SELECT * FROM RoomBooking;

SELECT 
	r.Room_ID, 
	rd.maintenance_status, 
	rb.RoomBooking_ID, 
	rb.room_booking_created_time,
	rb.end_time
FROM Room r
JOIN RoomDetails rd ON r.Room_ID = rd.Room_ID
JOIN RoomBooking rb ON r.Room_ID = rb.Room_ID

INSERT INTO RoomBooking (RoomBooking_ID, room_booking_created_time)
VALUES ('RB0011', GETDATE());
/*======================================================================*/

-- Lecturer can view room status and details
SELECT * FROM Room;
SELECT * FROM RoomDetails;
/*======================================================================*/


--------------------------------------------------------------------------
--                            Cannot Be Access                          --
--------------------------------------------------------------------------
/*======================================================================*/

-- Lecturer dont have access to update any table data
UPDATE Book
SET book_title = 'Cant be change'
WHERE ISBN = 'ISBN000000000013';
/*======================================================================*/

-- Lecturer dont have access to view user data
SELECT 
    u.User_ID,
    u.first_name AS User_Name,
    bc.BookCopy_ID,
    bc.ISBN,
    bc.availability_status,
    l.loan_created_date,
    l.return_date
FROM [User] u
JOIN Loan l ON u.User_ID = l.User_ID
JOIN BookCopy bc ON l.BookCopy_ID = bc.BookCopy_ID;
/*======================================================================*/

-- Lecturer cannot add Tag status into Tag table
Insert INTO Tag (Tag_ID, tag_name, fine_rate, loan_period, loanable_status)
VALUES('T004', 'Blue', 0.50, 30, 'loanable')
/*======================================================================*/

-- Lecturer dont have access to delete any table data
DELETE Reservation
WHERE Reservation_ID = 'RS0001';
/*======================================================================*/

-- Lecturer dont have access to delete any data in reservation table
DELETE Reservation WHERE Reservation_ID = 'RS0016';
/*======================================================================*/

--Lecturer cannot alter any table
ALTER TABLE Loan 
ADD PaymentType VARCHAR(20);
/*======================================================================*/

-- Lecturer cannot drop any table
DROP TABLE RoomBooking;
/*=========================================================================================================*/



-------------------------------------------------------------------------------------------------------------
--                               ____   _               _               _                                  --
--                              / ___| | |_  _   _   __| |  ___  _ __  | |_                                --
--                              \___ \ | __|| | | | / _` | / _ \| '_ \ | __|                               --
--                               ___) || |_ | |_| || (_| ||  __/| | | || |_                                --
--                              |____/  \__| \__,_| \__,_| \___||_| |_| \__|                               --
--                                                                                                         --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/

-- Khoo Jie Cheng

/*=========================================================================================================*/



-------------------------------------------------------------------------------------------------------------
--       ____   _                         _     ____                              _                        --
--      / ___| | |_  ___   _ __  ___   __| |   |  _ \  _ __  ___    ___  ___   __| | _   _  _ __  ___      --
--      \___ \ | __|/ _ \ | '__|/ _ \ / _` |   | |_) || '__|/ _ \  / __|/ _ \ / _` || | | || '__|/ _ \     --
--       ___) || |_| (_) || |  |  __/| (_| |   |  __/ | |  | (_) || (__|  __/| (_| || |_| || |  |  __/     --
--      |____/  \__|\___/ |_|   \___| \__,_|   |_|    |_|   \___/  \___|\___| \__,_| \__,_||_|   \___|     --
--                                                                                                         --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/

-- SP1 -- Invoke Trigger 1 (Ronald)
GO
CREATE PROCEDURE SP_Loan_Book -- Take 2 Parameter
    @User_ID VARCHAR(10),
    @BookCopy_ID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

	-- Check the book copy if it is available
	IF EXISTS (
        SELECT 1
        FROM BookCopy
        WHERE BookCopy_ID = @BookCopy_ID AND availability_status != 'available'
    )
    BEGIN
        RAISERROR('This book copy is not available for loan.', 16, 1);
        RETURN;
    END

    -- Check tag loanable status
    IF EXISTS (
		SELECT 1
        FROM Book b
        JOIN Tag t ON b.Tag_ID = t.Tag_ID
        JOIN BookCopy bc ON b.ISBN = bc.ISBN
        WHERE bc.BookCopy_ID = @BookCopy_ID AND t.loanable_status = 'non loanable'
	)
		-- If it's loanable and the user is lecturer can loan 
			AND NOT EXISTS ( 
		SELECT 1
			FROM Lecturer
			WHERE User_ID = @User_ID
	)
	BEGIN
        RAISERROR('Only lecturers can borrow this type of book.', 16, 1);
        RETURN;
    END

	-- Generate unique Loan_ID in format L###
    DECLARE @NewLoanID VARCHAR(10);
    DECLARE @MaxLoanNumber INT;

    -- Get the maximum numeric part of Loan_ID
    SELECT @MaxLoanNumber = ISNULL(MAX(CAST(SUBSTRING(Loan_ID, 2, LEN(Loan_ID) - 1) AS INT)), 0)
    FROM Loan WITH (UPDLOCK, HOLDLOCK)
    WHERE Loan_ID LIKE 'L[0-9]%';

    -- Increment and format as L### (e.g., L001)
    SET @NewLoanID = 'L' + RIGHT('0000' + CAST(@MaxLoanNumber + 1 AS VARCHAR(9)), 4);

    INSERT INTO Loan
        (Loan_ID, BookCopy_ID, User_ID, loan_fine_amount, loan_created_date, return_date)
    VALUES
        (@NewLoanID, @BookCopy_ID, @User_ID, 0, GETDATE(), NULL);

END;
GO
/*=========================================================================================================*/

-- SP2 -- Invoke Trigger 2 (Bryan)
CREATE PROCEDURE SP_Return_Book
    @BookCopy_ID VARCHAR(10),
    @return_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Result INT;
    DECLARE @loan_created_date DATE;
    DECLARE @loan_period INT;
    DECLARE @fine_rate DECIMAL(10,2);
    DECLARE @fine_amount DECIMAL(10,2);

    BEGIN TRANSACTION;

    -- Step 1: Lock BookCopy
    SELECT 1
    FROM BookCopy WITH (UPDLOCK, HOLDLOCK)
    WHERE BookCopy_ID = @BookCopy_ID;

    -- Step 2: Get loan_created_date
    EXEC @Result = SP_Get_Loan_Details @BookCopy_ID, @loan_created_date OUTPUT;
    IF @Result = 1
    BEGIN
        RAISERROR('Failed to get loan details.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Step 3: Get loan_period and fine_rate
    EXEC @Result = SP_Get_Loan_Parameters @BookCopy_ID, @loan_period OUTPUT, @fine_rate OUTPUT;
    IF @Result != 0
    BEGIN
        RAISERROR('Failed to get loan parameters.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Step 4: Calculate fine
    EXEC @Result = SP_Calculate_Fine @loan_created_date, @return_date, @loan_period, @fine_rate, @fine_amount OUTPUT;
    IF @Result != 0
    BEGIN
        RAISERROR('Failed to calculate fine.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Step 5: Update Loan record
    EXEC @Result = SP_Update_Loan_Fine @BookCopy_ID, @return_date, @fine_amount;
    IF @Result = 5
    BEGIN
        RAISERROR('Failed to update loan record.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    COMMIT TRANSACTION;
    RETURN 0; -- Success
END;
GO


CREATE PROCEDURE SP_Get_Loan_Details
    @BookCopy_ID VARCHAR(10),
    @loan_created_date DATE OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    SELECT TOP 1 @loan_created_date = loan_created_date
    FROM Loan WITH (UPDLOCK, HOLDLOCK)
    WHERE BookCopy_ID = @BookCopy_ID AND return_date IS NULL;

    IF @loan_created_date IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        RETURN 1; -- Loan not found
    END

    COMMIT TRANSACTION;
    RETURN 0; -- Success
END;
GO


CREATE PROCEDURE SP_Get_Loan_Parameters
    @BookCopy_ID VARCHAR(10),
    @loan_period INT OUTPUT,
    @fine_rate DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ISBN VARCHAR(20), @Tag_ID VARCHAR(10);

    BEGIN TRANSACTION;

    SELECT @ISBN = ISBN
    FROM BookCopy WITH (UPDLOCK, HOLDLOCK)
    WHERE BookCopy_ID = @BookCopy_ID;

    IF @ISBN IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        RETURN 2; -- BookCopy not found
    END

    SELECT @Tag_ID = Tag_ID
    FROM Book WITH (UPDLOCK, HOLDLOCK)
    WHERE ISBN = @ISBN;

    IF @Tag_ID IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        RETURN 3; -- Book not found
    END

    SELECT @loan_period = loan_period,
           @fine_rate = fine_rate
    FROM Tag WITH (UPDLOCK, HOLDLOCK)
    WHERE Tag_ID = @Tag_ID;

    IF @loan_period IS NULL OR @fine_rate IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        RETURN 4; -- Tag not found or missing values
    END

    COMMIT TRANSACTION;
    RETURN 0; -- Success
END;
GO


CREATE PROCEDURE SP_Calculate_Fine
    @loan_created_date DATE,
    @return_date DATE,
    @loan_period INT,
    @fine_rate DECIMAL(10,2),
    @fine_amount DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @overdue_days INT;

    SET @overdue_days = DATEDIFF(DAY, @loan_created_date, @return_date) - @loan_period;

    IF @overdue_days < 0 SET @overdue_days = 0;

    SET @fine_amount = @overdue_days * @fine_rate;

    RETURN 0; -- Success
END;
GO


CREATE PROCEDURE SP_Update_Loan_Fine
    @BookCopy_ID VARCHAR(10),
    @return_date DATE,
    @fine_amount DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    UPDATE Loan WITH (UPDLOCK, HOLDLOCK)
    SET 
        return_date = @return_date,
        loan_fine_amount = @fine_amount
    WHERE BookCopy_ID = @BookCopy_ID AND return_date IS NULL;

    IF @@ROWCOUNT = 0
    BEGIN
        ROLLBACK TRANSACTION;
        RETURN 5; -- Update failed (loan not found or already returned)
    END

    COMMIT TRANSACTION;
    RETURN 0; -- Success
END;
GO

-- Testing Store Procedure
UPDATE Loan
SET return_date = null
WHERE BookCopy_ID = 'BC00001';

UPDATE BookCopy
SET availability_status = 'loaned'
WHERE BookCopy_ID = 'BC00001';

SELECT * FROM Loan WHERE BookCopy_ID = 'BC00001';
SELECT * FROM BookCopy WHERE BookCopy_ID = 'BC00001';

EXEC SP_Return_Book
@BookCopy_ID = 'BC00001',
@return_date = '2025-05-10';


/*=========================================================================================================*/

-- SP3 -- Invoke Trigger 3 with Concurrency Control (Nested SP)

CREATE PROCEDURE SP_Reserve_Book
    @User_ID VARCHAR(10),
    @BookCopy_ID VARCHAR(10),
    @reservation_created_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Result INT;

    BEGIN TRANSACTION;

    -- Lock the BookCopy row to prevent concurrency issues
    SELECT 1
    FROM BookCopy WITH (UPDLOCK, HOLDLOCK)
    WHERE BookCopy_ID = @BookCopy_ID;

    -- Step 1: Validate book copy
    EXEC @Result = SP_Validate_BookCopy_ForReservation @BookCopy_ID;
    IF @Result = 1
    BEGIN
        RAISERROR('Book copy is not valid for reservation.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Step 2: Check if user already reserved same book
    EXEC @Result = SP_Check_User_Already_Reserved_Book @User_ID, @BookCopy_ID;
    IF @Result = 2
    BEGIN
        RAISERROR('User already has an active reservation for this book.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Step 3: Insert reservation
IF @Result = 0
BEGIN
    EXEC @Result = SP_Insert_Reservation_Record @User_ID, @BookCopy_ID, @reservation_created_date;

    IF @Result != 0
    BEGIN
        RAISERROR('Failed to insert reservation.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
ELSE
BEGIN
    RAISERROR('User already has an active reservation for this book.', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN;
END

    -- Step 4: Update book copy status
    EXEC @Result = SP_Update_BookCopy_Status_Reserved @BookCopy_ID;
    IF @Result = 4
    BEGIN
        RAISERROR('Failed to update book copy status.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    COMMIT TRANSACTION;
END;
GO

CREATE PROCEDURE SP_Validate_BookCopy_ForReservation
    @BookCopy_ID VARCHAR(10)
AS
BEGIN
    DECLARE @status VARCHAR(20);

    SELECT @status = availability_status
    FROM BookCopy
    WHERE BookCopy_ID = @BookCopy_ID;

    IF @status IN ('loaned', 'reserved')
        RETURN 1;

    RETURN 0;   
END;
GO



CREATE PROCEDURE SP_Check_User_Already_Reserved_Book
    @User_ID VARCHAR(10),
    @BookCopy_ID VARCHAR(10)
AS
BEGIN
    DECLARE @ISBN VARCHAR(20);

    -- Get ISBN of the BookCopy
    SELECT @ISBN = ISBN
    FROM BookCopy
    WHERE BookCopy_ID = @BookCopy_ID;

    -- Check if user already has a non-expired reservation for this ISBN
    IF EXISTS (
        SELECT 1
    FROM Reservation r WITH (HOLDLOCK) -- Optional: prevent phantom read
        JOIN BookCopy bc ON r.BookCopy_ID = bc.BookCopy_ID
    WHERE r.User_ID = @User_ID
        AND bc.ISBN = @ISBN
        AND r.expiry_date > GETDATE()
    )
        RETURN 2;
    -- Conflict: Already reserved

    RETURN 0;
-- OK
END;
GO


CREATE PROCEDURE SP_Insert_Reservation_Record
    @User_ID VARCHAR(10),
    @BookCopy_ID VARCHAR(10),
    @reservation_created_date DATE
AS
BEGIN
    DECLARE @LastID VARCHAR(10);
    DECLARE @NewNum INT;
    DECLARE @NewID VARCHAR(10);
    BEGIN TRY
        -- Lock the Reservation table to prevent ID collision
        SELECT TOP 1
            @LastID = Reservation_ID
        FROM Reservation WITH (TABLOCKX, HOLDLOCK)
        WHERE Reservation_ID LIKE 'RS%'
        ORDER BY Reservation_ID DESC;

        -- Generate new number
        IF @LastID IS NULL
            SET @NewNum = 1;
        ELSE
            SET @NewNum = CAST(SUBSTRING(@LastID, 3, LEN(@LastID) - 2) AS INT) + 1;

        -- Generate ID with 4-digit padding if below 10000
        IF @NewNum < 10000
            SET @NewID = 'RS' + RIGHT('0000' + CAST(@NewNum AS VARCHAR), 4);
        ELSE
            SET @NewID = 'RS' + CAST(@NewNum AS VARCHAR);  -- No padding needed 

        -- Optional safety check (10 char max)
        IF LEN(@NewID) > 10
        BEGIN
            RAISERROR('Generated Reservation_ID exceeds allowed length.', 16, 1);
            RETURN 98;
        END

        -- Insert reservation (expiry handled by trigger)
        INSERT INTO Reservation
            (Reservation_ID, BookCopy_ID, User_ID, reservation_created_date, expiry_date)
        VALUES
            (@NewID, @BookCopy_ID, @User_ID, @reservation_created_date, NULL);

        RETURN 0; -- Success
    END TRY
    BEGIN CATCH
        RETURN 3; -- Insert failed
    END CATCH
END;
GO



CREATE PROCEDURE SP_Update_BookCopy_Status_Reserved
    @BookCopy_ID VARCHAR(10)
AS
BEGIN
    BEGIN TRY
        UPDATE BookCopy
        SET availability_status = 'reserved'
        WHERE BookCopy_ID = @BookCopy_ID;

        IF @@ROWCOUNT = 0
            RETURN 4;

        RETURN 0;
    END TRY
    BEGIN CATCH
        RETURN 4;
    END CATCH
END;
GO
/*=========================================================================================================*/



-------------------------------------------------------------------------------------------------------------
--                                  _____       _                                                          --
--                                 |_   _|_ __ (_)  __ _   __ _   ___  _ __                                --
--                                   | | | '__|| | / _` | / _` | / _ \| '__|                               --
--                                   | | | |   | || (_| || (_| ||  __/| |                                  --
--                                   |_| |_|   |_| \__, | \__, | \___||_|                                  --
--                                                 |___/  |___/                                            --
--                                                                                                         --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/

-- Invoke after SP1 （Ronald)

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
/*=========================================================================================================*/

-- Invoke after SP2 (Bryan)
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
/*=========================================================================================================*/

-- Invoke after SP3 (JC)
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
/*=========================================================================================================*/



-------------------------------------------------------------------------------------------------------------
--                  ___          _    _             _             _    _                                   --
--                 / _ \  _ __  | |_ (_) _ __ ___  (_) ____ __ _ | |_ (_)  ___   _ __                      --
--                | | | || '_ \ | __|| || '_ ` _ \ | ||_  // _` || __|| | / _ \ | '_ \                     --
--                | |_| || |_) || |_ | || | | | | || | / /| (_| || |_ | || (_) || | | |                    --
--                 \___/ | .__/  \__||_||_| |_| |_||_|/___|\__,_| \__||_| \___/ |_| |_|                    --
--                       |_|                                                                               --
--                     ____   _                                                                            --
--                    / ___| | |_  _ __  __ _ | |_  ___   __ _  _   _                                      --
--                    \___ \ | __|| '__|/ _` || __|/ _ \ / _` || | | |                                     --   
--                     ___) || |_ | |  | (_| || |_|  __/| (_| || |_| |                                     --
--                    |____/  \__||_|   \__,_| \__|\___| \__, | \__, |                                     --
--                                                       |___/  |___/                                      --
--                                                                                                         --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/
  
-- Ronald Oh Fu Ming
--------------------------------------------------------------------------
--                            Test Sub-Queries                          --
--------------------------------------------------------------------------
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
/*=========================================================================================================*/

-- Bryan Tee Ming Jun
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
/*=========================================================================================================*/

-- Khoo Jie Cheng
--------------------------------------------------------------------------
--                          Database Sharding                           --
--------------------------------------------------------------------------
/*======================================================================*/
SELECT COUNT(*) AS ActiveUsersBornIn1990s
FROM [User]
WHERE account_status = 'active'
  AND date_of_birth BETWEEN '1990-01-01' AND '2000-12-31';



SELECT * INTO User_Shard1 FROM [User] WHERE 1 = 0;
SELECT * INTO User_Shard2 FROM [User] WHERE 1 = 0;
SELECT * INTO User_Shard3 FROM [User] WHERE 1 = 0;

-- Shard 1: User_ID 1 - 100000
INSERT INTO User_Shard1
SELECT * FROM [User]
WHERE CAST(SUBSTRING(User_ID, 2, 6) AS INT) BETWEEN 1 AND 100000;

-- Shard 2: User_ID 100001 - 200000
INSERT INTO User_Shard2
SELECT * FROM [User]
WHERE CAST(SUBSTRING(User_ID, 2, 6) AS INT) BETWEEN 100001 AND 200000;

-- Shard 3: User_ID 200001 - 300000
INSERT INTO User_Shard3
SELECT * FROM [User]
WHERE CAST(SUBSTRING(User_ID, 2, 6) AS INT) BETWEEN 200001 AND 300000;


SELECT COUNT(*) AS ActiveUsersBornIn1990s
FROM (
    SELECT date_of_birth FROM User_Shard1
    WHERE account_status = 'active'
      AND date_of_birth BETWEEN '1990-01-01' AND '2000-12-31'

    UNION ALL

    SELECT date_of_birth FROM User_Shard2
    WHERE account_status = 'active'
      AND date_of_birth BETWEEN '1990-01-01' AND '2000-12-31'

    UNION ALL

    SELECT date_of_birth FROM User_Shard3
    WHERE account_status = 'active'
      AND date_of_birth BETWEEN '1990-01-01' AND '2000-12-31'
) AS AllMatches;
/*=========================================================================================================*/



-------------------------------------------------------------------------------------------------------------
--                   ____    ___   _        ___                               ___   _                      --
--                  / ___|  / _ \ | |      / _ \  _   _   ___  _ __  _   _   / _ \ / |                     --
--                  \___ \ | | | || |     | | | || | | | / _ \| '__|| | | | | | | || |                     --
--                   ___) || |_| || |___  | |_| || |_| ||  __/| |   | |_| | | |_| || |                     --
--                  |____/  \__\_\|_____|  \__\_\ \__,_| \___||_|    \__, |  \__\_\|_|                     --
--                                                                   |___/                                 --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/

-- Khoo Jie Cheng (Student 1)
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
/*=========================================================================================================*/



-------------------------------------------------------------------------------------------------------------
--                ____    ___   _        ___                                ___   ____                     --
--               / ___|  / _ \ | |      / _ \  _   _   ___  _ __  _   _    / _ \ |___ \                    --
--               \___ \ | | | || |     | | | || | | | / _ \| '__|| | | |  | | | |  __) |                   --
--                ___) || |_| || |___  | |_| || |_| ||  __/| |   | |_| |  | |_| | / __/                    --
--               |____/  \__\_\|_____|  \__\_\ \__,_| \___||_|    \__, |   \__\_\|_____|                   --
--                                                                |___/                                    --
--                                                                                                         --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/

-- Bryan Tee Ming Jun (Student 2)
-- 1) Find the presentation room which has the greatest number of bookings
SELECT TOP 1 rb.room_id, r.room_name, COUNT(*) AS total_bookings
FROM RoomBooking rb
JOIN Room r ON rb.room_id = r.room_id
GROUP BY rb.room_id, r.room_name
ORDER BY total_bookings DESC;
/*=========================================================================================================*/

-- 2) Show the person who have never made any loan.
SELECT u.user_id, u.first_name, u.email
FROM [User] u
LEFT JOIN Loan l ON u.user_id = l.user_id
WHERE l.loan_id IS NULL;
/*=========================================================================================================*/

-- 3) Find the person who paid the highest total fine.
SELECT TOP 1 u.user_id, u.first_name, u.email, SUM(l.loan_fine_amount) AS total_fines
FROM [User] u
JOIN Loan l ON u.user_id = l.user_id
GROUP BY u.user_id, u.first_name, u.email
ORDER BY total_fines DESC;

/*=========================================================================================================*/

-- 4) Create a query which provides, for the loan, 
--    the total amount of fine from different types of persons 
--    in the university such as staff and students.
SELECT 
    ISNULL(PersonType, 'Total') AS PersonType,
    SUM(loan_fine_amount) AS total_fine
FROM (
    SELECT 
        u.user_id,
        CASE 
            WHEN lib.user_id IS NOT NULL THEN 'Librarian'
            WHEN lec.user_id IS NOT NULL THEN 'Lecturer'
            WHEN s.user_id IS NOT NULL THEN 'Student'
            WHEN sta.user_id IS NOT NULL THEN 'Staff'
            ELSE 'Unknown'
        END AS PersonType,
        l.loan_fine_amount
    FROM Loan l
    JOIN [User] u ON l.user_id = u.user_id
    LEFT JOIN Librarian lib ON u.user_id = lib.user_id
    LEFT JOIN Lecturer lec ON u.user_id = lec.user_id
    LEFT JOIN Student s ON u.user_id = s.user_id
    LEFT JOIN Staff sta ON u.user_id = sta.user_id
) AS fine_data
GROUP BY ROLLUP(PersonType);
/*=========================================================================================================*/

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
/*=========================================================================================================*/



-------------------------------------------------------------------------------------------------------------
--                ____    ___   _        ___                               ___   _____                     --
--               / ___|  / _ \ | |      / _ \  _   _   ___  _ __  _   _   / _ \ |___ /                     --
--               \___ \ | | | || |     | | | || | | | / _ \| '__|| | | | | | | |  |_ \                     --
--                ___) || |_| || |___  | |_| || |_| ||  __/| |   | |_| | | |_| | ___) |                    --
--               |____/  \__\_\|_____|  \__\_\ \__,_| \___||_|    \__, |  \__\_\|____/                     --
--                                                                |___/                                    --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/

-- Ronald Oh Fu Ming (Student 3)
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
/*=========================================================================================================*/


