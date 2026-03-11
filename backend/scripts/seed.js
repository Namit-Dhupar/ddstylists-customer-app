/**
 * Seed script — populates MongoDB Atlas with sample data
 * Run: node scripts/seed.js
 */
require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const User = require('../src/models/User');
const Stylist = require('../src/models/Stylist');
const WardrobeItem = require('../src/models/WardrobeItem');
const Appointment = require('../src/models/Appointment');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/ddstylists';

async function seed() {
  console.log('Connecting to MongoDB Atlas...');
  await mongoose.connect(MONGO_URI);
  console.log('✅ Connected');

  // Clear existing data
  await User.deleteMany({});
  await Stylist.deleteMany({});
  await WardrobeItem.deleteMany({});
  await Appointment.deleteMany({});
  console.log('🧹 Cleared existing data');

  // Create test user
  const passwordHash = await bcrypt.hash('demo123', 12);
  const user = await User.create({
    firstName: 'Namit',
    lastName: 'Dhupar',
    username: 'namit_dd',
    email: 'namit@ddstylists.com',
    passwordHash,
    phone: '+44 7700 900000',
    dob: new Date('1995-01-15'),
    stylePreference: 'Both',
    country: 'United Kingdom',
    authProvider: 'Local',
    profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
  });
  console.log(`👤 Created test user: ${user.email} / demo123`);

  // Create stylists
  const stylists = await Stylist.insertMany([
    {
      firstName: 'Amara', lastName: 'Chen',
      email: 'amara@ddstylists.com', passwordHash,
      speciality: ['Wedding', 'Red Carpet'],
      experienceYears: 8, location: 'London',
      bio: 'Award-winning bridal and red carpet stylist with 8+ years of experience dressing celebrities and brides.',
      profileImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      rating: 4.9, reviewCount: 127, sessionCount: 340,
      services: [
        { name: 'Bridal Styling', price: 150, packageType: 'Signature' },
        { name: 'Red Carpet Look', price: 200, packageType: 'Signature' },
        { name: 'Style Consultation', price: 75, packageType: 'Custom' },
      ],
      availability: [
        { dayOfWeek: 'Monday', startTime: '09:00', endTime: '17:00' },
        { dayOfWeek: 'Wednesday', startTime: '10:00', endTime: '18:00' },
        { dayOfWeek: 'Friday', startTime: '09:00', endTime: '15:00' },
      ],
      isApproved: true,
    },
    {
      firstName: 'Priya', lastName: 'Sharma',
      email: 'priya@ddstylists.com', passwordHash,
      speciality: ['Corporate', 'Casual'],
      experienceYears: 6, location: 'Mumbai',
      bio: 'Corporate wardrobe specialist helping professionals look polished and confident in the boardroom.',
      profileImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      rating: 4.8, reviewCount: 89, sessionCount: 210,
      services: [
        { name: 'Corporate Wardrobe', price: 100, packageType: 'Signature' },
        { name: 'Smart Casual Styling', price: 80, packageType: 'Custom' },
        { name: 'Wardrobe Audit', price: 60, packageType: 'Custom' },
      ],
      availability: [
        { dayOfWeek: 'Tuesday', startTime: '10:00', endTime: '18:00' },
        { dayOfWeek: 'Thursday', startTime: '10:00', endTime: '18:00' },
        { dayOfWeek: 'Saturday', startTime: '11:00', endTime: '16:00' },
      ],
      isApproved: true,
    },
    {
      firstName: 'James', lastName: 'Wright',
      email: 'james@ddstylists.com', passwordHash,
      speciality: ['Sustainable', 'Casual'],
      experienceYears: 5, location: 'Manchester',
      bio: 'Eco-conscious stylist specialising in sustainable fashion and thrift styling.',
      profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      rating: 4.7, reviewCount: 56, sessionCount: 140,
      services: [
        { name: 'Sustainable Styling', price: 70, packageType: 'Custom' },
        { name: 'Thrift Shopping Tour', price: 90, packageType: 'Signature' },
        { name: 'Capsule Wardrobe', price: 120, packageType: 'Signature' },
      ],
      availability: [
        { dayOfWeek: 'Monday', startTime: '11:00', endTime: '19:00' },
        { dayOfWeek: 'Wednesday', startTime: '11:00', endTime: '19:00' },
        { dayOfWeek: 'Friday', startTime: '11:00', endTime: '17:00' },
      ],
      isApproved: true,
    },
    {
      firstName: 'Olivia', lastName: 'Brown',
      email: 'olivia@ddstylists.com', passwordHash,
      speciality: ['Wedding', 'Maternity'],
      experienceYears: 10, location: 'London',
      bio: 'Specialist in maternity fashion and bridal wear with a gentle, supportive approach.',
      profileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
      rating: 4.8, reviewCount: 112, sessionCount: 290,
      services: [
        { name: 'Maternity Styling', price: 85, packageType: 'Custom' },
        { name: 'Bridal Consultation', price: 130, packageType: 'Signature' },
        { name: 'Baby Shower Outfit', price: 65, packageType: 'Custom' },
      ],
      availability: [
        { dayOfWeek: 'Tuesday', startTime: '09:00', endTime: '16:00' },
        { dayOfWeek: 'Thursday', startTime: '09:00', endTime: '16:00' },
      ],
      isApproved: true,
    },
    {
      firstName: 'Marcus', lastName: 'Johnson',
      email: 'marcus@ddstylists.com', passwordHash,
      speciality: ['Corporate', 'Red Carpet'],
      experienceYears: 12, location: 'Birmingham',
      bio: 'Executive image consultant for C-suite professionals and public figures.',
      profileImage: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      rating: 4.9, reviewCount: 178, sessionCount: 450,
      services: [
        { name: 'Executive Styling', price: 180, packageType: 'Signature' },
        { name: 'Award Ceremony Look', price: 250, packageType: 'Signature' },
        { name: 'Personal Shopping', price: 150, packageType: 'Custom' },
      ],
      availability: [
        { dayOfWeek: 'Monday', startTime: '08:00', endTime: '17:00' },
        { dayOfWeek: 'Wednesday', startTime: '08:00', endTime: '17:00' },
        { dayOfWeek: 'Friday', startTime: '08:00', endTime: '14:00' },
      ],
      isApproved: true,
    },
    {
      firstName: 'Anya', lastName: 'Patel',
      email: 'anya@ddstylists.com', passwordHash,
      speciality: ['Casual', 'Sustainable'],
      experienceYears: 4, location: 'Delhi',
      bio: 'Young, trendy stylist bringing fresh perspectives to everyday fashion.',
      profileImage: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      rating: 4.6, reviewCount: 43, sessionCount: 95,
      services: [
        { name: 'Everyday Styling', price: 50, packageType: 'Custom' },
        { name: 'Festival Look', price: 70, packageType: 'Custom' },
        { name: 'Wardrobe Refresh', price: 90, packageType: 'Signature' },
      ],
      availability: [
        { dayOfWeek: 'Tuesday', startTime: '12:00', endTime: '20:00' },
        { dayOfWeek: 'Saturday', startTime: '10:00', endTime: '18:00' },
        { dayOfWeek: 'Sunday', startTime: '10:00', endTime: '16:00' },
      ],
      isApproved: true,
    },
    {
      firstName: 'Sophie', lastName: 'Laurent',
      email: 'sophie@ddstylists.com', passwordHash,
      speciality: ['Red Carpet', 'Wedding'],
      experienceYears: 15, location: 'London',
      bio: 'Former Vogue stylist now offering personal styling exclusively through D&D.',
      profileImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
      rating: 5.0, reviewCount: 201, sessionCount: 520,
      services: [
        { name: 'Celebrity Styling', price: 300, packageType: 'Signature' },
        { name: 'Editorial Look', price: 200, packageType: 'Signature' },
        { name: 'VIP Consultation', price: 120, packageType: 'Custom' },
      ],
      availability: [
        { dayOfWeek: 'Monday', startTime: '10:00', endTime: '16:00' },
        { dayOfWeek: 'Thursday', startTime: '10:00', endTime: '16:00' },
      ],
      isApproved: true,
    },
    {
      firstName: 'Raj', lastName: 'Malhotra',
      email: 'raj@ddstylists.com', passwordHash,
      speciality: ['Wedding', 'Corporate'],
      experienceYears: 7, location: 'Bangalore',
      bio: 'Blending traditional Indian aesthetics with modern silhouettes for the contemporary professional.',
      profileImage: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400',
      rating: 4.7, reviewCount: 67, sessionCount: 180,
      services: [
        { name: 'Indian Wedding Styling', price: 120, packageType: 'Signature' },
        { name: 'Indo-Western Fusion', price: 90, packageType: 'Custom' },
        { name: 'Groom Styling', price: 100, packageType: 'Signature' },
      ],
      availability: [
        { dayOfWeek: 'Wednesday', startTime: '10:00', endTime: '18:00' },
        { dayOfWeek: 'Friday', startTime: '10:00', endTime: '18:00' },
        { dayOfWeek: 'Saturday', startTime: '11:00', endTime: '17:00' },
      ],
      isApproved: true,
    },
  ]);
  console.log(`👗 Created ${stylists.length} stylists`);

  // Add favourites
  user.favouriteStylists = [stylists[0]._id, stylists[1]._id];
  await user.save();

  // Create wardrobe items
  const wardrobeItems = await WardrobeItem.insertMany([
    { userId: user._id, name: 'Navy Blazer', category: 'Top Wear', imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=300' },
    { userId: user._id, name: 'White Oxford Shirt', category: 'Top Wear', imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=300' },
    { userId: user._id, name: 'Black Turtleneck', category: 'Top Wear', imageUrl: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=300' },
    { userId: user._id, name: 'Cream Chinos', category: 'Bottom Wear', imageUrl: 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=300' },
    { userId: user._id, name: 'Dark Denim Jeans', category: 'Bottom Wear', imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=300' },
    { userId: user._id, name: 'Tailored Trousers', category: 'Bottom Wear', imageUrl: 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=300' },
    { userId: user._id, name: 'Brown Oxford Shoes', category: 'Footwear', imageUrl: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=300' },
    { userId: user._id, name: 'White Sneakers', category: 'Footwear', imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=300' },
    { userId: user._id, name: 'Navy Suit', category: 'Outfits', imageUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=300' },
    { userId: user._id, name: 'Gold Watch', category: 'Accessories', imageUrl: 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=300' },
  ]);
  console.log(`👔 Created ${wardrobeItems.length} wardrobe items`);

  // Create sample appointments
  const appointments = await Appointment.insertMany([
    {
      customerId: user._id, stylistId: stylists[0]._id,
      date: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), time: '11:00 am',
      status: 'Upcoming', packageType: 'Signature', paymentStatus: 'Completed',
    },
    {
      customerId: user._id, stylistId: stylists[1]._id,
      date: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000), time: '2:00 pm',
      status: 'Completed', packageType: 'Custom', paymentStatus: 'Completed',
    },
    {
      customerId: user._id, stylistId: stylists[2]._id,
      date: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000), time: '10:00 am',
      status: 'Cancelled', packageType: 'Custom', paymentStatus: 'Refunded',
    },
  ]);
  console.log(`📅 Created ${appointments.length} appointments`);

  // Create indexes for performance
  await Stylist.collection.createIndex({ speciality: 1 });
  await Stylist.collection.createIndex({ rating: -1 });
  await Stylist.collection.createIndex({ location: 1 });
  await Stylist.collection.createIndex({ isApproved: 1 });
  await WardrobeItem.collection.createIndex({ userId: 1, category: 1 });
  await Appointment.collection.createIndex({ customerId: 1, status: 1 });
  console.log('📊 Created indexes');

  console.log('\n✅ Seed complete!');
  console.log(`   Test login: namit@ddstylists.com / demo123`);
  console.log(`   ${stylists.length} stylists, ${wardrobeItems.length} wardrobe items, ${appointments.length} appointments`);

  await mongoose.disconnect();
  process.exit(0);
}

seed().catch((err) => {
  console.error('❌ Seed failed:', err);
  process.exit(1);
});
