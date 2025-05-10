use RKB_Library;

-------------------------------------------------------------------------------------------------------------
--                _                 _                             ____         _                           --
--               | |     ___   ___ | |_  _   _  _ __  ___  _ __  |  _ \  ___  | |  ___                     --
--               | |    / _ \ / __|| __|| | | || '__|/ _ \| '__| | |_) |/ _ \ | | / _ \                    --
--               | |___|  __/| (__ | |_ | |_| || |  |  __/| |    |  _ <| (_) || ||  __/                    --
--               |_____|\___| \___| \__| \__,_||_|   \___||_|    |_| \_\\___/ |_| \___|                    --
--                                                                                                         --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/
-- Bryan Tee Ming Jun
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
