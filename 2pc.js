const cassandra = require('cassandra-driver');

// Create a client instance
const client = new cassandra.Client({
  contactPoints: ['127.0.0.1'], 
  localDataCenter: 'dc1'
});

var currentQuantityglobal =0;

async function preparePhase(client, item_id, quantity, order_id, customer_id) {
  try {
    // Read the current quantity
    const currentQuantityQuery = 'SELECT quantity FROM inventory.items WHERE item_id = ?';
    const currentQuantityResult = await client.execute(currentQuantityQuery, [item_id], { prepare: true, consistency: cassandra.types.consistencies.quorum });
    const currentQuantity = currentQuantityResult.first().quantity;
    currentQuantityglobal=currentQuantity;
    // Calculate the new quantity
    const newQuantity = currentQuantity - quantity;
    // Update item quantity
    const updateItemQuantity = 'UPDATE inventory.items SET quantity = ? WHERE item_id = ?';
    await client.execute(updateItemQuantity, [newQuantity, item_id], { prepare: true });

  } catch (e) {
    console.error('Update phase failed:', e);
    return false;
  }
  try {
    // Convert item_id to UUID
    const item_id_uuid = cassandra.types.Uuid.fromString(item_id);
    // Insert order
    const insertOrder = 'INSERT INTO sales.orders (order_id, customer_id, item_id, quantity, status) VALUES (?, ?, ?, ?, ?)';
    await client.execute(insertOrder, [order_id, customer_id, item_id_uuid.toString(), quantity, 'Pending'], { prepare: true });
  } catch (e) {
    console.error('Insert phase failed:', e);
    return false;
  }

  console.log('Prepare phase successful, transaction prepared for commit.');
  return true;
}

async function commitPhase(client, order_id) {
  try {
    // Update the order status to 'Success'
    const updateOrderStatus = 'UPDATE sales.orders SET status = ? WHERE order_id = ?';
    await client.execute(updateOrderStatus, ['Success', order_id], { prepare: true });
    console.log('Commit phase successful. Transaction committed.');
  } catch (e) {
    console.error('Commit phase failed:', e);
  }
}

async function rollbackPhaseItem(client, item_id, original_quantity) {
  try {
    // Rollback the item quantity to its original value
    const rollbackUpdateQuantity = 'UPDATE inventory.items SET quantity = ? WHERE item_id = ?';
    await client.execute(rollbackUpdateQuantity, [original_quantity, item_id], { prepare: true });
    console.log('Transaction aborted. Rollback successful.');
  } catch (e) {
    console.error('Rollback phase failed:', e);
  }
}

async function rollbackPhaseOrder(client, order_id) {
  try {
    // Rollback the order insertion
    const rollbackInsertOrder = 'DELETE FROM sales.orders WHERE order_id = ?';
    await client.execute(rollbackInsertOrder, [order_id], { prepare: true });
    console.log('Transaction aborted. Rollback successful.');
  } catch (e) {
    console.error('Rollback phase failed:', e);
  }
}

async function run() {
  try {
    // Connect to the cluster
    await client.connect();
    console.log('Connected to Cassandra');

    // Simulating a transaction
    const item_id = 'a658becc-18fe-4246-be71-852b7113e5a3';
    const order_id = cassandra.types.Uuid.random(); // Use cassandra.types.Uuid.random() instead of uuid.v4()
    const customer_id = 456;
    const quantity = 1;

    // Phase 1: Prepare
    if (await preparePhase(client, item_id, quantity, order_id, customer_id)) {
      // Phase 2: Commit if prepare was successful
      await commitPhase(client, order_id);
    } else {
      // Rollback if prepare phase failed
      await rollbackPhaseItem(client, item_id, currentQuantityglobal);
      await rollbackPhaseOrder(client, order_id);
    }

  } finally {
    // Close the client connection
    await client.shutdown();
    console.log('Connection closed');
  }
}

run();