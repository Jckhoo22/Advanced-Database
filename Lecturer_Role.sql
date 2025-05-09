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


-------------------------------------------------------------------------------------------------------------
--                                                CAN BE ACCESS                                            --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/
-- Lecturer can browse books, view genres, authors, and descriptions
SELECT * FROM Book;
SELECT * FROM BookDescription;
SELECT * FROM Author;
SELECT * FROM Genre;
/*=========================================================================================================*/

-- Lecturer can view copy availability (available, loaned, reserved, etc.)
SELECT availability_status, BookCopy_ID FROM BookCopy;
/*=========================================================================================================*/

-- Lecturer  can view Tag details (so they can know which books are reference/non-loanable)
SELECT * FROM Tag;
/*=========================================================================================================*/

-- Lecturer can view and make reservation
SELECT * FROM Reservation;
INSERT INTO Reservation (Reservation_ID, BookCopy_ID, User_ID, reservation_created_date, expiry_date)
VALUES('RS0001', 'BC00001', 'U3001', GETDATE(), null);
/*=========================================================================================================*/

-- Lecturer can view own loan history
SELECT * FROM Loan;
/*=========================================================================================================*/

-- Lecturer can view room booking status and make booking for a room
SELECT * FROM RoomBooking;
INSERT INTO RoomBooking (RoomBooking_ID, Room_ID, User_ID, room_booking_created_time, end_time)
VALUES ('RB0001', 'R001', 'U3001', GETDATE(), null);
/*=========================================================================================================*/

-- Lecturer can view room status and details
SELECT * FROM Room;
SELECT * FROM RoomDetails;
/*=========================================================================================================*/


-------------------------------------------------------------------------------------------------------------
--                                             CANNOT BE ACCESS                                            --
-------------------------------------------------------------------------------------------------------------
/*=========================================================================================================*/
-- Lecturer also have some table cannot be view
SELECT * FROM LoginCredentials;

-- Lecturer dont have access to update any table data
UPDATE Book
SET book_title = 'Cant be change'
WHERE ISBN = 'ISBN000000000013';

-- Lecturer dont have access to delete any table data
DELETE Reservation
WHERE Reservation_ID = 'RS0001';


-- Lecturer


