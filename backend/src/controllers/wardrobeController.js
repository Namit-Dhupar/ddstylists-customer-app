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
      imageUrl = `/uploads/${req.file.filename}`;
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
