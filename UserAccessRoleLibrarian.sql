-- User Access Roles (Librarian) 
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
GRANT SELECT ON BookAuthor TO librarian;
GRANT SELECT ON Author TO librarian;
GRANT SELECT ON Genre TO librarian;

-- For viewing the room and its information
GRANT SELECT ON Room to librarian; 
GRANT SELECT ON RoomDetails to librarian; 

-- For allowing the librarian to edit student room booking
GRANT SELECT, UPDATE ON RoomBooking to librarian;