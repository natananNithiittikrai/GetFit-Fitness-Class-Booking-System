-- View script for the database
-- This script creates a view that shows all classes taught by an instructor
CREATE VIEW AllClassAvaliable AS
SELECT c."ClassID", c."ClassName", c."ClassDescription", c."ClassType", c."Duration", c."DifficultyLevel", c."BranchID", c."DateTime", c."MaxParticipants", i."InstructorID", i."InstructorName"
FROM "Classes" c
JOIN "Instructors" i ON c."InstructorID" = i."InstructorID";

-- View for customer membership information
CREATE VIEW CustomerMembershipInfo AS
SELECT cu."CustomerID", cu."CustomerName", cu."UserID", m."Type", m."Status", 
       m."StartDate", m."EndDate", m."AccessLevel"
FROM "Customers" cu
JOIN "Memberships" m ON cu."CustomerID" = m."CustomerID";
