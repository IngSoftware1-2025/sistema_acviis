const express = require('express');
const router = express.Router();
const supabase = require('../services/supabaseClient');

// GET /auth/protected-route
router.get('/protected-route', async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: 'No se proporcionó token' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const { data: user, error } = await supabase.auth.getUser(token);
    if (error) {
      return res.status(401).json({ error: 'Token inválido', details: error.message });
    }
    res.json({ message: 'Autenticado', user: user.user });
  } catch (err) {
    res.status(500).json({ error: 'Error interno al autenticar' });
  }
});

module.exports = router;
