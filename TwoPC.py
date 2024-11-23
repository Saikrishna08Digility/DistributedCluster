from cassandra.cluster import Cluster
from cassandra.query import SimpleStatement, ConsistencyLevel
import uuid

# Custom exceptions
class UpdateFailedException(Exception):
    pass

class InsertFailedException(Exception):
    pass

# Connect to the Cassandra cluster
cluster = Cluster(['127.0.0.1'], port=9042, initial_host_lookup=False)
session = cluster.connect()

# Set the keyspaces and prepare queries
session.execute("USE inventory")
update_item_quantity = session.prepare("UPDATE items SET quantity = ? WHERE item_id = ?")

session.execute("USE sales")
insert_order = session.prepare("INSERT INTO orders (order_id, customer_id, item_id, quantity, status) VALUES (?, ?, ?, ?, ?)")
update_order_status = session.prepare("UPDATE orders SET status = ? WHERE order_id = ?")

def prepare_phase(session, item_id, quantity, order_id, customer_id):
    try:
        # Read the current quantity
        current_quantity_query = SimpleStatement(
            "SELECT quantity FROM items WHERE item_id = %s",
            consistency_level=ConsistencyLevel.QUORUM
        )
        current_quantity_result = session.execute(current_quantity_query, (item_id,))
        current_quantity = current_quantity_result.one().quantity
        
        # Calculate the new quantity
        new_quantity = current_quantity - quantity
        
        # Update item quantity
        session.execute(update_item_quantity, (new_quantity, item_id))
    except Exception as e:
        print("Update phase failed:", e)
        raise UpdateFailedException("Update operation failed")

    try:
        # Insert order
        session.execute(insert_order, (order_id, customer_id, item_id, quantity, 'Pending'))
    except Exception as e:
        print("Insert phase failed:", e)
        raise InsertFailedException("Insert operation failed")
    
    print("Prepare phase successful, transaction prepared for commit.")
    return True

def commit_phase(session, order_id):
    try:
        # Update the order status to 'Success'
        session.execute(update_order_status, ('Success', order_id))
        print("Commit phase successful. Transaction committed.")
    except Exception as e:
        print("Commit phase failed:", e)

def rollback_phase(session, item_id, original_quantity, order_id):
    try:
        # Rollback the item quantity to its original value
        session.execute(update_item_quantity, (original_quantity, item_id))
        
        # Delete the order if it was inserted
        session.execute("DELETE FROM orders WHERE order_id = %s", (order_id,))
        
        print("Transaction aborted. Rollback successful.")
    except Exception as e:
        print("Rollback phase failed:", e)

# Simulating a transaction
item_id = uuid.UUID("a658becc-18fe-4246-be71-852b7113e5a3")
order_id = uuid.uuid4()
customer_id = 456
quantity = 1

# Phase 1: Prepare
try:
    if prepare_phase(session, item_id, quantity, order_id, customer_id):
        # Phase 2: Commit if prepare was successful
        commit_phase(session, order_id)
except UpdateFailedException:
    print("Update operation failed, no rollback needed.")
except InsertFailedException:
    print("Insert operation failed, rolling back update.")
    rollback_phase(session, item_id, quantity, order_id)

# Close the session and cluster connection
session.shutdown()
cluster.shutdown()