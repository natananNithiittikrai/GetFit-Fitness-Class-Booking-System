-- Creating a User
INSERT INTO "UserAuthentication" ("Username", "Password", "LastLogin", "AccountStatus", "Role")
VALUES
('user1', 'password123', '2024-03-28 09:00:00', 'Active', 'Customer'),
('user2', 'password123', '2024-03-29 15:30:00', 'Active', 'Customer'),
('user3', 'password123', '2024-03-30 11:00:00', 'Active', 'Instructor');

-- Adding Branches
INSERT INTO "Branches" ("BranchName", "BranchType", "Location", "PhoneNumber", "Email", "Facilities", "OpeningHours", "MembershipOptions", "Status")
VALUES
('Jett Fitness Salaya', 'Basic', 'Salaya, Downtown', '02-789-6543', 'salaya@jettfitness.com', 'Gym', 'Mon-Fri 6am-10pm, Sat-Sun 8am-8pm', 'Monthly, Yearly', 'Open'),
('Jett Fitness Rama 2', 'Premium', 'Rama 2', '02-987-6544', 'rama2@jettfitness.com', 'Yoga Studio, Meditation Room, Pool, Spa', 'Mon-Fri 7am-9pm, Sat 9am-5pm', 'Monthly, Yearly', 'Open');

-- Adding Instructors
INSERT INTO "Instructors" ("UserID", "BranchID", "InstructorName", "Specialization", "Rating", "HireDate", "ClassesTaught", "Availability", "Status", "YearsOfExperience")
VALUES
(14, 5, 'Cbum', 'Aerobics, Cardio', 4.8, '2023-05-15', 'Cardio Kickboxing', 'Weekdays 4pm-9pm', 'Active', 3);

-- Adding Customers
INSERT INTO "Customers" ("UserID", "CustomerName", "Email",
                         "Address", "DateOfBirth", "Gender",
                         "EmergencyContact")
VALUES
(12, 'Mickey', 'mickey@gmail.com', 'Mahidol University', '2002-02-10', 'Male', '089-500-6296'),
(13, 'Bom', 'bom@gmail.com', 'Mahidol University', '2002-02-11', 'Male', '083-456-897');

-- After Creating account let's login first for Mickey and Bom
SELECT  user_login('user1', 'password123');
SELECT  user_login('user2', 'password123');

-- Buying membership for Bom and Mickey
SELECT buy_membership(8, 'Basic',
                      100.00, 'Credit Card',
                      'Basic');
SELECT buy_membership(9, 'Premium',
                      200.00, 'Credit Card',
                      'Premium');

-- Buying membership without login
SELECT buy_membership(7, 'Premium',
                      200.00, 'Credit Card',
                      'Premium');
-- Creating a class
SELECT create_class(11, 'Boxing', 'Learn Boxing Techniques',
                    'Boxing', 60, 'Hard',
                    5, '2024-03-30 18:00:00', 20);
-- Creating a class in different branches than instructor branch
SELECT create_class(11, 'Boxing', 'Learn Boxing Techniques',
                    'Boxing', 60, 'Hard',
                    6, '2024-03-30 18:00:00', 20);

-- Booking class
SELECT book_class(8, 18);
SELECT book_class(9, 18);

-- Booking class with Inactive membership example
SELECT book_class(7, 18);

-- Creating class in 'Premium' branch
SELECT create_class(10, 'Boxing', 'Learn Boxing Techniques',
                    'Boxing', 60, 'Hard',
                    6, '2024-03-30 18:00:00', 20);

-- Booking class in a Branch with different access level
SELECT book_class(8, 19);

-- Cancelling the class
SELECT cancel_class_booking(8, 18);

-- Adding products to the table
SELECT add_product_to_sales_and_products('Jett Fitness Shirt',
                                         'Limited edition t-shirt of Jett Fitness',
                                         'Clothes',10,2);
SELECT add_product_to_sales_and_products('Jett Fitness Bottle',
                                         'Limited edition bottle of Jett Fitness',
                                         'Bottle',5,10);

-- Purchasing a product
SELECT purchase_product(3, 8, 1,
                        10, 'Credit Card');

-- Purchasing product more than its quantity
SELECT purchase_product(4, 8, 3,
                        10, 'Credit Card');

-- Sending direct message
SELECT send_direct_message(12,14,
                           'Hey Cbum I want to know more' ||
                           ' about the boxing class you are teaching');
-- Check user's inbox
SELECT user_inbox(14);

-- See the direct message
SELECT get_direct_messages(12,14);

-- Sending more direct messages direct message
SELECT send_direct_message(12,14,
                           'I am a very big fan of' ||
                           ' your teaching');
SELECT send_direct_message(12,14,
                           'Please contact me back asap');
SELECT send_direct_message(14,12,
                           'Hey thank you for reaching out to me I will let' ||
                           ' you know about information on-site. See you there.');

--Check inbox again
SELECT user_inbox(14);

-- See the direct messages
SELECT get_direct_messages(14, 12);

--Check inbox again to see if the readStatus change or not?
SELECT user_inbox(14);

-- Updating info using procedure
CALL update_class_info(19,'Body Combat','Basic combat exercise',30);
CALL update_customer_info(9,'bom123@gmail','Bang Na');
CALL update_instructor_info(11,'Boxing',5);

-- Logging out
SELECT  user_logout(12);
SELECT  user_logout('user2');
