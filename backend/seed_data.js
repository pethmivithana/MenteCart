const mongoose = require('mongoose');
require('dotenv').config();

const MONGODB_URI =
  process.env.MONGODB_URI ||
  'mongodb+srv://pethmi9:pethmi09@cluster0.furwrbi.mongodb.net/MenteCart';

const serviceSchema = new mongoose.Schema({
  title: String,
  description: String,
  category: String,
  price: Number,
  duration: Number,
  image: String,
  capacityPerSlot: Number,
  isActive: Boolean,
  rating: Number,
  reviewCount: Number,
  availableSlots: [
    {
      date: String,
      startTime: String,
      time: String,
      capacity: Number,
      bookedCount: Number,
      remainingCapacity: Number,
    },
  ],
  createdAt: Date,
  updatedAt: Date,
});

const Service = mongoose.model('Service', serviceSchema);

// ✅ Generate dates starting from May 20, 2026
const generateDates = () => {
  const dates = [];
  const start = new Date('2026-05-20');

  for (let i = 0; i < 10; i++) {
    const d = new Date(start);
    d.setDate(start.getDate() + i);
    dates.push(d.toISOString().split('T')[0]);
  }

  return dates;
};

const upcomingDates = generateDates();

// ✅ Common time slots (morning, noon, evening)
const timeSlots = ['08:00', '09:30', '11:00', '14:00', '16:00', '18:00'];

const createSlots = (dates, capacity) => {
  const slots = [];

  dates.forEach((date, i) => {
    timeSlots.forEach((time, j) => {
      // spread slots across days (not too repetitive)
      if ((i + j) % 2 === 0) {
        slots.push({
          date,
          time,
          startTime: time,
          capacity,
          bookedCount: 0,
          remainingCapacity: capacity,
        });
      }
    });
  });

  return slots.slice(0, 10); // limit per service for balance
};

const seedData = [
  {
    title: 'Furniture Repair & Restoration',
    description: 'Expert restoration of damaged furniture',
    category: 'repair',
    price: 3500,
    duration: 120,
    image: 'https://via.placeholder.com/400x300?text=Furniture+Repair',
    capacityPerSlot: 5,
    rating: 4.5,
    reviewCount: 23,
    isActive: true,
    availableSlots: createSlots(upcomingDates, 5),
  },
  {
    title: 'House Cleaning Service',
    description: 'Professional deep cleaning for your home',
    category: 'cleaning',
    price: 4200,
    duration: 180,
    image: 'https://via.placeholder.com/400x300?text=House+Cleaning',
    capacityPerSlot: 8,
    rating: 4.8,
    reviewCount: 45,
    isActive: true,
    availableSlots: createSlots(upcomingDates, 8),
  },
  {
    title: 'Plumbing Repairs',
    description: 'Quick and reliable plumbing solutions',
    category: 'plumbing',
    price: 3800,
    duration: 90,
    image: 'https://via.placeholder.com/400x300?text=Plumbing+Repair',
    capacityPerSlot: 4,
    rating: 4.6,
    reviewCount: 32,
    isActive: true,
    availableSlots: createSlots(upcomingDates, 4),
  },
  {
    title: 'Electrical Wiring Installation',
    description: 'Safe and professional electrical work',
    category: 'electrical',
    price: 4900,
    duration: 120,
    image: 'https://via.placeholder.com/400x300?text=Electrical+Work',
    capacityPerSlot: 3,
    rating: 4.7,
    reviewCount: 28,
    isActive: true,
    availableSlots: createSlots(upcomingDates, 3),
  },
  {
    title: 'Personal Fitness Coaching',
    description: 'One-on-one fitness training sessions',
    category: 'fitness',
    price: 3000,
    duration: 60,
    image: 'https://via.placeholder.com/400x300?text=Fitness+Coaching',
    capacityPerSlot: 6,
    rating: 4.9,
    reviewCount: 67,
    isActive: true,
    availableSlots: createSlots(upcomingDates, 6),
  },
  {
    title: 'Language Tutoring',
    description: 'Learn English, Spanish, or French',
    category: 'tutoring',
    price: 2500,
    duration: 60,
    image: 'https://via.placeholder.com/400x300?text=Language+Tutoring',
    capacityPerSlot: 10,
    rating: 4.4,
    reviewCount: 56,
    isActive: true,
    availableSlots: createSlots(upcomingDates, 10),
  },
  {
    title: 'Beauty Makeup Session',
    description: 'Professional makeup for events',
    category: 'beauty',
    price: 2800,
    duration: 90,
    image: 'https://via.placeholder.com/400x300?text=Makeup+Session',
    capacityPerSlot: 5,
    rating: 4.7,
    reviewCount: 38,
    isActive: true,
    availableSlots: createSlots(upcomingDates, 5),
  },
  {
    title: 'Appliance Repair Service',
    description: 'Fix your broken appliances quickly',
    category: 'repair',
    price: 4500,
    duration: 75,
    image: 'https://via.placeholder.com/400x300?text=Appliance+Repair',
    capacityPerSlot: 4,
    rating: 4.5,
    reviewCount: 41,
    isActive: true,
    availableSlots: createSlots(upcomingDates, 4),
  },
  {
    title: 'Web Development Consultation',
    description: 'Expert advice on your web projects',
    category: 'other',
    price: 5600,
    duration: 60,
    image: 'https://via.placeholder.com/400x300?text=Web+Development',
    capacityPerSlot: 5,
    rating: 4.8,
    reviewCount: 25,
    isActive: true,
    availableSlots: createSlots(upcomingDates, 5),
  },
  {
    title: 'Car Maintenance Service',
    description: 'Regular checkups and maintenance',
    category: 'repair',
    price: 6000,
    duration: 150,
    image: 'https://via.placeholder.com/400x300?text=Car+Maintenance',
    capacityPerSlot: 3,
    rating: 4.6,
    reviewCount: 51,
    isActive: true,
    availableSlots: createSlots(upcomingDates, 3),
  },
];

// normalize slots
for (const svc of seedData) {
  svc.availableSlots = svc.availableSlots.map((slot) => {
    if (slot.time && !slot.startTime) slot.startTime = slot.time;
    return slot;
  });
}

async function seedDatabase() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    await Service.deleteMany({});
    console.log('Cleared existing services');

    const inserted = await Service.insertMany(seedData);
    console.log(`Inserted ${inserted.length} services`);

    inserted.forEach((s) => {
      console.log(`✓ ${s.title} - LKR ${s.price}`);
    });

    await mongoose.disconnect();
    console.log('Database seeding complete');
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
}

seedDatabase();