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


select * from sensor_data
WHERE sensor_id = 796080f2-65bd-4e63-a96d-878a2cc48388
AND type= 'Pressure';


CREATE TABLE iot.sensor_data_daily (
    date text,
    sensor_id uuid,
    sensor_type text,
    avg_value double,
    min_value double,
    max_value double,
    PRIMARY KEY ((date), sensor_id, sensor_type)
) WITH CLUSTERING ORDER BY (sensor_id ASC, sensor_type ASC);

select * from iot.sensor_data_daily;


CREATE TABLE anomaly_detection (
    sensor_id UUID,
    timestamp TIMESTAMP,
    type TEXT, 
    value DOUBLE,
    anomaly_type TEXT,
    PRIMARY KEY ((sensor_id, type), timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);




select * from anomaly_detection;

CREATE INDEX ON sensor_data(location);


CREATE KEYSPACE iot WITH replication = {'class': 'NetworkTopologyStrategy', 'dc2': '1', 'dc1': '2'}  AND durable_writes = true;

CREATE TABLE iot.aggregated_data (
    sensor_id uuid,
    parameter text,
    date date,
    avg_value double,
    max_value double,
    min_value double,
    PRIMARY KEY ((sensor_id, parameter), date)
) WITH CLUSTERING ORDER BY (date ASC);



CREATE TABLE iot.anomaly_detection (
    sensor_id uuid,
    type text,
    timestamp timestamp,
    anomaly_type text,
    value double,
    PRIMARY KEY ((sensor_id, type), timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);


CREATE TABLE iot.sensor_data (
    sensor_id uuid,
    type text,
    event_time timestamp,
    location text,
    value double,
    PRIMARY KEY ((sensor_id, type), event_time)
) WITH CLUSTERING ORDER BY (event_time DESC);

CREATE INDEX ON sensor_data(location);

CREATE MATERIALIZED VIEW iot.sensor_data_by_location AS
    SELECT *
    FROM iot.sensor_data
    WHERE location IS NOT NULL AND sensor_id IS NOT NULL AND type IS NOT NULL AND event_time IS NOT NULL
    PRIMARY KEY (location, sensor_id, type, event_time)
 WITH CLUSTERING ORDER BY (sensor_id ASC, type ASC, event_time DESC);


 CREATE TABLE iot.sensor_data_daily (
    date text,
    sensor_id uuid,
    sensor_type text,
    avg_value double,
    min_value double,
    PRIMARY KEY (date, sensor_id, sensor_type)
) WITH CLUSTERING ORDER BY (sensor_id ASC, sensor_type ASC);


