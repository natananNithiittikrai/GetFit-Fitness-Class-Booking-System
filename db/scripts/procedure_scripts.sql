-- Procedure scripts for the database

-- Procedure to update customer information
CREATE OR REPLACE PROCEDURE update_customer_info(customer_id INT, new_email VARCHAR, new_address TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "Customers"
    SET "Email" = new_email, "Address" = new_address
    WHERE "CustomerID" = customer_id;
END;
$$;

-- Procedure to update booking information
CREATE OR REPLACE PROCEDURE update_class_info(class_id INT, new_class_name VARCHAR, new_description TEXT, new_max_participants INT)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "Classes"
    SET "ClassName" = new_class_name, "ClassDescription" = new_description, "MaxParticipants" = new_max_participants
    WHERE "ClassID" = class_id;
END;
$$;

-- Procedure to update instructor information
CREATE OR REPLACE PROCEDURE update_instructor_info(instructor_id INT, new_specialization VARCHAR, new_rating FLOAT)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "Instructors"
    SET "Specialization" = new_specialization, "Rating" = new_rating
    WHERE "InstructorID" = instructor_id;
END;
$$;
