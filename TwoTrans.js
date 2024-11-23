const cassandra = require('cassandra-driver');

// Connect to Cassandra
const client = new cassandra.Client({
    contactPoints: ['127.0.0.1'],
    localDataCenter: 'dc1',
});

const consistencyLevels = {
    [cassandra.types.consistencies.one]: 'ONE',
    [cassandra.types.consistencies.quorum]: 'QUORUM',
    [cassandra.types.consistencies.all]: 'ALL'
};

// Update stock count with different consistency levels
async function updateStock(itemId, decrement, consistency) {
    // Step 1: Read the current quantity from the table
    const readQuery = 'SELECT quantity FROM inventory.items WHERE item_id = ?';
    let currentQuantity;

    try {
        const result = await client.execute(readQuery, [itemId], { prepare: true, consistency });
        currentQuantity = result.first().quantity;
        console.log(`Current Item Quantity: ${currentQuantity} with ${consistencyLevels[consistency]} consistency`);
    } catch (err) {
        console.error(`Failed to read current quantity with ${consistencyLevels[consistency]} consistency:`, err);
        return;
    }

    // Step 2: Calculate the new quantity
    const newQuantity = currentQuantity - decrement;

    // Step 3: Update the quantity in the table
    const updateQuery = 'UPDATE inventory.items SET quantity = ? WHERE item_id = ?';
    try {
        await client.execute(updateQuery, [newQuantity, itemId], { prepare: true, consistency });
        console.log(`Item Quantity Updated to ${newQuantity} with ${consistencyLevels[consistency]} consistency`);
    } catch (err) {
        console.error(`Failed to update stock with ${consistencyLevels[consistency]} consistency:`, err);
    }
}

// Insert order with different consistency levels
async function insertOrder(customerId, itemId, quantity, consistency) {
    const query = 'INSERT INTO sales.orders (order_id, customer_id, item_id, quantity, status) VALUES (?, ?, ?, ?, ?)';
    const orderId = cassandra.types.Uuid.random();  // Generate a UUID using Cassandra driver
    try {
        await client.execute(query, [orderId, customerId, itemId.toString(), quantity, 'PENDING'], { prepare: true, consistency });
        //console.log(`Order inserted with ${consistencyLevels[consistency]} consistency`);
    } catch (err) {
        console.error(`Failed to insert order with ${consistencyLevels[consistency]} consistency:`, err);
    }
}

async function simulateConcurrentTransactions() {
    const itemId = cassandra.types.Uuid.fromString('a658becc-18fe-4246-be71-852b7113e5a3');  
    const customerId =123;
    const orderQuantity =1;

    await client.connect();
    console.log('Connected to Cassandra');

    // Simulating concurrent transactions with different consistency levels
    await Promise.all([
        updateStock(itemId, orderQuantity, cassandra.types.consistencies.all),
        insertOrder(customerId, itemId, orderQuantity, cassandra.types.consistencies.all),

        updateStock(itemId, orderQuantity, cassandra.types.consistencies.all),
        insertOrder(customerId, itemId, orderQuantity, cassandra.types.consistencies.all),
    ]);
}

simulateConcurrentTransactions()
    .then(() => console.log('Concurrent transaction simulation completed'))
    .catch(err => console.error('Simulation error:', err))
    .finally(() => client.shutdown());
