const WardrobeItem = require('../models/WardrobeItem');

/**
 * GET /api/wardrobe
 * Query: category
 */
exports.listItems = async (req, res) => {
  try {
    const { category } = req.query;
    const filter = { userId: req.user.id };
    if (category && category !== 'All') {
      filter.category = category;
    }

    const items = await WardrobeItem.find(filter).sort({ createdAt: -1 });
    return res.status(200).json({ items });
  } catch (error) {
    console.error('ListWardrobeItems Error:', error);
    return res.status(500).json({ error: 'Failed to fetch wardrobe items.' });
  }
};

/**
 * POST /api/wardrobe
 */
exports.addItem = async (req, res) => {
  try {
    const { name, category } = req.body;

    if (!name || !category) {
      return res.status(400).json({ error: 'name and category are required.' });
    }

    let imageUrl = '';
    if (req.file) {
      if (process.env.REMOVE_BG_API_KEY) {
        try {
          const axios = require('axios');
          const FormData = require('form-data');
          const fs = require('fs');
          const path = require('path');

          const formData = new FormData();
          formData.append('size', 'auto');
          formData.append('image_file', fs.createReadStream(req.file.path), req.file.filename);

          const bgResponse = await axios.post('https://api.remove.bg/v1.0/removebg', formData, {
            headers: {
              ...formData.getHeaders(),
              'X-Api-Key': process.env.REMOVE_BG_API_KEY,
            },
            responseType: 'arraybuffer',
          });

          const processedFileName = `nobg_${Date.now()}_${req.file.filename}.png`;
          const processedFilePath = path.join(__dirname, '..', '..', 'uploads', processedFileName);
          fs.writeFileSync(processedFilePath, bgResponse.data);

          imageUrl = `/uploads/${processedFileName}`;
          // Delete original file to save space
          if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
        } catch (apiErr) {
          console.error('remove.bg API Error:', apiErr.message);
          imageUrl = `/uploads/${req.file.filename}`; // fallback to original
        }
      } else {
        imageUrl = `/uploads/${req.file.filename}`;
      }
    } else if (req.body.imageUrl) {
      imageUrl = req.body.imageUrl;
    }

    if (!imageUrl) {
      return res.status(400).json({ error: 'Image is required (file upload or imageUrl).' });
    }

    const item = await WardrobeItem.create({
      userId: req.user.id,
      name,
      category,
      imageUrl,
    });

    return res.status(201).json({ message: 'Item added', item });
  } catch (error) {
    console.error('AddWardrobeItem Error:', error);
    return res.status(500).json({ error: 'Failed to add wardrobe item.' });
  }
};

/**
 * DELETE /api/wardrobe/:id
 */
exports.deleteItem = async (req, res) => {
  try {
    const item = await WardrobeItem.findOneAndDelete({ _id: req.params.id, userId: req.user.id });
    if (!item) return res.status(404).json({ error: 'Item not found.' });
    return res.status(200).json({ message: 'Item deleted' });
  } catch (error) {
    console.error('DeleteWardrobeItem Error:', error);
    return res.status(500).json({ error: 'Failed to delete wardrobe item.' });
  }
};
