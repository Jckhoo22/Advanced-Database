/*=========================================================================================================*/
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
/*=========================================================================================================*/

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
/*=========================================================================================================*/

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
/*=========================================================================================================*/

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
/*=========================================================================================================*/

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
/*=========================================================================================================*/

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
/*=========================================================================================================*/

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
/*=========================================================================================================*/

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
/*=========================================================================================================*/

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
/*=========================================================================================================*/