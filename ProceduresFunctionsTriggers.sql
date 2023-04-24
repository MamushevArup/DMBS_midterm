--! Procedure which does group by information  !--
CREATE OR REPLACE procedure get_product_category_summary1()AS $$
DECLARE
    c RECORD;
BEGIN
    FOR c IN (SELECT category.brand, COUNT(*) AS ProductCount, SUM(quantity) AS TotalQuantity, AVG(price) AS AveragePrice 
			  FROM product 
			  JOIN category ON product.category_id = category.category_id 
			  GROUP BY category.brand) 
		LOOP
        RAISE NOTICE '%: % products, % total quantity, average price: %', c.brand, c.ProductCount, c.TotalQuantity, c.AveragePrice;
    END LOOP;

END;
$$ LANGUAGE plpgsql;
call get_product_category_summary1();








--! Function which counts the number of records  !--
CREATE OR REPLACE FUNCTION count_records(table_name text)
RETURNS integer AS $$
DECLARE
    record_count integer;
BEGIN
    EXECUTE 'SELECT COUNT(*) FROM ' || table_name INTO record_count;
    RETURN record_count;
END;
$$ LANGUAGE plpgsql;

SELECT count_records('supplier');




--! Procedure which uses SQL%ROWCOUNT to determine the number of rows affected !--
CREATE OR REPLACE PROCEDURE update_table(p_product_id IN integer, p_new_price IN integer)
LANGUAGE plpgsql
AS $$
DECLARE
    rows_affected integer;
BEGIN
    UPDATE employee SET salary = p_new_price WHERE employee_id = p_product_id;
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    RAISE NOTICE 'Number of rows affected: %', rows_affected;
END;
$$;

call update_table(3,145000);


--! Add user-defined exception which disallows to enter title of item (e.g. book) to be less than 5 characters !--
CREATE OR REPLACE FUNCTION add_product(IN product_title VARCHAR(100), IN product_price NUMERIC) RETURNS INTEGER AS $$
DECLARE
    product_id23 INTEGER;
BEGIN
    IF LENGTH(product_title) < 5 THEN
        RAISE EXCEPTION 'Product title should be at least 5 characters long.';
    END IF;

    INSERT INTO product(product_name, price) VALUES (product_title, product_price) RETURNING product_id INTO product_id23;
    RAISE NOTICE 'Product with ID % has been added.', product_id23;
	return product_id23;
END;
$$ LANGUAGE plpgsql;

SELECT add_product('Mini', 10.99);




--! Create a trigger before insert on any entity which will show the current number of rows in the table !--
CREATE OR REPLACE FUNCTION show_row_count()
RETURNS TRIGGER AS $$
DECLARE
  row_count INTEGER;
BEGIN
  SELECT count(*) INTO row_count FROM customer;
  RAISE NOTICE 'Current row count: %', row_count;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_my_table
BEFORE INSERT ON customer
FOR EACH ROW
EXECUTE FUNCTION show_row_count();

insert into customer(first_name, last_name) values ('Jordan', 'Peterson')


