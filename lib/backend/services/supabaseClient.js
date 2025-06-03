const { createClient } = require('@supabase/supabase-js');

require('dotenv').config({ path: './lib/backend/.env' }); // Para cuando se inicia automaticamente

//require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY; // Usa la clave service_role para operaciones de backend

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = supabase;

