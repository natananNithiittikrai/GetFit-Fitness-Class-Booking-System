-- Functions / Procedures
#___________________________________________________________________________________________________________________________

-- Function to buy a membership
CREATE OR REPLACE FUNCTION buy_membership(customer_id int, membership_type varchar, price decimal, payment_method varchar)
RETURNS void AS $$
DECLARE
    new_membership_id int;
    new_transaction_id int;
BEGIN
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
CREATE OR REPLACE FUNCTION create_class(instructor_id int, class_name varchar, class_description text, class_type varchar, duration int, difficulty_level varchar, branch_id int, class_datetime timestamp, max_participants int)
RETURNS void AS $$
BEGIN
    INSERT INTO "Classes" ("InstructorID", "ClassName", "ClassDescription", "ClassType", "Duration", "DifficultyLevel", "BranchID", "DateTime", "MaxParticipants")
    VALUES (instructor_id, class_name, class_description, class_type, duration, difficulty_level, branch_id, class_datetime, max_participants);
END;
$$ LANGUAGE plpgsql;

-- Function to book a class
CREATE OR REPLACE FUNCTION book_class(customer_id INT, class_id INT)
RETURNS void AS $$
DECLARE
    membership_status VARCHAR;
    existing_booking_count INT;
BEGIN
    -- Check if the customer has an active membership
    SELECT "Status" INTO membership_status FROM "Memberships" WHERE "CustomerID" = customer_id;

    IF membership_status = 'Active' THEN
        -- Check for existing booking for the same class
        SELECT COUNT(*) INTO existing_booking_count FROM "Bookings"
        WHERE "CustomerID" = customer_id AND "ClassID" = class_id;

        -- If no existing booking, proceed to book the class
        IF existing_booking_count = 0 THEN
            INSERT INTO "Bookings" ("CustomerID", "ClassID", "BookingDateTime", "SessionType")
            VALUES (customer_id, class_id, CURRENT_TIMESTAMP, 'Standard');
        ELSE
            RAISE EXCEPTION 'Customer has already booked this class.';
        END IF;
    ELSE
        RAISE EXCEPTION 'Customer does not have an active membership.';
    END IF;
END;
$$ LANGUAGE plpgsql;

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
    current_stock int;
    new_transaction_id int;
BEGIN
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































#___________________________________________________________________________________________________________________________
# Old Functions / Procedures

-- Function to calculate the average number of participants per class type
CREATE OR REPLACE FUNCTION avg_participants_per_class(class_type VARCHAR)
RETURNS FLOAT AS $$
DECLARE
  avg_participants FLOAT;
BEGIN
  SELECT AVG("MaxParticipants") INTO avg_participants
  FROM "Classes"
  WHERE "ClassType" = class_type;
  RETURN avg_participants;
END;
$$ LANGUAGE plpgsql;

-- Function to validate user login in 'UserAuthentication' table
CREATE OR REPLACE FUNCTION validate_login(username VARCHAR, password VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
  user_exists BOOLEAN;
BEGIN
  SELECT EXISTS(SELECT 1 FROM "UserAuthentication" WHERE "Username" = username AND "Password" = password) INTO user_exists;
  RETURN user_exists;
END;
$$ LANGUAGE plpgsql;

-- Procedure to update instructor details in 'Instructors' table
CREATE OR REPLACE PROCEDURE update_instructor(instructor_id INT, instructor_name VARCHAR, specialization VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE "Instructors"
  SET "InstructorName" = instructor_name, "Specialization" = specialization
  WHERE "InstructorID" = instructor_id;
END;
$$;



