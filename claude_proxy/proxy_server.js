const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = 3000;

// Enable CORS for all routes
app.use(cors());
app.use(express.json());

// Proxy endpoint for Claude API
app.post('/api/claude', async (req, res) => {
  try {
    const { apiKey, ...requestBody } = req.body;
    
    const response = await axios.post(
      'https://api.anthropic.com/v1/messages',
      requestBody,
      {
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
      }
    );
    
    res.json(response.data);
  } catch (error) {
    console.error('Proxy error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: error.response?.data || { message: error.message }
    });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Claude API Proxy running on http://localhost:${PORT}`);
  console.log(`📡 Ready to proxy requests to Claude API`);
});
