from cassandra.cluster import Cluster
from cassandra.query import SimpleStatement, ConsistencyLevel
import uuid

# Connect to the Cassandra cluster
cluster = Cluster(['127.0.0.1'], port=9042, initial_host_lookup=False)
session = cluster.connect()

# Set the keyspaces and prepare queries
session.execute("USE inventory")
update_item_quantity = session.prepare("UPDATE items SET quantity = ? WHERE item_id = ?")

session.execute("USE sales")
insert_order = session.prepare("INSERT INTO orders (order_id, customer_id, item_id, quantity, status) VALUES (?, ?, ?, ?, ?)")
update_order_status = session.prepare("UPDATE orders SET status = ? WHERE order_id = ?")

# Rollback queries (if needed)
rollback_update_quantity = session.prepare("UPDATE items SET quantity = ? WHERE item_id = ?")
rollback_insert_order = session.prepare("DELETE FROM orders WHERE order_id = ?")

def prepare_phase(session, item_id, quantity, order_id, customer_id):
    try:
        # Read the current quantity
        current_quantity_query = SimpleStatement(
            "SELECT quantity FROM items WHERE item_id = %s",
            consistency_level=ConsistencyLevel.QUORUM
        )
        current_quantity_result = session.execute(current_quantity_query, (item_id,))
        current_quantity = current_quantity_result.one().quantity
    except Exception as e:
        print("Select phase failed:", e)
        return False
    
    try:
        # Calculate the new quantity
        new_quantity = current_quantity - quantity
        
        # Update item quantity
        session.execute(update_item_quantity, (new_quantity, item_id))
    except Exception as e:
        print("Update phase failed:", e)
        return False
    
    try:
        # Insert order
        session.execute(insert_order, (order_id, customer_id, item_id, quantity, 'Pending'))
    except Exception as e:
        print("Insert phase failed:", e)
        return False
    
    print("Prepare phase successful, transaction prepared for commit.")
    return True

def commit_phase(session, order_id):
    try:
        # Update the order status to 'success'
        session.execute(update_order_status, ('Success', order_id))
        print("Commit phase successful. Transaction committed.")
    except Exception as e:
        print("Commit phase failed:", e)

def rollback_phase_Item(session, item_id, original_quantity):
    try:
        # Rollback the item quantity to its original value
        session.execute(update_item_quantity, (original_quantity, item_id))
        print("Transaction aborted. Rollback successful.")
    except Exception as e:
        print("Rollback phase failed:", e)
        
def rollback_phase_Order(session, order_id):
    try:
        # Rollback the order insertion
        session.execute(rollback_insert_order, (order_id,))
        print("Transaction aborted. Rollback successful.")
    except Exception as e:
        print("Rollback phase failed:", e)

# Simulating a transaction
item_id = uuid.UUID("a658becc-18fe-4246-be71-852b7113e5a3")
order_id = uuid.uuid4()
customer_id = 456
quantity = 1

# Phase 1: Prepare
if prepare_phase(session, item_id, quantity, order_id, customer_id):
    # Phase 2: Commit if prepare was successful
    commit_phase(session, order_id)
else:
    # Rollback if prepare phase failed
    rollback_phase_Item(session, item_id, quantity)
    rollback_phase_Order(session, order_id)

# Close the session and cluster connection
session.shutdown()
cluster.shutdown()
