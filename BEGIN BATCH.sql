BEGIN BATCH
  INSERT INTO sales.orders (order_id, item_id, quantity, customer_id)
  VALUES (uuid(), a658becc-18fe-4246-be71-852b7113e5a3, 5, 456);

  UPDATE inventory.items
  SET quantity = quantity - 5
  WHERE item_id = a658becc-18fe-4246-be71-852b7113e5a3;
APPLY BATCH;


BEGIN BATCH
  INSERT INTO sales.orders (order_id, item_id, quantity, customer_id)
  VALUES (uuid(), 'a658becc-18fe-4246-be71-852b7113e5a3', 5, 456);

  UPDATE inventory.items
  SET quantity =95
  WHERE item_id = a658becc-18fe-4246-be71-852b7113e5a3;
APPLY BATCH;



CREATE TABLE sales.orders (
    order_id uuid PRIMARY KEY,
    item_id text,
    quantity int,
    customer_id int
);


BEGIN BATCH
  INSERT INTO sales.orders (order_id, item_id, quantity, customer_id)
  VALUES (uuid(), 'a658becc-18fe-4246-be71-852b7113e5a3', 5, 456);

  UPDATE inventory.items
  SET quantity =quantity-5
  WHERE item_id = a658becc-18fe-4246-be71-852b7113e5a3;
APPLY BATCH;

select * from inventory.items;

update inventory.items set item_name='Samsung' where item_id = 'a658becc-18fe-4246-be71-852b7113e5a3';

update inventory.items set quantity=100 where item_id = 'a658becc-18fe-4246-be71-852b7113e5a3';

select * from sales.orders;

BEGIN BATCH
  INSERT INTO sales.orders (order_id, item_id, quantity, customer_id)
  VALUES (uuid(), 'a658becc-18fe-4246-be71-852b7113e5a3', 5, 456);

  UPDATE inventory.items
  SET quantity =85
  WHERE item_id = a658becc-18fe-4246-be71-852b7113e5a3;
APPLY BATCH;


BEGIN BATCH
  INSERT INTO sales.orders (order_id, item_id, quantity, customer_id)
  VALUES (uuid(), 'a658becc-18fe-4246-be71-852b7113e5a3', 5, 456);

  UPDATE inventory.items
  SET quantity =80
  WHERE item_id = a658becc-18fe-4246-be71-852b7113e5a3;
APPLY BATCH;