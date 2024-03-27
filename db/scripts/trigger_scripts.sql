-- Trigger Functions and Triggers

-- Function for updating 'LastActivityDate' in 'Customers' table
CREATE OR REPLACE FUNCTION update_customer_last_activity()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the LastActivityDate in Customers table
    UPDATE "Customers"
    SET "LastActivityDate" = NEW."BookingDateTime"
    WHERE "CustomerID" = NEW."CustomerID";

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update 'LastActivityDate' after a new booking is inserted
CREATE TRIGGER trigger_update_last_activity
AFTER INSERT ON "Bookings"
FOR EACH ROW
EXECUTE FUNCTION update_customer_last_activity();

-- Function for updating 'Stock Quantity' in 'SaleAndProducts' table
CREATE OR REPLACE FUNCTION update_stock_after_purchase()
RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        IF NEW."StockQuantity" < 0 THEN
            RAISE EXCEPTION 'Stock quantity cannot be negative.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_stock_after_purchase
BEFORE UPDATE ON "SalesAndProducts"
FOR EACH ROW EXECUTE FUNCTION update_stock_after_purchase();

-- Function for notifying customers after a product purchase
CREATE OR REPLACE FUNCTION notify_product_purchase()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO "Notifications" ("NotificationType", "Status", "NotificationDateTime", "Content", "CustomerID")
    VALUES ('Purchase', 'New', CURRENT_TIMESTAMP, 'Thank you for your purchase.', NEW."CustomerID");
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_product_purchase
AFTER INSERT ON "PaymentTransactions"
FOR EACH ROW
WHEN (NEW."TransactionType" = 'Product Purchase')
EXECUTE FUNCTION notify_product_purchase();

-- Function for notifying customers after a class booking
CREATE OR REPLACE FUNCTION notify_class_booking()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO "Notifications" ("NotificationType", "Status", "NotificationDateTime", "Content", "CustomerID", "BookingID")
    VALUES (
        'Booking', 
        'New', 
        CURRENT_TIMESTAMP, 
        'You have just booked class #' || NEW."ClassID" || '. Your class has been successfully booked.', 
        NEW."CustomerID", 
        NEW."BookingID"
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_class_booking
AFTER INSERT ON "Bookings"
FOR EACH ROW
EXECUTE FUNCTION notify_class_booking();

-- Function for handling membership renewals
CREATE OR REPLACE FUNCTION membership_renewal_trigger()
RETURNS TRIGGER AS $$
DECLARE
    new_payment_date DATE;
BEGIN
    IF NEW."EndDate" > OLD."EndDate" AND NEW."RenewalStatus" = 'True' THEN
        -- Assuming a 1-year renewal period
        new_payment_date := CURRENT_DATE + INTERVAL '1 year';

        -- Update NextPaymentDate and EndDate in Memberships table
        NEW."NextPaymentDate" := new_payment_date;
        NEW."EndDate" := NEW."EndDate" + INTERVAL '1 year';

        -- Insert a new record into PaymentTransactions table
        INSERT INTO "PaymentTransactions" (
            "CustomerID",
            "TransactionType",
            "Amount",
            "PaymentDate",
            "Status"
        )
        VALUES (
            NEW."CustomerID",
            'Membership Renewal',
            NEW."Price",
            CURRENT_DATE,
            'Completed'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_membership_renewal
AFTER UPDATE ON "Memberships"
FOR EACH ROW
EXECUTE FUNCTION membership_renewal_trigger();

#___________________________________________________________________________________________________________________________



