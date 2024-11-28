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


CREATE TABLE sensor_data (
    sensor_id UUID,
    timestamp TIMESTAMP,
    parameter TEXT,
    value DOUBLE,
    PRIMARY KEY ((sensor_id, parameter), timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);

insert into iot.sensor_data (sensor_id, timestamp, parameter, value) values (uuid(), toTimestamp(now()), 'temperature', 25.5);


select * from iot.sensor_data;

CREATE TABLE aggregated_data (
    sensor_id UUID,
    date DATE,
    parameter TEXT,
    avg_value DOUBLE,
    max_value DOUBLE,
    min_value DOUBLE,
    PRIMARY KEY ((sensor_id, parameter), date)
);

select * from iot.aggregated_data;

CREATE TABLE anomaly_detection (
    sensor_id UUID,
    timestamp TIMESTAMP,
    parameter TEXT,
    value DOUBLE,
    anomaly_type TEXT,
    PRIMARY KEY ((sensor_id, parameter), timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);


select * from iot.anomaly_detection;
