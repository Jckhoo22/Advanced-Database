use RKB_Library_OS;

--------------------------------------------------------------------------
--                        Add Data Into Table                           --
--------------------------------------------------------------------------
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



INSERT INTO Tag (Tag_ID, tag_name, fine_rate, loan_period, loanable_status)
VALUES
('T001', 'Yellow', 2.00, 14, 'loanable'),
('T002', 'Red', 3.00, 7, 'non loanable'),
('T003', 'Green', 1.00, 21, 'loanable');



INSERT INTO AgeSuggestion (AgeSuggestion_ID, rating_label, min_age, description)
VALUES
('AS001', 'All Ages', 0, 'Suitable for all readers, including children'),
('AS002', 'Children', 7, 'Content suitable for young readers aged 7 and above'),
('AS003', 'Teen', 13, 'Recommended for teenagers aged 13 and older'),
('AS004', 'Young Adult', 16, 'Content ideal for young adults aged 16+'),
('AS005', 'Adult', 18, 'Content intended for mature readers aged 18 and above'),
('AS006', 'Academic Only', 21, 'Recommended for academic and research purposes, typically university students and staff');



INSERT INTO Room (Room_ID, room_name)
VALUES
('R001', 'Presentation Room 1'),
('R002', 'Presentation Room 2'),
('R003', 'Presentation Room 3'),
('R004', 'Presentation Room 4'),
('R005', 'Presentation Room 5');



INSERT INTO RoomDetails (Room_ID, room_capacity, room_floor, maintenance_status)
VALUES
('R001', 30, 4, 'available'),
('R002', 25, 4, 'under maintenance'),
('R003', 40, 4, 'available'),
('R004', 20, 5, 'closed'),
('R005', 35, 5, 'available');



--Insert 3000 student inside the user table
DECLARE @counter INT = 1;
DECLARE @UserID VARCHAR(10);
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

WHILE @counter <= 3000
BEGIN
    SET @UserID = 'U' + RIGHT('0000' + CAST(@counter AS VARCHAR), 4);
    SET @FName = 'StudentFirst' + CAST(@counter AS VARCHAR);
    SET @LName = 'StudentLast' + CAST(@counter AS VARCHAR);
    SET @DOB = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 8000), GETDATE());
    SET @Email = LOWER(@FName + '.' + @LName + '@mail.com');
    SET @Gender = CASE WHEN @counter % 3 = 0 THEN 'male' WHEN @counter % 3 = 1 THEN 'female' ELSE 'other' END;
    SET @Address = 'Address ' + CAST(@counter AS VARCHAR);
    SET @Contact = '010' + CAST(1000000 + @counter AS VARCHAR);
    SET @AccountStatus = CASE WHEN @counter % 50 = 0 THEN 'suspended' ELSE 'active' END;

    INSERT INTO [User] (User_ID, first_name, last_name, date_of_birth, contact_number, email, gender, address, account_status)
    VALUES (@UserID, @FName, @LName, @DOB, @Contact, @Email, @Gender, @Address, @AccountStatus);

    -- Student Table
    SET @Program = 'Program ' + CAST((@counter % 5 + 1) AS VARCHAR);
    SET @Faculty = 'Faculty ' + CAST((@counter % 4 + 1) AS VARCHAR);
    SET @EnrollmentDate = DATEADD(YEAR, -1 * (ABS(CHECKSUM(NEWID())) % 5), GETDATE());
    SET @CGPA = ROUND(RAND() * 4.0, 2);

    INSERT INTO Student (User_ID, program, faculty, enrollment_date, CGPA)
    VALUES (@UserID, @Program, @Faculty, @EnrollmentDate, @CGPA);

    SET @counter = @counter + 1;
END;



--Insert 1200 into Staff (Lecturer)
DECLARE @counter INT = 3001;
DECLARE @UserID VARCHAR(10);
DECLARE @FName VARCHAR(50);
DECLARE @LName VARCHAR(50);
DECLARE @DOB DATE;
DECLARE @Email VARCHAR(100);
DECLARE @Gender VARCHAR(10);
DECLARE @Address VARCHAR(255);
DECLARE @Contact VARCHAR(20);
DECLARE @AccountStatus VARCHAR(20);

DECLARE @StartDate DATE;
DECLARE @Salary DECIMAL(10,2);

DECLARE @Department VARCHAR(100);
DECLARE @Specialization VARCHAR(100);
DECLARE @OfficeHour VARCHAR(50);
DECLARE @OfficeLocation VARCHAR(100);

WHILE @counter <= 4200
BEGIN
    SET @UserID = 'U' + RIGHT('0000' + CAST(@counter AS VARCHAR), 4);
    SET @FName = 'LecturerFirst' + CAST(@counter AS VARCHAR);
    SET @LName = 'LecturerLast' + CAST(@counter AS VARCHAR);
    SET @DOB = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 12000), GETDATE());
    SET @Email = LOWER(@FName + '.' + @LName + '@university.edu');
    SET @Gender = CASE WHEN @counter % 2 = 0 THEN 'male' ELSE 'female' END;
    SET @Address = 'Lecturer Address ' + CAST(@counter AS VARCHAR);
    SET @Contact = '011' + CAST(2000000 + @counter AS VARCHAR);
    SET @AccountStatus = 'active';

    INSERT INTO [User] (User_ID, first_name, last_name, date_of_birth, contact_number, email, gender, address, account_status)
    VALUES (@UserID, @FName, @LName, @DOB, @Contact, @Email, @Gender, @Address, @AccountStatus);

    -- Staff
    SET @StartDate = DATEADD(YEAR, -1 * (ABS(CHECKSUM(NEWID())) % 20), GETDATE());
    SET @Salary = ROUND(4000 + (RAND() * 3000), 2);

    INSERT INTO Staff (User_ID, start_working_date, salary)
    VALUES (@UserID, @StartDate, @Salary);

    -- Lecturer
    SET @Department = 'Department ' + CAST((@counter % 5 + 1) AS VARCHAR);
    SET @Specialization = 'Specialization ' + CAST((@counter % 10 + 1) AS VARCHAR);
    SET @OfficeHour = 'Mon-Fri 9AM-5PM';
    SET @OfficeLocation = 'Block ' + CHAR(65 + (@counter % 5)) + '-' + CAST((@counter % 10 + 1) AS VARCHAR);

    INSERT INTO Lecturer (User_ID, department, specialization, office_hour, office_location)
    VALUES (@UserID, @Department, @Specialization, @OfficeHour, @OfficeLocation);

    SET @counter = @counter + 1;
END;



--Insert 800 into Staff (Librarian)
DECLARE @c INT = 4201;
DECLARE @StaffID VARCHAR(10);
DECLARE @NameF VARCHAR(50);
DECLARE @NameL VARCHAR(50);
DECLARE @SDOB DATE;
DECLARE @SEmail VARCHAR(100);
DECLARE @SGender VARCHAR(10);
DECLARE @SAddress VARCHAR(255);
DECLARE @SContact VARCHAR(20);
DECLARE @SAccountStatus VARCHAR(20);

DECLARE @StartDate1 DATE;
DECLARE @Salary1 DECIMAL(10,2);

DECLARE @ShiftStart TIME;
DECLARE @ShiftEnd TIME;
DECLARE @Branch VARCHAR(100);
DECLARE @Task NVARCHAR(MAX);

WHILE @c <= 5000
BEGIN
    SET @StaffID = 'U' + RIGHT('0000' + CAST(@c AS VARCHAR), 4);
    SET @NameF = 'LibrarianFirst' + CAST(@c AS VARCHAR);
    SET @NameL = 'LibrarianLast' + CAST(@c AS VARCHAR);
    SET @SDOB = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 12000), GETDATE());
    SET @SEmail = LOWER(@NameF + '.' + @NameL + '@university.edu');
    SET @SGender = CASE WHEN @c % 2 = 0 THEN 'male' ELSE 'female' END;
    SET @SAddress = 'Librarian Address ' + CAST(@c AS VARCHAR);
    SET @SContact = '012' + CAST(3000000 + @c AS VARCHAR);
    SET @SAccountStatus = 'active';

    INSERT INTO [User] (User_ID, first_name, last_name, date_of_birth, contact_number, email, gender, address, account_status)
    VALUES (@StaffID, @NameF, @NameL, @SDOB, @SContact, @SEmail, @SGender, @SAddress, @SAccountStatus);

    -- Staff
    SET @StartDate1 = DATEADD(YEAR, -1 * (ABS(CHECKSUM(NEWID())) % 10), GETDATE());
    SET @Salary1 = ROUND(2500 + (RAND() * 2000), 2);

    INSERT INTO Staff (User_ID, start_working_date, salary)
    VALUES (@StaffID, @StartDate1, @Salary1);

    -- Librarian
    SET @ShiftStart = '08:00:00';
    SET @ShiftEnd = '17:00:00';
    SET @Branch = 'Library Block ' + CHAR(65 + (@c % 5));
    SET @Task = 'Assist users, manage book circulation and maintain library records.';

    INSERT INTO Librarian (User_ID, shift_starting_time, shift_ending_time, shift_branch, shift_task)
    VALUES (@StaffID, @ShiftStart, @ShiftEnd, @Branch, @Task);

    SET @c = @c + 1;
END;



--Insert 200 Student as Librarians
DECLARE @studentCounter INT = 1;
DECLARE @studentUserID VARCHAR(10);

WHILE @studentCounter <= 200
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



--Insert 5000 Author
DECLARE @c1 INT = 1;
DECLARE @AuthorID VARCHAR(10);
DECLARE @AuthorName VARCHAR(100);

WHILE @c1 <= 5000
BEGIN
    SET @AuthorID = 'A' + RIGHT('0000' + CAST(@c1 AS VARCHAR), 4);
    SET @AuthorName = 'Author_' + CAST(@c1 AS VARCHAR);

    INSERT INTO Author (Author_ID, author_name)
    VALUES (@AuthorID, @AuthorName);

    SET @c1 = @c1 + 1;
END;



--Insert 20000 books
DECLARE @c2 INT = 1;
DECLARE @ISBN VARCHAR(20);
DECLARE @Title VARCHAR(255);
DECLARE @GenreID VARCHAR(10);
DECLARE @AgeID VARCHAR(10);
DECLARE @TagID VARCHAR(10);

WHILE @c2 <= 20000
BEGIN
    SET @ISBN = 'ISBN' + RIGHT('000000000000' + CAST(@c2 AS VARCHAR), 12);
    SET @Title = 'Book Title ' + CAST(@c2 AS VARCHAR);

    -- Rotate GenreID (G001 to G009)
    SET @GenreID = 'G00' + CAST(((@c2 - 1) % 9) + 1 AS VARCHAR);

    -- Rotate AgeSuggestion_ID (AS001 to AS006)
    SET @AgeID = 'AS00' + CAST(((@c2 - 1) % 6) + 1 AS VARCHAR);

    -- Rotate Tag_ID (T001 to T003)
    SET @TagID = 'T00' + CAST(((@c2 - 1) % 3) + 1 AS VARCHAR);

    INSERT INTO Book (ISBN, book_title, Genre_ID, AgeSuggestion_ID, Tag_ID)
    VALUES (@ISBN, @Title, @GenreID, @AgeID, @TagID);

    SET @c2 = @c2 + 1;
END;



--Insert book description 20000
DECLARE @c3 INT = 1;
DECLARE @ISBN1 VARCHAR(20);
DECLARE @Desc NVARCHAR(MAX);  -- Use NVARCHAR(MAX) since TEXT can't be declared

WHILE @c3 <= 20000
BEGIN
    SET @ISBN1 = 'ISBN' + RIGHT('000000000000' + CAST(@c3 AS VARCHAR), 12);
    SET @Desc = 'This is the description for Book Title ' + CAST(@c3 AS VARCHAR);

    INSERT INTO BookDescription (ISBN, description)
    VALUES (@ISBN1, @Desc);

    SET @c3 = @c3 + 1;
END;



--Insert 10,000 Book Copies
DECLARE @c4 INT = 1;
DECLARE @BookCopyID VARCHAR(10);
DECLARE @ISBN2 VARCHAR(20);
DECLARE @Status VARCHAR(20);

WHILE @c4 <= 100000
BEGIN
    SET @BookCopyID = 'BC' + RIGHT('00000' + CAST(@c4 AS VARCHAR), 5);

    -- Cycle through 20,000 ISBNs
    SET @ISBN2 = 'ISBN' + RIGHT('000000000000' + CAST(((@c4 - 1) % 20000) + 1 AS VARCHAR), 12);

    -- Rotate availability status
    SET @Status = CASE (@c4 % 3)
                    WHEN 1 THEN 'Available'
                    WHEN 2 THEN 'Loaned'
                    ELSE 'Reserved'
                  END;

    INSERT INTO BookCopy (BookCopy_ID, ISBN, availability_status)
    VALUES (@BookCopyID, @ISBN2, @Status);

    SET @c4 = @c4 + 1;
END;


--Assign 1 author to each of 15,000 books
DECLARE @c5 INT = 1;
DECLARE @ISBN3 VARCHAR(20);
DECLARE @AuthorID1 VARCHAR(10);

WHILE @c5 <= 15000
BEGIN
    SET @ISBN3 = 'ISBN' + RIGHT('000000000000' + CAST(@c5 AS VARCHAR), 12);
    SET @AuthorID1 = 'A' + RIGHT('0000' + CAST((@c5 % 5000) + 1 AS VARCHAR), 4);

    INSERT INTO BookAuthor (ISBN, Author_ID)
    VALUES (@ISBN3, @AuthorID1);

    SET @c5 = @c5 + 1;
END;
--Second pass: add 5000 more (random books get 2nd/3rd authors)
SET @c5 = 1;
WHILE @c5 <= 5000
BEGIN
    SET @ISBN3 = 'ISBN' + RIGHT('000000000000' + CAST(((@c5 * 4) % 20000 + 1) AS VARCHAR), 12);  -- spread across books
    SET @AuthorID1 = 'A' + RIGHT('0000' + CAST(((1234 + @c5) % 5000 + 1) AS VARCHAR), 4);

    -- Ensure no duplicate (optional safety)
    IF NOT EXISTS (
        SELECT 1 FROM BookAuthor WHERE ISBN = @ISBN3 AND Author_ID = @AuthorID1
    )
    BEGIN
        INSERT INTO BookAuthor (ISBN, Author_ID)
        VALUES (@ISBN3, @AuthorID1);
    END

    SET @c5 = @c5 + 1;
END;



--Insert 100,000 into loan
DECLARE @c6 INT = 1;
DECLARE @LoanID VARCHAR(10);
DECLARE @BookCopyID1 VARCHAR(10);
DECLARE @UserID1 VARCHAR(10);
DECLARE @Fine DECIMAL(6,2);
DECLARE @LoanDate DATE;
DECLARE @ReturnDate DATE;

WHILE @c6 <= 100000
BEGIN
    SET @LoanID = 'L' + RIGHT('00000' + CAST(@c6 AS VARCHAR), 5);

    -- Reuse book copies in rotation
    SET @BookCopyID1 = 'BC' + RIGHT('00000' + CAST(((@c6 - 1) % 10000 + 1) AS VARCHAR), 5);

    -- Rotate through 5000 users
    SET @UserID1 = 'U' + RIGHT('0000' + CAST(((@c6 - 1) % 5000 + 1) AS VARCHAR), 4);

    -- Random fine: 0 to 20
    SET @Fine = ROUND(RAND() * 20, 2);

    -- Random loan date in last 10 years
    SET @LoanDate = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 3650), GETDATE());

    -- Return date 730 days after loan date
    SET @ReturnDate = DATEADD(DAY, (7 + ABS(CHECKSUM(NEWID())) % 24), @LoanDate);

    INSERT INTO Loan (Loan_ID, BookCopy_ID, User_ID, loan_fine_amount, loan_created_date, return_date)
    VALUES (@LoanID, @BookCopyID1, @UserID1, @Fine, @LoanDate, @ReturnDate);

    SET @c6 = @c6 + 1;
END;
