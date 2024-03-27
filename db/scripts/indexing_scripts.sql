-- Indexing

-- Creating index on 'Username' in 'UserAuthentication' table
CREATE INDEX idx_user_auth_username ON "UserAuthentication" ("Username");

-- Creating index on 'BranchName' and 'BranchType' in 'Branches' table
CREATE INDEX idx_bookings_customer_class ON "Bookings" ("CustomerID", "ClassID");

-- Creating index on 'CustomerID' in 'Memberships' table
CREATE INDEX idx_memberships_customer ON "Memberships" ("CustomerID");

-- Creating index on 'InstructorID' and 'BranchID' in 'Classes' table
CREATE INDEX idx_classes_instructor_branch ON "Classes" ("InstructorID", "BranchID");

-- Creating index on 'CustomerID' and 'BookingID' in 'Notifications' table
CREATE INDEX idx_notifications_customer_booking ON "Notifications" ("CustomerID", "BookingID");
