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


#___________________________________________________________________________________________________________________________

-- Trigger Function to update 'StockQuantity' in 'SalesAndProducts'
CREATE OR REPLACE FUNCTION update_stock_after_sale()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE "SalesAndProducts"
  SET "StockQuantity" = "StockQuantity" - NEW."SoldQuantity"
  WHERE "ProductID" = NEW."ProductID";
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update 'StockQuantity' after a sale (Assuming 'SoldQuantity' is a column in 'SalesAndProducts')
CREATE TRIGGER trigger_update_stock
AFTER INSERT ON "SalesAndProducts"
FOR EACH ROW
EXECUTE FUNCTION update_stock_after_sale();

-- Trigger Function to update 'LastPaymentDate' in 'Memberships'
CREATE OR REPLACE FUNCTION update_last_payment_date()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE "Memberships"
  SET "LastPaymentDate" = NEW."PaymentDate"
  WHERE "MembershipID" = NEW."MembershipID";
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update 'LastPaymentDate' after a payment transaction
CREATE TRIGGER trigger_update_last_payment
AFTER INSERT ON "PaymentTransactions"
FOR EACH ROW
EXECUTE FUNCTION update_last_payment_date();



