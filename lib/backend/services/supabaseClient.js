const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: './lib/backend/.env' });

const entorno = process.env.ENTORNO;
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

let supabase = null;

// Solo crea el cliente si no estás en LOCAL y las claves existen
if (entorno !== 'LOCAL' && supabaseUrl && supabaseKey) {
  supabase = createClient(supabaseUrl, supabaseKey);
}

module.exports = supabase;
