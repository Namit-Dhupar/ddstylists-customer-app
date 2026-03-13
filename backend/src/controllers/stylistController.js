const Stylist = require('../models/Stylist');
const Review = require('../models/Review');

/**
 * GET /api/stylists
 * Query params: category, location, minRating, minPrice, maxPrice, sortBy, page, limit
 */
exports.listStylists = async (req, res) => {
  try {
    const { category, location, minRating, minPrice, maxPrice, sortBy, search, page = 1, limit = 20 } = req.query;

    const filter = { isApproved: true };

    if (category && category !== 'All') {
      filter.speciality = { $in: [category] };
    }
    if (search) {
      const searchRegex = { $regex: search, $options: 'i' };
      filter.$or = [
        { firstName: searchRegex },
        { lastName: searchRegex },
        { speciality: searchRegex },
      ];
    }
    if (location) {
      filter.location = { $regex: location, $options: 'i' };
    }
    if (minRating) {
      filter.rating = { $gte: parseFloat(minRating) };
    }
    if (minPrice || maxPrice) {
      filter['services.price'] = {};
      if (minPrice) filter['services.price'].$gte = parseFloat(minPrice);
      if (maxPrice) filter['services.price'].$lte = parseFloat(maxPrice);
    }

    let sortOption = {};
    switch (sortBy) {
      case 'rating': sortOption = { rating: -1 }; break;
      case 'price_low': sortOption = { 'services.0.price': 1 }; break;
      case 'price_high': sortOption = { 'services.0.price': -1 }; break;
      case 'experience': sortOption = { experienceYears: -1 }; break;
      default: sortOption = { rating: -1 };
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const stylists = await Stylist.find(filter)
      .sort(sortOption)
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Stylist.countDocuments(filter);

    return res.status(200).json({
      stylists,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit)),
      },
    });
  } catch (error) {
    console.error('ListStylists Error:', error);
    return res.status(500).json({ error: 'Failed to fetch stylists.' });
  }
};

/**
 * GET /api/stylists/:id
 */
exports.getStylist = async (req, res) => {
  try {
    const stylist = await Stylist.findById(req.params.id);
    if (!stylist) return res.status(404).json({ error: 'Stylist not found.' });
    return res.status(200).json({ stylist });
  } catch (error) {
    console.error('GetStylist Error:', error);
    return res.status(500).json({ error: 'Failed to fetch stylist.' });
  }
};

/**
 * GET /api/stylists/:id/reviews
 */
exports.getReviews = async (req, res) => {
  try {
    const reviews = await Review.find({ stylistId: req.params.id })
      .populate('customerId', 'firstName lastName profileImage')
      .sort({ createdAt: -1 })
      .limit(20);
    return res.status(200).json({ reviews });
  } catch (error) {
    console.error('GetReviews Error:', error);
    return res.status(500).json({ error: 'Failed to fetch reviews.' });
  }
};

/**
 * POST /api/stylists/:id/reviews
 */
exports.addReview = async (req, res) => {
  try {
    const { rating, reviewText } = req.body;
    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ error: 'Rating must be between 1 and 5.' });
    }

    const review = await Review.create({
      customerId: req.user.id,
      stylistId: req.params.id,
      rating,
      reviewText: reviewText || '',
    });

    // Update stylist average rating
    const allReviews = await Review.find({ stylistId: req.params.id });
    const avgRating = allReviews.reduce((sum, r) => sum + r.rating, 0) / allReviews.length;
    await Stylist.findByIdAndUpdate(req.params.id, {
      rating: Math.round(avgRating * 10) / 10,
      reviewCount: allReviews.length,
    });

    return res.status(201).json({ message: 'Review added', review });
  } catch (error) {
    console.error('AddReview Error:', error);
    return res.status(500).json({ error: 'Failed to add review.' });
  }
};

/**
 * GET /api/stylists/categories
 */
exports.getCategories = async (req, res) => {
  try {
    const categories = await Stylist.distinct('speciality');
    return res.status(200).json({ categories: ['All', ...categories] });
  } catch (error) {
    console.error('GetCategories Error:', error);
    return res.status(500).json({ error: 'Failed to fetch categories.' });
  }
};
