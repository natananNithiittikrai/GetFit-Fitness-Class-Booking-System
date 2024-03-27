#___________________________________________________________________________________________________________________________#
# Basic insert statements to populate the tables with dummy data for testing and demonstration purposes.
INSERT INTO "UserAuthentication" ("Username", "Password", "LastLogin", "AccountStatus", "Role")
VALUES
('john_doe', 'password123', '2024-03-24 09:00:00', 'Active', 'Customer'),
('jane_smith', 'jane2024', '2024-03-23 15:30:00', 'Active', 'Instructor'),
('admin_user', 'adminPass', '2024-03-24 11:00:00', 'Active', 'Admin');

INSERT INTO "Branches" ("BranchName", "BranchType", "Location", "PhoneNumber", "Email", "Facilities", "OpeningHours", "MembershipOptions", "Status")
VALUES
('Downtown Fitness', 'Basic', '123 Main St, Downtown', '555-1234', 'contact@downtownfitness.com', 'Gym, Pool, Spa', 'Mon-Fri 6am-10pm, Sat-Sun 8am-8pm', 'Monthly, Yearly', 'Open'),
('Uptown fitness', 'Premium', '456 High St, Uptown', '555-5678', 'info@uptownwellness.com', 'Yoga Studio, Meditation Room', 'Mon-Fri 7am-9pm, Sat 9am-5pm', 'Monthly, Yearly, Pay per class', 'Open');

INSERT INTO "Instructors" ("UserID", "BranchID", "InstructorName", "Specialization", "Rating", "HireDate", "ClassesTaught", "Availability", "Status", "YearsOfExperience")
VALUES
(4, 2, 'Mike Johnson', 'Aerobics, Cardio', 4.8, '2023-05-15', 'Cardio Kickboxing', 'Weekdays 4pm-9pm', 'Active', 3);

INSERT INTO "Customers" ("UserID", "CustomerName", "Email", "Address", "MembershipID", "DateOfBirth", "Gender", "EmergencyContact")
VALUES
(1, 'John Doe', 'john.doe@example.com', '789 Park Ave, City', 1, '1990-05-20', 'Male', '555-9876'),

#___________________________________________________________________________________________________________________________#
# To add data using functions
SELECT buy_membership(6, 'Basic', 100.00, 'Credit Card', 'basic');
SELECT create_class(9, 'Yoga Class', 'Relax and unwind with yoga poses.', 'Yoga', 60, 'Beginner', 3, '2024-03-25 18:00:00', 20);
SELECT book_class(6, 3);

SELECT purchase_product(
    3,        -- Product ID
    6,        -- Customer ID
    2,          -- Purchase Quantity
    50.00,      -- Purchase Price
    'Credit'    -- Payment Method
);


#___________________________________________________________________________________________________________________________#