-- Test librarian here

USE RKB_Library;

-- For handling loan
Select * From Loan;

INSERT INTO Loan (Loan_ID, BookCopy_ID, User_ID, loan_fine_amount, loan_created_date, return_date) VALUES
('L0045', 'BC029', 'U001', 0.00, '2025-05-01', NULL);

UPDATE Loan
SET return_date = '2025-05-03', loan_fine_amount = 50
WHERE User_ID = 'U001' AND BookCopy_ID = 'BC029';

-- For handling and managing reservations
SELECT * FROM Reservation;

UPDATE Reservation
SET BookCopy_ID = 'BC027', User_ID = 'U001', reservation_created_date = '2025-05-05' 
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


