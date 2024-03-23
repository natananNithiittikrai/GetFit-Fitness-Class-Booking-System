DROP TABLE IF EXISTS "Classes";
CREATE TABLE "Classes" (
  "ClassID" SERIAL PRIMARY KEY,
  "ClassName" varchar(100) NOT NULL,
  "ClassDescription" text,
  "ClassType" varchar(50) NOT NULL,
  "InstructorID" int NOT NULL,
  "Duration" int CHECK ("Duration" > 0),
  "DifficultyLevel" varchar(50),
  "BranchID" int NOT NULL,
  "DateTime" timestamp NOT NULL,
  "MaxParticipants" int CHECK ("MaxParticipants" > 0)
);
ALTER TABLE "Classes" ADD FOREIGN KEY ("InstructorID") REFERENCES "Instructors" ("InstructorID");
ALTER TABLE "Classes" ADD FOREIGN KEY ("BranchID") REFERENCES "Branches" ("BranchID");


DROP TABLE IF EXISTS "UserAuthentication";
CREATE TABLE "UserAuthentication" (
  "UserID" SERIAL PRIMARY KEY,
  "Username" varchar(100) NOT NULL,
  "Password" varchar(255) NOT NULL,
  "LastLogin" timestamp,
  "AccountStatus" varchar(50) NOT NULL,
  "Role" varchar(50) NOT NULL
);

DROP TABLE IF EXISTS "Branches";
CREATE TABLE "Branches" (
  "BranchID" SERIAL PRIMARY KEY,
  "BranchName" varchar(100) NOT NULL,
  "BranchType" varchar(50),
  "Location" text NOT NULL,
  "PhoneNumber" varchar(20),
  "Email" varchar(100),
  "ManagerID" int,
  "Facilities" text,
  "OpeningHours" text,
  "MembershipOptions" text,
  "ClassTypesOffered" text,
  "EventsCalendarLink" varchar(255),
  "Status" varchar(50) NOT NULL
);

DROP TABLE IF EXISTS "Instructors";
CREATE TABLE "Instructors" (
  "InstructorID" SERIAL PRIMARY KEY,
  "UserID" int NOT NULL,
  "BranchID" int NOT NULL,
  "InstructorName" varchar(100) NOT NULL,
  "Specialization" varchar(100),
  "Rating" float CHECK ("Rating" >= 0 AND "Rating" <= 5),
  "HireDate" date NOT NULL,
  "ClassesTaught" text,
  "Availability" text,
  "InstructorPhoto" varchar(255),
  "TrainingHourLogged" int CHECK ("TrainingHourLogged" >= 0),
  "Status" varchar(50) NOT NULL,
  "YearsOfExperience" int CHECK ("YearsOfExperience" >= 0),
  "Qualifications" text
);
ALTER TABLE "Instructors" ADD FOREIGN KEY ("UserID") REFERENCES "UserAuthentication" ("UserID");
ALTER TABLE "Instructors" ADD FOREIGN KEY ("BranchID") REFERENCES "Branches"("BranchID");

DROP TABLE IF EXISTS "Customers";
CREATE TABLE "Customers" (
  "CustomerID" SERIAL PRIMARY KEY,
  "UserID" int NOT NULL,
  "CustomerName" varchar(100) NOT NULL,
  "Email" varchar(100),
  "Address" text,
  "MembershipID" int,
  "DateOfBirth" date,
  "Gender" varchar(50),
  "EmergencyContact" varchar(100),
  "CustomerPhoto" varchar(255),
  "HealthIssues" text,
  "LastActivityDate" date
);
ALTER TABLE "Customers" ADD FOREIGN KEY ("UserID") REFERENCES "UserAuthentication" ("UserID");
ALTER TABLE "Customers" ADD FOREIGN KEY ("MembershipID") REFERENCES "Memberships" ("MembershipID");

DROP TABLE IF EXISTS "Bookings";
CREATE TABLE "Bookings" (
  "BookingID" SERIAL PRIMARY KEY,
  "CustomerID" int NOT NULL,
  "ClassID" int NOT NULL,
  "BookingDateTime" timestamp NOT NULL,
  "SessionType" varchar(50) NOT NULL
);
ALTER TABLE "Bookings" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "Bookings" ADD FOREIGN KEY ("ClassID") REFERENCES "Classes" ("ClassID");

DROP TABLE IF EXISTS "Memberships";
CREATE TABLE "Memberships" (
  "MembershipID" SERIAL PRIMARY KEY,
  "CustomerID" int NOT NULL,
  "TransactionID" int,
  "Type" varchar(50) NOT NULL,
  "StartDate" date NOT NULL,
  "EndDate" date,
  "Status" varchar(50) NOT NULL,
  "Price" decimal(10,2),
  "PaymentMethod" varchar(50),
  "RenewalStatus" varchar(50),
  "LastPaymentDate" date,
  "NextPaymentDate" date,
  "DiscountsApplied" text,
  "Benefits" text,
  "AccessLevel" varchar(50)
);
ALTER TABLE "Memberships" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "Memberships" ADD FOREIGN KEY ("TransactionID") REFERENCES "PaymentTransactions" ("TransactionID");

DROP TABLE IF EXISTS "SalesAndProducts";
CREATE TABLE "SalesAndProducts" (
  "ProductID" SERIAL PRIMARY KEY,
  "ProductName" varchar(100) NOT NULL,
  "ProductDescription" text,
  "ProductType" varchar(50) NOT NULL,
  "Price" decimal(10,2) NOT NULL,
  "StockQuantity" int CHECK ("StockQuantity" >= 0),
  "TransactionID" int,
  "CustomerID" int
);
ALTER TABLE "SalesAndProducts" ADD FOREIGN KEY ("TransactionID") REFERENCES "PaymentTransactions" ("TransactionID");
ALTER TABLE "SalesAndProducts" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");

DROP TABLE IF EXISTS "PackagesAndGiftCards";
CREATE TABLE "PackagesAndGiftCards" (
  "PackageID" SERIAL PRIMARY KEY,
  "PackageName" varchar(100) NOT NULL,
  "Type" varchar(50) NOT NULL,
  "PackageDescription" text,
  "Price" decimal(10,2) NOT NULL,
  "PurchaseDate" date NOT NULL,
  "ValidityPeriod" int,
  "ExpirationDate" date,
  "CustomerID" int,
  "Usage" int CHECK ("Usage" >= 0),
  "Status" varchar(50) NOT NULL,
  "ActivationDate" date,
  "TermsAndConditions" text
);
ALTER TABLE "PackagesAndGiftCards" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");

DROP TABLE IF EXISTS "Notifications";
CREATE TABLE "Notifications" (
  "NotificationID" SERIAL PRIMARY KEY,
  "NotificationType" varchar(50) NOT NULL,
  "Status" varchar(50) NOT NULL,
  "NotificationDateTime" timestamp NOT NULL,
  "Content" text NOT NULL,
  "BookingID" int,
  "CustomerID" int
);
ALTER TABLE "Notifications" ADD FOREIGN KEY ("BookingID") REFERENCES "Bookings" ("BookingID");
ALTER TABLE "Notifications" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");

DROP TABLE IF EXISTS "PaymentTransactions";
CREATE TABLE "PaymentTransactions" (
  "TransactionID" SERIAL PRIMARY KEY,
  "CustomerID" int,
  "TransactionType" varchar(50) NOT NULL,
  "Amount" decimal(10,2) NOT NULL,
  "PaymentDate" date NOT NULL,
  "Status" varchar(50) NOT NULL,
  "ReceivedBy" int
);
ALTER TABLE "PaymentTransactions" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");

DROP TABLE IF EXISTS "Messages";
CREATE TABLE "Messages" (
  "MessageID" SERIAL PRIMARY KEY,
  "SenderID" int NOT NULL,
  "ReceiverID" int NOT NULL,
  "Content" text NOT NULL,
  "Timestamp" timestamp NOT NULL,
  "ReadStatus" varchar(50)
);
ALTER TABLE "Messages" ADD FOREIGN KEY ("SenderID") REFERENCES "UserAuthentication" ("UserID");
ALTER TABLE "Messages" ADD FOREIGN KEY ("ReceiverID") REFERENCES "UserAuthentication" ("UserID");
