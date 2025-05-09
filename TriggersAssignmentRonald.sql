USE RKB_Library;

-- Trigger 1
GO
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
Go

-- Trigger 2
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