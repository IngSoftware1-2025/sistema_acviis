const express = require('express');
const router = express.Router();
const createProveedor = require('../controllers/proveedores/create_proveedor');

router.post('/', createProveedor);

module.exports = router;