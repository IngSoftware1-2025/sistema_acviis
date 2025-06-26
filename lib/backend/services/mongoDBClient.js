const { MongoClient } = require('mongodb');
require('dotenv').config({ path: './lib/backend/.env' });

const uri = process.env.mongodbURI;
if (!uri) throw new Error('La variable de entorno mongodbURI no está definida');

const client = new MongoClient(uri);

async function getMongoClient() {
    if (!client.topology || !client.topology.isConnected()) {
        await client.connect();
    }
    return client;
}

module.exports = getMongoClient;