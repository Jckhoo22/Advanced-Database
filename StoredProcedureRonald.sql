--use RKB_Library;

--GO

---- SP1
--CREATE PROCEDURE SP_Loan_Book
--    @User_ID VarChar(50),
--    @BookCopy_ID VarChar(50)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    -- Check if user has 10 or more active loans (no return_date yet)
--    IF (
--        SELECT COUNT(*) 
--        FROM Loan 
--        WHERE User_ID = @User_ID AND return_date IS NULL
--    ) >= 10
--    BEGIN
--        RAISERROR('User already has 10 active loans.', 16, 1);
--        RETURN;
--    END

--    -- Check if book copy is available
--    IF (
--        SELECT availability_status 
--        FROM BookCopy 
--        WHERE BookCopy_ID = @BookCopy_ID
--    ) != 'available'
--    BEGIN
--        RAISERROR('Book copy is not available.', 16, 1);
--        RETURN;
--    END

--    -- Check if the book is loanable or user is a Lecturer
--    IF EXISTS (
--        SELECT 1
--        FROM Book b
--        JOIN Tag t ON b.Tag_ID = t.Tag_ID
--        JOIN BookCopy bc ON b.ISBN = bc.ISBN
--        WHERE bc.BookCopy_ID = @BookCopy_ID 
--          AND t.loanable_status != 'loanable'
--          AND NOT EXISTS (
--              SELECT 1 FROM Lecturer WHERE User_ID = @User_ID
--          )
--    )
--    BEGIN
--        RAISERROR('Book is not loanable.', 16, 1);
--        RETURN;
--    END

--    -- All checks passed: insert into Loan
--    INSERT INTO Loan (BookCopy_ID, User_ID, loan_fine_amount, loan_created_date)
--    VALUES (@BookCopy_ID, @User_ID, 0, GETDATE());

--    -- Update the book copy's availability to 'loaned'
--    UPDATE BookCopy
--    SET availability_status = 'loaned'
--    WHERE BookCopy_ID = @BookCopy_ID;
--END;

--DROP PROCEDURE SP_Loan_Book

---- SP2
--CREATE PROCEDURE SP_Return_Book
--    @Loan_ID INT,
--    @return_date DATE
--AS
--BEGIN
--    SET NOCOUNT ON;

--    DECLARE @BookCopy_ID VarChar(50);
--    DECLARE @loan_created_date DATE;
--    DECLARE @ISBN VARCHAR(20);
--    DECLARE @Tag_ID VarChar(50);
--    DECLARE @loan_period INT;
--    DECLARE @fine_rate DECIMAL(10, 2);
--    DECLARE @overdue_days INT;
--    DECLARE @fine_amount DECIMAL(10, 2);

--    -- Get loan details
--    SELECT 
--        @BookCopy_ID = BookCopy_ID,
--        @loan_created_date = loan_created_date
--    FROM Loan
--    WHERE Loan_ID = @Loan_ID;

--    -- Get ISBN from BookCopy
--    SELECT @ISBN = ISBN
--    FROM BookCopy
--    WHERE BookCopy_ID = @BookCopy_ID;

--    -- Get Tag_ID from Book
--    SELECT @Tag_ID = Tag_ID
--    FROM Book
--    WHERE ISBN = @ISBN;

--    -- Get loan_period and fine_rate from Tag
--    SELECT 
--        @loan_period = loan_period,
--        @fine_rate = fine_rate
--    FROM Tag
--    WHERE Tag_ID = @Tag_ID;

--    -- Calculate overdue days
--    SET @overdue_days = DATEDIFF(DAY, @loan_created_date, @return_date) - @loan_period;
--    IF @overdue_days < 0
--        SET @overdue_days = 0;

--    -- Calculate fine
--    SET @fine_amount = @overdue_days * @fine_rate;

--    -- Update Loan with return_date and fine
--    UPDATE Loan
--    SET 
--        return_date = @return_date,
--        loan_fine_amount = @fine_amount
--    WHERE Loan_ID = @Loan_ID;

--    -- Update BookCopy to available
--    UPDATE BookCopy
--    SET availability_status = 'available'
--    WHERE BookCopy_ID = @BookCopy_ID;
--END;


---- SP3
--CREATE PROCEDURE SP_Reserve_Book
--    @User_ID VarChar(50),
--    @BookCopy_ID VarChar(50),
--    @reservation_created_date DATE
--AS
--BEGIN
--    SET NOCOUNT ON;

--    DECLARE @loan_created_date DATE;
--    DECLARE @expiry_date DATE;

--    -- Check if book copy is currently unavailable (i.e., loaned out)
--    IF (
--        SELECT availability_status
--        FROM BookCopy
--        WHERE BookCopy_ID = @BookCopy_ID
--    ) != 'loaned'
--    BEGIN
--        RAISERROR('Book copy is not currently loaned out and cannot be reserved.', 16, 1);
--        RETURN;
--    END

--    -- Get loan_created_date for the active loan of this book copy
--    SELECT TOP 1 @loan_created_date = loan_created_date
--    FROM Loan
--    WHERE BookCopy_ID = @BookCopy_ID AND return_date IS NULL;

--    -- If loan not found (shouldn't happen, but for safety)
--    IF @loan_created_date IS NULL
--    BEGIN
--        RAISERROR('No active loan found for this book copy.', 16, 1);
--        RETURN;
--    END

--    -- Calculate expiry date (5 days from loan_created_date)
--    SET @expiry_date = DATEADD(DAY, 5, @loan_created_date);

--    -- Insert reservation record
--    INSERT INTO Reservation (BookCopy_ID, User_ID, reservation_created_date, expiry_date)
--    VALUES (@BookCopy_ID, @User_ID, @reservation_created_date, @expiry_date);

--    -- Update book copy status to reserved
--    UPDATE BookCopy
--    SET availability_status = 'reserved'
--    WHERE BookCopy_ID = @BookCopy_ID;
--END;


---- SP4
--CREATE PROCEDURE SP_Expire_Reservation
--AS
--BEGIN
--    SET NOCOUNT ON;

--    DECLARE @Reservation_ID INT;
--    DECLARE @BookCopy_ID INT;
--    DECLARE @return_date DATE;

--    -- Cursor to loop through expired reservations
--    DECLARE expired_cursor CURSOR FOR
--        SELECT Reservation_ID, BookCopy_ID
--        FROM Reservation
--        WHERE expiry_date < GETDATE();

--	-- Open the cursor
--    OPEN expired_cursor;
--	-- Fetch the first row from the cursor and into two variables declared
--    FETCH NEXT FROM expired_cursor INTO @Reservation_ID, @BookCopy_ID;

--	-- This is a system function as it returns the status of the last FETCH statement from a cursor
--	-- 0 means that the FETCH was successful — data was returned
--    WHILE @@FETCH_STATUS = 0
--    BEGIN
--        -- Get latest loan return date for the book copy
--        SELECT TOP 1 @return_date = return_date
--        FROM Loan
--        WHERE BookCopy_ID = @BookCopy_ID
--        ORDER BY loan_created_date DESC;

--        -- Determine availability based on return_date
--        IF @return_date IS NULL
--        BEGIN
--            -- Book is still on loan
--            UPDATE BookCopy
--            SET availability_status = 'loaned'
--            WHERE BookCopy_ID = @BookCopy_ID;
--        END
--        ELSE
--        BEGIN
--            -- Book has been returned
--            UPDATE BookCopy
--            SET availability_status = 'available'
--            WHERE BookCopy_ID = @BookCopy_ID;
--        END

--        -- Optionally: delete or archive the expired reservation
--        DELETE FROM Reservation
--        WHERE Reservation_ID = @Reservation_ID;

--        FETCH NEXT FROM expired_cursor INTO @Reservation_ID, @BookCopy_ID;
--    END

--    CLOSE expired_cursor;
--    DEALLOCATE expired_cursor;
--END;


---- SP5 
--CREATE PROCEDURE SP_Booking_Room
--    @User_ID VARCHAR(50),
--    @room_name VARCHAR(100),
--    @room_booking_created_time DATETIME,
--    @end_time DATETIME
--AS
--BEGIN
--    SET NOCOUNT ON;

--    DECLARE @Room_ID INT;
--    DECLARE @DurationInMinutes INT;
--	DECLARE @MaintenanceStatus VARCHAR(50);

--    -- 1. Check if room exists
--    SELECT 
--        @Room_ID = r.Room_ID,
--        @MaintenanceStatus = rd.maintainance_status
--    FROM Room r
--    JOIN Room_Details rd ON r.Room_ID = rd.Room_ID
--    WHERE r.room_name = @room_name;

--    IF @Room_ID IS NULL
--    BEGIN
--        RAISERROR('Room name not found.', 16, 1);
--        RETURN;
--    END

--	-- 2. Check if room is under maintenance
--    IF @MaintenanceStatus <> 'available'
--    BEGIN
--        RAISERROR('Room is currently not available for booking (under maintenance).', 16, 1);
--        RETURN;
--    END

--    -- 2. Check duration (must not exceed 2 hours)
--    SET @DurationInMinutes = DATEDIFF(MINUTE, @room_booking_created_time, @end_time);

--    IF @DurationInMinutes > 180
--    BEGIN
--        RAISERROR('Booking duration cannot exceed 2 hours.', 16, 1);
--        RETURN;
--    END

--    -- 3. Check if room is already booked in that time
--    IF EXISTS (
--        SELECT 1
--        FROM Room_Booking
--        WHERE Room_ID = @Room_ID
--          AND (
--              (@room_booking_created_time BETWEEN room_booking_created_time AND end_time) --  Checks if the new booking START time overlaps with an existing booking window
--              OR (@end_time BETWEEN room_booking_created_time AND end_time) -- Checks if the new booking END time overlaps with an existing booking window
--              OR (room_booking_created_time BETWEEN @room_booking_created_time AND @end_time) -- Checks if an existing booking STARTS during the requested time window
--          )
--    )
--    BEGIN
--        RAISERROR('The room is already booked during the requested time.', 16, 1);
--        RETURN;
--    END

--    -- 4. Insert booking
--    INSERT INTO Room_Booking (User_ID, Room_ID, room_booking_created_time, end_time)
--    VALUES (@User_ID, @Room_ID, @room_booking_created_time, @end_time);
--END;


---- SP6
--CREATE PROCEDURE SP_User_Loan_History
--    @User_ID VARCHAR(50)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    -- Check if user has any loans
--    IF NOT EXISTS (SELECT 1 FROM Loan WHERE User_ID = @User_ID)
--    BEGIN
--        RAISERROR('No loan history found for this user.', 16, 1);
--        RETURN;
--    END

--    -- Return the user's loan history
--    SELECT 
--        l.Loan_ID,
--        l.User_ID,
--        l.BookCopy_ID,
--        b.Book_ID,
--        bk.title AS Book_Title,
--        l.loan_created_date,
--        l.return_date,
--        l.fine_amount
--    FROM Loan l
--    INNER JOIN BookCopy b ON l.BookCopy_ID = b.BookCopy_ID
--    INNER JOIN Book bk ON b.Book_ID = bk.Book_ID
--    WHERE l.User_ID = @User_ID
--    ORDER BY l.loan_created_date DESC;
--END;

-- Stored Procedure Ronald
use RKB_Library;
GO
CREATE PROCEDURE SP_Loan_Book -- Take 2 Parameter
    @User_ID VARCHAR(10),
    @BookCopy_ID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

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
    SET @NewLoanID = 'L' + RIGHT('000' + CAST(@MaxLoanNumber + 1 AS VARCHAR(9)), 3);

    INSERT INTO Loan
        (Loan_ID, BookCopy_ID, User_ID, loan_fine_amount, loan_created_date, return_date)
    VALUES
        (@NewLoanID, @BookCopy_ID, @User_ID, 0, GETDATE(), NULL);

END;
GO

EXEC SP_Loan_Book @User_ID = 'U002', @BookCopy_ID = 'BC023';

Select * From Loan 
Where User_ID = 'U002'