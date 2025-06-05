// lib/backend/mongoClient.js
const { MongoClient } = require("mongodb");

const uri = "mongodb://localhost:27017"; // Cambia si usas otro puerto
const client = new MongoClient(uri);

let db;

async function connectDB() {
    if (!db) {
        await client.connect();
        db = client.db("sistema_acviis"); // Cambia por el nombre de tu base de datos
    }
    return db;
}

module.exports = { connectDB };
