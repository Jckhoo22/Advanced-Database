use RKB_Library;

-- SP2 -- Invoke Trigger 2 (Bryan)
/*=========================================================================================================*/

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

/*=========================================================================================================*/

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
/*=========================================================================================================*/

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
/*=========================================================================================================*/

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
/*=========================================================================================================*/

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
/*=========================================================================================================*/

--Trigger 
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