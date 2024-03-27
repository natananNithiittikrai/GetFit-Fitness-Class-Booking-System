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

DROP TABLE IF EXISTS "UserAuthentication";
CREATE TABLE "UserAuthentication" (
  "UserID" SERIAL PRIMARY KEY,
  "Username" varchar(100) NOT NULL,
  "Password" varchar(255) NOT NULL,
  "LastLogin" timestamp,
  "AccountStatus" varchar(50) NOT NULL,
  "Role" varchar(50) NOT NULL,
  "LoginStatus" BOOLEAN DEFAULT FALSE
);

DROP TABLE IF EXISTS "Branches";
CREATE TABLE "Branches" (
  "BranchID" SERIAL PRIMARY KEY,
  "BranchName" varchar(100) NOT NULL,
  "BranchType" varchar(50),
  "Location" text NOT NULL,
  "PhoneNumber" varchar(20),
  "Email" varchar(100),
  "Facilities" text,
  "OpeningHours" text NOT NULL,
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
  "ClassesTaught" text NOT NULL,
  "Availability" text NOT NULL,
  "InstructorPhoto" varchar(255),
  "TrainingHourLogged" int CHECK ("TrainingHourLogged" >= 0),
  "Status" varchar(50) NOT NULL,
  "YearsOfExperience" int CHECK ("YearsOfExperience" >= 0),
  "Qualifications" text
);

DROP TABLE IF EXISTS "Customers";
CREATE TABLE "Customers" (
  "CustomerID" SERIAL PRIMARY KEY,
  "UserID" int NOT NULL,
  "CustomerName" varchar(100) NOT NULL,
  "Email" varchar(100) NOT NULL UNIQUE,
  "Address" text NOT NULL,
  "DateOfBirth" date NOT NULL,
  "Gender" varchar(50) NOT NULL,
  "EmergencyContact" varchar(100),
  "CustomerPhoto" varchar(255),
  "HealthIssues" text,
  "LastActivityDate" date
);

DROP TABLE IF EXISTS "Bookings";
CREATE TABLE "Bookings" (
  "BookingID" SERIAL PRIMARY KEY,
  "CustomerID" int NOT NULL,
  "ClassID" int NOT NULL,
  "BookingDateTime" timestamp NOT NULL,
  "SessionType" varchar(50) NOT NULL
);

DROP TABLE IF EXISTS "Memberships";
CREATE TABLE "Memberships" (
  "MembershipID" SERIAL PRIMARY KEY,
  "CustomerID" int NOT NULL,
  "TransactionID" int ,
  "Type" varchar(50) NOT NULL,
  "StartDate" date NOT NULL,
  "EndDate" date,
  "Status" varchar(50) NOT NULL,
  "Price" decimal(10,2) NOT NULL,
  "PaymentMethod" varchar(50) NOT NULL,
  "RenewalStatus" BOOLEAN,
  "LastPaymentDate" date,
  "NextPaymentDate" date NOT NULL,
  "AccessLevel" varchar(50) NOT NULL
);

DROP TABLE IF EXISTS "SalesAndProducts";
CREATE TABLE "SalesAndProducts" (
  "ProductID" SERIAL PRIMARY KEY,
  "ProductName" varchar(100) NOT NULL,
  "ProductDescription" text,
  "ProductType" varchar(50) NOT NULL,
  "Price" decimal(10,2) NOT NULL,
  "StockQuantity" int CHECK ("StockQuantity" >= 0),
  "TransactionID" int,
);

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

DROP TABLE IF EXISTS "PaymentTransactions";
CREATE TABLE "PaymentTransactions" (
  "TransactionID" SERIAL PRIMARY KEY,
  "CustomerID" int NOT NULL,
  "TransactionType" varchar(50) NOT NULL,
  "Amount" decimal(10,2) NOT NULL,
  "PaymentDate" date NOT NULL,
  "Status" varchar(50) NOT NULL
);

DROP TABLE IF EXISTS "Messages";
CREATE TABLE "Messages" (
  "MessageID" SERIAL PRIMARY KEY,
  "SenderID" int NOT NULL,
  "ReceiverID" int NOT NULL,
  "Content" text NOT NULL,
  "Timestamp" timestamp NOT NULL,
  "ReadStatus" varchar(50)
);


-- Add Foreign Key Constraints
ALTER TABLE "Messages" ADD FOREIGN KEY ("SenderID") REFERENCES "UserAuthentication" ("UserID");
ALTER TABLE "Messages" ADD FOREIGN KEY ("ReceiverID") REFERENCES "UserAuthentication" ("UserID");
ALTER TABLE "Instructors" ADD FOREIGN KEY ("UserID") REFERENCES "UserAuthentication" ("UserID");
ALTER TABLE "Instructors" ADD FOREIGN KEY ("BranchID") REFERENCES "Branches"("BranchID");
ALTER TABLE "Customers" ADD FOREIGN KEY ("UserID") REFERENCES "UserAuthentication" ("UserID");
ALTER TABLE "Customers" ADD FOREIGN KEY ("MembershipID") REFERENCES "Memberships" ("MembershipID");
ALTER TABLE "Bookings" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "Bookings" ADD FOREIGN KEY ("ClassID") REFERENCES "Classes" ("ClassID");
ALTER TABLE "Memberships" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "Memberships" ADD FOREIGN KEY ("TransactionID") REFERENCES "PaymentTransactions" ("TransactionID");
ALTER TABLE "SalesAndProducts" ADD FOREIGN KEY ("TransactionID") REFERENCES "PaymentTransactions" ("TransactionID");
ALTER TABLE "SalesAndProducts" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "PackagesAndGiftCards" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "Notifications" ADD FOREIGN KEY ("BookingID") REFERENCES "Bookings" ("BookingID");
ALTER TABLE "Notifications" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "PaymentTransactions" ADD FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");
ALTER TABLE "Classes" ADD FOREIGN KEY ("InstructorID") REFERENCES "Instructors" ("InstructorID");
ALTER TABLE "Classes" ADD FOREIGN KEY ("BranchID") REFERENCES "Branches" ("BranchID");
