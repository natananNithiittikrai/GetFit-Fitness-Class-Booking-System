-- Functions / Procedures
#___________________________________________________________________________________________________________________________

-- Function to buy a membership
CREATE OR REPLACE FUNCTION buy_membership(customer_id int, membership_type varchar, price decimal, payment_method varchar)
RETURNS void AS $$
DECLARE
    user_id int;
    new_membership_id int;
    new_transaction_id int;
BEGIN
    -- Retrieve the UserID for the given CustomerID
    SELECT "UserID" INTO user_id FROM "Customers" WHERE "CustomerID" = customer_id;

    -- Check if the user is logged in
    IF NOT is_user_logged_in(user_id) THEN
        RAISE EXCEPTION 'User must be logged in to perform this action.';
    END IF;

    -- Insert into Memberships table
    INSERT INTO "Memberships" ("CustomerID", "Type", "StartDate", "EndDate", "Status", "Price", "PaymentMethod", "NextPaymentDate")
    VALUES (customer_id, membership_type, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 year', 'Active', price, payment_method, CURRENT_DATE + INTERVAL '1 month')
    RETURNING "MembershipID" INTO new_membership_id;

    -- Insert into PaymentTransactions table
    INSERT INTO "PaymentTransactions" ("CustomerID", "TransactionType", "Amount", "PaymentDate", "Status")
    VALUES (customer_id, 'Membership Purchase', price, CURRENT_DATE, 'Completed')
    RETURNING "TransactionID" INTO new_transaction_id;

    -- Update Memberships table with the transaction ID
    UPDATE "Memberships" SET "TransactionID" = new_transaction_id WHERE "MembershipID" = new_membership_id;
END;
$$ LANGUAGE plpgsql;

-- Function to create a class
CREATE OR REPLACE FUNCTION create_class(
    instructor_id INTEGER, 
    class_name VARCHAR, 
    class_description TEXT, 
    class_type VARCHAR, 
    duration INTEGER, 
    difficulty_level VARCHAR, 
    branch_id INTEGER, 
    class_datetime TIMESTAMP WITHOUT TIME ZONE, 
    max_participants INTEGER
) 
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    assigned_branch_id INT;
BEGIN
    -- Get the branch assigned to the instructor
    SELECT "BranchID" INTO assigned_branch_id FROM "Instructors"
    WHERE "InstructorID" = instructor_id;

    -- Check if the provided branch_id matches the instructor's assigned branch
    IF assigned_branch_id != branch_id THEN
        RAISE EXCEPTION 'Instructor can only create classes in their assigned branch.';
    END IF;

    -- Insert the class
    INSERT INTO "Classes" (
        "InstructorID", "ClassName", "ClassDescription", "ClassType", 
        "Duration", "DifficultyLevel", "BranchID", "DateTime", "MaxParticipants"
    )
    VALUES (
        instructor_id, class_name, class_description, class_type, 
        duration, difficulty_level, branch_id, class_datetime, max_participants
    );
END;
$$;

-- Function to book a class
CREATE OR REPLACE FUNCTION book_class(customer_id INTEGER, class_id INTEGER)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    user_id INT;
    membership_status VARCHAR;
    customer_access_level VARCHAR;
    branch_type VARCHAR;
    existing_booking_count INT;
BEGIN
    -- Retrieve the UserID for the given CustomerID
    SELECT "UserID" INTO user_id FROM "Customers" WHERE "CustomerID" = customer_id;

    -- Check if the user is logged in
    IF NOT is_user_logged_in(user_id) THEN
        RAISE EXCEPTION 'User must be logged in to perform this action.';
    END IF;

    -- Check if the customer has an active membership and get their access level
    SELECT m."Status", m."AccessLevel" INTO membership_status, customer_access_level
    FROM "Memberships" m
    WHERE m."CustomerID" = customer_id
    ORDER BY m."StartDate" DESC
    LIMIT 1;

    IF membership_status != 'Active' THEN
        RAISE EXCEPTION 'Customer does not have an active membership.';
    END IF;

    -- Get the branch type of the class
    SELECT b."BranchType" INTO branch_type
    FROM "Classes" c
    JOIN "Branches" b ON c."BranchID" = b."BranchID"
    WHERE c."ClassID" = class_id;

    -- Check for existing booking
    SELECT COUNT(*) INTO existing_booking_count
    FROM "Bookings"
    WHERE "CustomerID" = customer_id AND "ClassID" = class_id;

    IF existing_booking_count > 0 THEN
        RAISE EXCEPTION 'Customer has already booked this class.';
    END IF;

    -- Check if the customer's access level matches or exceeds the branch type
    IF NOT (LOWER(customer_access_level) = 'premium' OR LOWER(customer_access_level) = LOWER(branch_type)) THEN
        RAISE EXCEPTION 'Customer access level (%), does not match the class branch type (%).', customer_access_level, branch_type;
    END IF;

    -- Proceed to book the class
    INSERT INTO "Bookings" ("CustomerID", "ClassID", "BookingDateTime", "SessionType")
    VALUES (customer_id, class_id, CURRENT_TIMESTAMP, 'Standard');
END;
$$;

-- Function to purchase a product
CREATE OR REPLACE FUNCTION add_product_to_sales_and_products(
    product_name varchar,
    product_description text,
    product_type varchar,
    price decimal,
    stock_quantity int
)
RETURNS void AS $$
BEGIN
    IF NOT is_user_logged_in(user_id) THEN
            RAISE EXCEPTION 'User must be logged in to perform this action.';
    END IF;
    INSERT INTO "SalesAndProducts" (
        "ProductName",
        "ProductDescription",
        "ProductType",
        "Price",
        "StockQuantity"
    )
    VALUES (
        product_name,
        product_description,
        product_type,
        price,
        stock_quantity
    );
END;
$$ LANGUAGE plpgsql;

-- Function to purchase a product
CREATE OR REPLACE FUNCTION purchase_product(product_id int, customer_id int, purchase_quantity int, purchase_price decimal, payment_method varchar)
RETURNS void AS $$
DECLARE
    user_id int;
    current_stock int;
    new_transaction_id int;
BEGIN
    -- Retrieve the UserID for the given CustomerID
    SELECT "UserID" INTO user_id FROM "Customers" WHERE "CustomerID" = customer_id;

    -- Check if the user is logged in
    IF NOT is_user_logged_in(user_id) THEN
        RAISE EXCEPTION 'User must be logged in to perform this action.';
    END IF;

    -- Check current stock
    SELECT "StockQuantity" INTO current_stock FROM "SalesAndProducts" WHERE "ProductID" = product_id;

    IF current_stock < purchase_quantity THEN
        RAISE EXCEPTION 'Not enough stock to complete the purchase.';
    ELSE
        -- Create a transaction record
        INSERT INTO "PaymentTransactions" ("CustomerID", "TransactionType", "Amount", "PaymentDate", "Status")
        VALUES (customer_id, 'Product Purchase', purchase_price * purchase_quantity, CURRENT_DATE, 'Completed')
        RETURNING "TransactionID" INTO new_transaction_id;

        -- Update product record with the transaction ID and reduce stock
        UPDATE "SalesAndProducts"
        SET "StockQuantity" = current_stock - purchase_quantity, "TransactionID" = new_transaction_id
        WHERE "ProductID" = product_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to send a direct message
CREATE OR REPLACE FUNCTION send_direct_message(sender_id INT, receiver_id INT, message_content TEXT)
RETURNS void AS $$
BEGIN
    -- Check if the user is logged in
    IF NOT is_user_logged_in(user_id) THEN
        RAISE EXCEPTION 'User must be logged in to perform this action.';
    END IF;

    INSERT INTO "Messages" ("SenderID", "ReceiverID", "Content", "Timestamp", "ReadStatus")
    VALUES (sender_id, receiver_id, message_content, CURRENT_TIMESTAMP, 'Unread');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_direct_messages(user1_id INT, user2_id INT)
RETURNS TABLE(
    MessageID INT,
    SenderID INT,
    ReceiverID INT,
    Content TEXT,
    MessageTimestamp TIMESTAMP
) AS $$
BEGIN
    -- Check if the user is logged in
    IF NOT is_user_logged_in(user1_id) OR is_user_logged_in(user2_id) THEN
        RAISE EXCEPTION 'User must be logged in to perform this action.';
    END IF;

    -- Update ReadStatus to 'Read' for all unread messages sent to user1_id by user2_id
    UPDATE "Messages"
    SET "ReadStatus" = 'Read'
    WHERE ("ReceiverID" = user1_id AND "SenderID" = user2_id AND "ReadStatus" = 'Unread')
       OR ("ReceiverID" = user2_id AND "SenderID" = user1_id AND "ReadStatus" = 'Unread');

    -- Return the conversation messages
    RETURN QUERY
    SELECT
        "MessageID",
        "SenderID",
        "ReceiverID",
        "Content",
        "Timestamp"
    FROM
        "Messages"
    WHERE
        ("SenderID" = user1_id AND "ReceiverID" = user2_id) OR
        ("SenderID" = user2_id AND "ReceiverID" = user1_id)
    ORDER BY
        "Timestamp";
END;
$$ LANGUAGE plpgsql;

-- Function to get the user's inbox
CREATE OR REPLACE FUNCTION user_inbox(user_id INT)
RETURNS TABLE(
    CorrespondentID INT,
    LastMessageContent TEXT,
    LastMessageReadStatus VARCHAR
) AS $$
BEGIN
    -- Check if the user is logged in
    IF NOT is_user_logged_in(user_id) THEN
        RAISE EXCEPTION 'User must be logged in to perform this action.';
    END IF;
    RETURN QUERY
    WITH LastMessages AS (
        SELECT
            "MessageID",
            "SenderID",
            "ReceiverID",
            "Content",
            "ReadStatus",
            "Timestamp",
            ROW_NUMBER() OVER (PARTITION BY LEAST("SenderID", "ReceiverID"), GREATEST("SenderID", "ReceiverID") ORDER BY "Timestamp" DESC) AS rn
        FROM
            "Messages"
        WHERE
            "SenderID" = user_id OR "ReceiverID" = user_id
    )
    SELECT
        CASE
            WHEN lm."SenderID" = user_id THEN lm."ReceiverID"
            ELSE lm."SenderID"
        END AS CorrespondentID,
        lm."Content" AS LastMessageContent,
        lm."ReadStatus" AS LastMessageReadStatus
    FROM
        LastMessages lm
    WHERE
        lm.rn = 1;
END;
$$ LANGUAGE plpgsql;

-- Function to get the membership status of a customer
CREATE OR REPLACE FUNCTION get_membership_status(customer_id INT)
RETURNS TABLE(
    MembershipStatus VARCHAR,
    MembershipType VARCHAR,
    StartDate DATE,
    EndDate DATE
) AS $$
DECLARE
    user_id INT;
BEGIN
    -- Retrieve the UserID for the given CustomerID
    SELECT "UserID" INTO user_id FROM "Customers" WHERE "CustomerID" = customer_id;

    -- Check if the user is logged in
    IF NOT is_user_logged_in(user_id) THEN
        RAISE EXCEPTION 'User must be logged in to perform this action.';
    END IF;
    RETURN QUERY 
    SELECT 
        m."Status",
        m."Type",
        m."StartDate",
        m."EndDate"
    FROM 
        "Memberships" m
    WHERE 
        m."CustomerID" = customer_id
    ORDER BY 
        m."StartDate" DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to get the classes taught by an instructor
CREATE OR REPLACE FUNCTION get_classes_taught_by_instructor(instructor_id INT)
RETURNS TABLE(
    ClassID INT,
    ClassName VARCHAR,
    ClassDescription TEXT,
    ClassType VARCHAR,
    Duration INT,
    DifficultyLevel VARCHAR,
    BranchID INT,
    DateTime TIMESTAMP,
    MaxParticipants INT
) AS $$
DECLARE
    user_id INT;
BEGIN
    -- Retrieve the UserID for the given CustomerID
    SELECT "UserID" INTO user_id FROM "Customers" WHERE "CustomerID" = customer_id;

    -- Check if the user is logged in
    IF NOT is_user_logged_in(user_id) THEN
        RAISE EXCEPTION 'User must be logged in to perform this action.';
    END IF;
    RETURN QUERY
    SELECT
        "ClassID",
        "ClassName",
        "ClassDescription",
        "ClassType",
        "Duration",
        "DifficultyLevel",
        "BranchID",
        "DateTime",
        "MaxParticipants"
    FROM
        "Classes"
    WHERE
        "InstructorID" = instructor_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get the classes in a branch
CREATE OR REPLACE FUNCTION get_classes_in_branch(branch_id INT)
RETURNS TABLE(
    ClassID INT,
    ClassName VARCHAR,
    ClassDescription TEXT,
    ClassType VARCHAR,
    InstructorID INT,
    Duration INT,
    DifficultyLevel VARCHAR,
    DateTime TIMESTAMP,
    MaxParticipants INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        "ClassID",
        "ClassName",
        "ClassDescription",
        "ClassType",
        "InstructorID",
        "Duration",
        "DifficultyLevel",
        "DateTime",
        "MaxParticipants"
    FROM
        "Classes"
    WHERE
        "BranchID" = branch_id;
END;
$$ LANGUAGE plpgsql;

-- Function to login a user
CREATE OR REPLACE FUNCTION user_login(username VARCHAR, password VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    found_user_id INT;
    current_login_status BOOLEAN;
BEGIN
    SELECT "UserID", "LoginStatus" INTO found_user_id, current_login_status
    FROM "UserAuthentication"
    WHERE "Username" = username AND "Password" = password;

    IF found_user_id IS NOT NULL THEN
        IF current_login_status = FALSE THEN
            UPDATE "UserAuthentication"
            SET "LoginStatus" = TRUE
            WHERE "UserID" = found_user_id;
            RETURN TRUE;
        ELSE
            RAISE EXCEPTION 'User (%s) is already logged in.', username;
            RETURN FALSE;
        END IF;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to logout a user
CREATE OR REPLACE FUNCTION user_logout(user_identifier TEXT)
RETURNS VOID AS $$
DECLARE
    is_numeric BOOLEAN;
    current_login_status BOOLEAN;
BEGIN
    -- Check if the user_identifier is numeric
    is_numeric := user_identifier ~ '^\d+$';

    IF is_numeric THEN
        -- Logout using UserID
        SELECT "LoginStatus" INTO current_login_status
        FROM "UserAuthentication"
        WHERE "UserID" = user_identifier::INT;

        IF current_login_status = TRUE THEN
            UPDATE "UserAuthentication"
            SET "LoginStatus" = FALSE
            WHERE "UserID" = user_identifier::INT;
        ELSE
            RAISE EXCEPTION 'User with ID % is already logged out.', user_identifier;
        END IF;
    ELSE
        -- Logout using Username
        SELECT "LoginStatus" INTO current_login_status
        FROM "UserAuthentication"
        WHERE "Username" = user_identifier;

        IF current_login_status = TRUE THEN
            UPDATE "UserAuthentication"
            SET "LoginStatus" = FALSE
            WHERE "Username" = user_identifier;
        ELSE
            RAISE EXCEPTION 'User (%s) is already logged out.', user_identifier;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to check if a user is logged in
CREATE OR REPLACE FUNCTION is_user_logged_in(user_id INT)
RETURNS BOOLEAN AS $$
DECLARE
    login_status BOOLEAN;
BEGIN
    SELECT "LoginStatus" INTO login_status
    FROM "UserAuthentication"
    WHERE "UserID" = user_id;

    RETURN COALESCE(login_status, FALSE);
END;
$$ LANGUAGE plpgsql;

-- Function to cancel a class booking
CREATE OR REPLACE FUNCTION cancel_class_booking(customer_id INTEGER, class_id INTEGER)
RETURNS VOID AS $$
DECLARE
    user_id INT;
    booking_id INT;
    booking_exists INT;
BEGIN
    SELECT "UserID" INTO user_id FROM "Customers" WHERE "CustomerID" = customer_id;

    IF NOT is_user_logged_in(user_id) THEN
        RAISE EXCEPTION 'User must be logged in to perform this action.';
    END IF;

    SELECT "BookingID", COUNT(*) INTO booking_id, booking_exists
    FROM "Bookings"
    WHERE "CustomerID" = customer_id AND "ClassID" = class_id
    GROUP BY "BookingID";

    IF booking_exists > 0 THEN
        -- Delete any related notifications
        DELETE FROM "Notifications" WHERE "BookingID" = booking_id;

        -- Delete the booking
        DELETE FROM "Bookings" WHERE "CustomerID" = customer_id AND "ClassID" = class_id;
    ELSE
        RAISE EXCEPTION 'No booking found for the given customer and class.';
    END IF;
END;
$$ LANGUAGE plpgsql;



















#___________________________________________________________________________________________________________________________





