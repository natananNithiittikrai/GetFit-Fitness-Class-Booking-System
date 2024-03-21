DROP TABLE IF EXISTS "Classes";
CREATE TABLE "Classes" (
  "ClassID" int PRIMARY KEY,
  "ClassName" varchar,
  "ClassDescription" varchar,
  "ClassType" varchar,
  "InstructorID" int,
  "Duration" int,
  "DifficultyLevel" varchar,
  "BranchID" int,
  "DateOfClass" date,
  "TimeOfClass" time,
  "MaxParticipants" int
);

DROP TABLE IF EXISTS "UserAuthentication";
CREATE TABLE "UserAuthentication" (
  "UserID" int PRIMARY KEY,
  "Username" varchar,
  "PasswordHash" varchar,
  "Salt" varchar,
  "LastLogin" datetime,
  "AccountStatus" varchar
);

DROP TABLE IF EXISTS "Instructors";
CREATE TABLE "Instructors" (
  "InstructorID" int PRIMARY KEY,
  "InstructorName" varchar,
  "Specialization" varchar,
  "Rating" float,
  "HireDate" date,
  "ClassesTaught" varchar,
  "Availability" varchar,
  "InstructorPhoto" varchar,
  "SocialMedia" varchar,
  "TrainingHoursLogged" int,
  "Status" varchar,
  "YearsOfExperience" int,
  "Qualifications" varchar
);

DROP TABLE IF EXISTS "Branches";
CREATE TABLE "Branches" (
  "BranchID" int PRIMARY KEY,
  "BranchName" varchar,
  "BranchType" varchar,
  "Location" varchar,
  "PhoneNumber" varchar,
  "Email" varchar,
  "ManagerID" int,
  "Facilities" varchar,
  "OpeningHours" varchar,
  "MembershipOptions" varchar,
  "ClassTypesOffered" varchar,
  "EventsCalendarLink" varchar,
  "Status" varchar
);

DROP TABLE IF EXISTS "Customers";
CREATE TABLE "Customers" (
  "CustomerID" int PRIMARY KEY,
  "CustomerName" varchar,
  "Email" varchar,
  "Address" varchar,
  "MembershipID" int,
  "DateOfBirth" date,
  "Gender" varchar,
  "EmergencyContact" varchar,
  "CustomerPhoto" varchar,
  "HealthIssues" varchar,
  "LastActivityDate" date
);

DROP TABLE IF EXISTS "Bookings";
CREATE TABLE "Bookings" (
  "BookingID" int PRIMARY KEY,
  "CustomerID" int,
  "ClassID" int,
  "BookingDateTime" datetime,
  "SessionType" varchar
);

DROP TABLE IF EXISTS "Memberships";
CREATE TABLE "Memberships" (
  "MembershipID" int PRIMARY KEY,
  "CustomerID" int,
  "Type" varchar,
  "StartDate" date,
  "EndDate" date,
  "Status" varchar,
  "Price" decimal,
  "PaymentMethod" varchar,
  "RenewalStatus" varchar,
  "LastPaymentDate" date,
  "NextPaymentDate" date,
  "DiscountsApplied" varchar,
  "Benefits" varchar,
  "AccessLevel" varchar
);

DROP TABLE IF EXISTS "SalesAndProducts";
CREATE TABLE "SalesAndProducts" (
  "ProductID" int PRIMARY KEY,
  "ProductName" varchar,
  "ProductDescription" varchar,
  "Type" varchar,
  "Price" decimal,
  "StockQuantity" int,
  "TransactionID" int
);

DROP TABLE IF EXISTS "PackagesAndGiftCards";
CREATE TABLE "PackagesAndGiftCards" (
  "PackageID" int PRIMARY KEY,
  "Type" varchar,
  "Description" varchar,
  "Price" decimal,
  "Value" decimal,
  "PurchaseDate" date,
  "ValidityPeriod" int,
  "ExpirationDate" date,
  "CustomerID" int,
  "Usage" int,
  "Status" varchar,
  "ActivationDate" date,
  "TermsAndConditions" varchar
);

DROP TABLE IF EXISTS "Notifications";
CREATE TABLE "Notifications" (
  "NotificationID" int PRIMARY KEY,
  "Type" varchar,
  "Status" varchar,
  "Content" varchar,
  "BookingID" int,
  "CustomerID" int
);

DROP TABLE IF EXISTS "PaymentTransactions";
CREATE TABLE "PaymentTransactions" (
  "TransactionID" int PRIMARY KEY,
  "CustomerID" int,
  "PaymentMethod" varchar,
  "Amount" decimal,
  "PaymentDate" date,
  "Status" varchar,
  "ReceivedBy" int
);

-- Foreign key constraints
ALTER TABLE "Classes" ADD FOREIGN KEY ("InstructorID") REFERENCES "Instructors" ("InstructorID");
ALTER TABLE "Classes" ADD FOREIGN KEY ("BranchID") REFERENCES "Branches" ("BranchID");
ALTER TABLE "Customers" ADD FOREIGN KEY ("MembershipID") REFERENCES "Memberships" ("MembershipID");
ALTER TABLE "Bookings" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "Bookings" ADD FOREIGN KEY ("ClassID") REFERENCES "Classes" ("ClassID");
ALTER TABLE "Memberships" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "SalesAndProducts" ADD FOREIGN KEY ("TransactionID") REFERENCES "PaymentTransactions" ("TransactionID");
ALTER TABLE "PackagesAndGiftCards" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "Notifications" ADD FOREIGN KEY ("BookingID") REFERENCES "Bookings" ("BookingID");
ALTER TABLE "Notifications" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "PaymentTransactions" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");


DROP TABLE IF EXISTS "Classes";
CREATE TABLE "Classes" (
  "ClassID" int PRIMARY KEY,
  "ClassName" varchar,
  "ClassDescription" varchar,
  "ClassType" varchar,
  "InstructorID" int,
  "Duration" int,
  "DifficultyLevel" varchar,
  "BranchID" int,
  "DateTime" datetime,
  "MaxParticipants" int
);
ALTER TABLE "Classes" ADD FOREIGN KEY ("InstructorID") REFERENCES "Instructors" ("InstructorID");
ALTER TABLE "Classes" ADD FOREIGN KEY ("BranchID") REFERENCES "Branches" ("BranchID");

DROP TABLE IF EXISTS "UserAuthentication";
CREATE TABLE "UserAuthentication" (
  "UserID" int PRIMARY KEY,
  "Username" varchar,
  "Password" varchar,
  "LastLogin" datetime,
  "AccountStatus" varchar,
  "Role" varchar
);

DROP TABLE IF EXISTS "Instructors";
CREATE TABLE "Instructors" (
  "InstructorID" int PRIMARY KEY,
  "UserID" int,
  "InstructorName" varchar,
  "Specialization" varchar,
  "Rating" float,
  "HireDate" date,
  "ClassesTaught" varchar,
  "Availability" varchar,
  "InstructorPhoto" varchar,
  "TrainingHourLogged" int,
  "Status" varchar,
  "YearsOfExperience" int,
  "Qualifications" varchar
);
ALTER TABLE "Instructors" ADD FOREIGN KEY ("UserID") REFERENCES "UserAuthentication" ("UserID");

DROP TABLE IF EXISTS "Branches";
CREATE TABLE "Branches" (
  "BranchID" int PRIMARY KEY,
  "BranchName" varchar,
  "BranchType" varchar,
  "Location" varchar,
  "PhoneNumber" varchar,
  "Email" varchar,
  "ManagerID" int,
  "Facilities" varchar,
  "OpeningHours" varchar,
  "MembershipOptions" varchar,
  "ClassTypesOffered" varchar,
  "EventsCalendarLink" varchar,
  "Status" varchar
);

DROP TABLE IF EXISTS "Customers";
CREATE TABLE "Customers" (
  "CustomerID" int PRIMARY KEY,
  "UserID" int,
  "CustomerName" varchar,
  "Email" varchar,
  "Address" varchar,
  "MembershipID" int,
  "DateOfBirth" date,
  "Gender" varchar,
  "EmergencyContact" varchar,
  "CustomerPhoto" varchar,
  "HealthIssues" varchar,
  "LastActivityDate" date
);
ALTER TABLE "Customers" ADD FOREIGN KEY ("UserID") REFERENCES "UserAuthentication" ("UserID");
ALTER TABLE "Customers" ADD FOREIGN KEY ("MembershipID") REFERENCES "Memberships" ("MembershipID");

DROP TABLE IF EXISTS "Bookings";
CREATE TABLE "Bookings" (
  "BookingID" int PRIMARY KEY,
  "CustomerID" int,
  "ClassID" int,
  "BookingDateTime" datetime,
  "SessionType" varchar
);
ALTER TABLE "Bookings" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "Bookings" ADD FOREIGN KEY ("ClassID") REFERENCES "Classes" ("ClassID");

DROP TABLE IF EXISTS "Memberships";
CREATE TABLE "Memberships" (
  "MembershipID" int PRIMARY KEY,
  "CustomerID" int,
  "TransactionID" int,
  "Type" varchar,
  "StartDate" date,
  "EndDate" date,
  "Status" varchar,
  "Price" decimal,
  "PaymentMethod" varchar,
  "RenewalStatus" varchar,
  "LastPaymentDate" date,
  "NextPaymentDate" date,
  "DiscountsApplied" varchar,
  "Benefits" varchar,
  "AccessLevel" varchar
);
ALTER TABLE "Memberships" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "Memberships" ADD FOREIGN KEY ("TransactionID") REFERENCES "PaymentTransactions" ("TransactionID");

DROP TABLE IF EXISTS "SalesAndProducts";
CREATE TABLE "SalesAndProducts" (
  "ProductID" int PRIMARY KEY,
  "ProductName" varchar,
  "ProductDescription" varchar,
  "ProductType" varchar,
  "Price" decimal,
  "StockQuantity" int,
  "TransactionID" int,
  "CustomerID" int
);
ALTER TABLE "SalesAndProducts" ADD FOREIGN KEY ("TransactionID") REFERENCES "PaymentTransactions" ("TransactionID");
ALTER TABLE "SalesAndProducts" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");

DROP TABLE IF EXISTS "PackagesAndGiftCards";
CREATE TABLE "PackagesAndGiftCards" (
  "PackageID" int PRIMARY KEY,
  "PackageType" varchar,
  "Description" varchar,
  "Price" decimal,
  "Value" decimal,
  "PurchaseDate" date,
  "ValidityPeriod" int,
  "ExpirationDate" date,
  "CustomerID" int,
  "Usage" int,
  "Status" varchar,
  "ActivationDate" date,
  "TermsAndConditions" varchar,
  "TransactionID" int
);
ALTER TABLE "PackagesAndGiftCards" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "PackagesAndGiftCards" ADD FOREIGN KEY ("TransactionID") REFERENCES "PaymentTransactions" ("TransactionID");

DROP TABLE IF EXISTS "Notifications";
CREATE TABLE "Notifications" (
  "NotificationID" int PRIMARY KEY,
  "NotificationType" varchar,
  "Status" varchar,
  "NotificationDateTime" datetime,
  "Content" varchar,
  "BookingID" int,
  "CustomerID" int
);
ALTER TABLE "Notifications" ADD FOREIGN KEY ("BookingID") REFERENCES "Bookings" ("BookingID");
ALTER TABLE "Notifications" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");

DROP TABLE IF EXISTS "PaymentTransactions";
CREATE TABLE "PaymentTransactions" (
  "TransactionID" int PRIMARY KEY,
  "CustomerID" int,
  "TransactionType" varchar,
  "Amount" decimal,
  "PaymentDate" date,
  "Status" varchar,
  "ReceivedBy" int
);
ALTER TABLE "PaymentTransactions" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");

DROP TABLE IF EXISTS "Messages";
CREATE TABLE "Messages" (
  "MessageID" int PRIMARY KEY,
  "SenderID" int,
  "ReceiverID" int,
  "Content" text,
  "Timestamp" datetime,
  "ReadStatus" varchar
);
ALTER TABLE "Messages" ADD FOREIGN KEY ("SenderID") REFERENCES "UserAuthentication" ("UserID");
ALTER TABLE "Messages" ADD FOREIGN KEY ("ReceiverID") REFERENCES "UserAuthentication" ("UserID");


