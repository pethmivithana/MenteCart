import mongoose from 'mongoose';
import dotenv from 'dotenv';
import { Service, IAvailableSlot } from '../models/Service';

dotenv.config();

const generateFutureSlots = (startDaysFromNow: number = 1): IAvailableSlot[] => {
  const slots: IAvailableSlot[] = [];
  const today = new Date();

  // Generate slots for the next 60 days
  for (let dayOffset = startDaysFromNow; dayOffset < startDaysFromNow + 60; dayOffset++) {
    const date = new Date(today);
    date.setDate(date.getDate() + dayOffset);

    // Skip weekends (0 = Sunday, 6 = Saturday)
    if (date.getDay() === 0 || date.getDay() === 6) {
      continue;
    }

    // Generate 4 slots per day: 09:00, 11:00, 14:00, 16:00
    const times = ['09:00', '11:00', '14:00', '16:00'];
    times.forEach((time) => {
      slots.push({
        date: date.toISOString().split('T')[0], // YYYY-MM-DD format
        time,
        capacity: 5,
        bookedCount: 0,
      });
    });
  }

  return slots;
};

const seedServices = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI;
    if (!mongoUri) {
      throw new Error('MONGODB_URI is not defined in environment variables');
    }

    await mongoose.connect(mongoUri);
    console.log('✓ Connected to MongoDB');

    // Check if services already exist to prevent duplicates
    const existingCount = await Service.countDocuments();
    if (existingCount > 0) {
      console.log(`⚠ Database already has ${existingCount} services. Skipping seed to prevent duplicates.`);
      await mongoose.disconnect();
      return;
    }

    const services = [
      // Cleaning Services
      {
        title: 'Home Deep Cleaning',
        description: 'Professional deep cleaning service for your entire home including floors, walls, and furniture. Includes carpet shampooing and upholstery cleaning.',
        category: 'cleaning',
        price: 8500,
        duration: 240,
        image: 'https://images.unsplash.com/photo-1581578731548-c64695c952952?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 4.8,
        reviewCount: 142,
      },
      {
        title: 'Office Cleaning Service',
        description: 'Daily or weekly office cleaning including desks, bathrooms, common areas, and waste management. Perfect for small to medium businesses.',
        category: 'cleaning',
        price: 5500,
        duration: 120,
        image: 'https://images.unsplash.com/photo-1585610556861-f6a9d3fe57cf?w=400&h=300&fit=crop',
        capacityPerSlot: 2,
        rating: 4.6,
        reviewCount: 98,
      },
      {
        title: 'Carpet Cleaning Specialist',
        description: 'Professional carpet and rug cleaning using advanced steam cleaning technology. Removes stubborn stains and allergens.',
        category: 'cleaning',
        price: 3500,
        duration: 90,
        image: 'https://images.unsplash.com/photo-1580274455191-1c62238fa333?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 4.7,
        reviewCount: 87,
      },
      {
        title: 'Window Cleaning Service',
        description: 'Sparkling clean windows for homes and offices. Includes interior and exterior glass cleaning with streak-free finish.',
        category: 'cleaning',
        price: 2500,
        duration: 60,
        image: 'https://images.unsplash.com/photo-1563453392212-d0a3609f7a91?w=400&h=300&fit=crop',
        capacityPerSlot: 2,
        rating: 4.5,
        reviewCount: 76,
      },

      // Plumbing Services
      {
        title: 'Emergency Plumbing Repair',
        description: 'Immediate plumbing repairs for leaks, clogs, and pipe damage. Available 24/7 with emergency charges applicable after hours.',
        category: 'plumbing',
        price: 6500,
        duration: 60,
        image: 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 4.9,
        reviewCount: 156,
      },
      {
        title: 'Pipe Installation',
        description: 'Professional installation of water pipes, drainage pipes, and plumbing fixtures. Includes consultation and quality assurance.',
        category: 'plumbing',
        price: 12000,
        duration: 180,
        image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 4.7,
        reviewCount: 64,
      },
      {
        title: 'Drain Cleaning Service',
        description: 'Clear blocked drains using modern equipment. Handles kitchen, bathroom, and main line drainage issues.',
        category: 'plumbing',
        price: 3500,
        duration: 75,
        image: 'https://images.unsplash.com/photo-1580622687521-85fc7f9c6b8f?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 4.6,
        reviewCount: 92,
      },

      // Electrical Services
      {
        title: 'Home Electrical Wiring',
        description: 'New electrical wiring installation for homes and apartments. Includes circuit breaker installation and safety compliance testing.',
        category: 'electrical',
        price: 15000,
        duration: 240,
        image: 'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 4.8,
        reviewCount: 118,
      },
      {
        title: 'LED Lighting Installation',
        description: 'Transform your space with modern LED lighting. Includes consultation, installation, and energy efficiency assessment.',
        category: 'electrical',
        price: 8000,
        duration: 120,
        image: 'https://images.unsplash.com/photo-1565636192335-14ef8d3f4f50?w=400&h=300&fit=crop',
        capacityPerSlot: 2,
        rating: 4.7,
        reviewCount: 103,
      },
      {
        title: 'Electrical Appliance Repair',
        description: 'Repair and maintenance for refrigerators, ovens, washing machines, and other household appliances.',
        category: 'electrical',
        price: 4500,
        duration: 90,
        image: 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 4.6,
        reviewCount: 127,
      },

      // Beauty Services
      {
        title: 'Hair Styling & Cut',
        description: 'Professional haircut, styling, and coloring. Expert stylists with 10+ years experience. Consultation included.',
        category: 'beauty',
        price: 2000,
        duration: 60,
        image: 'https://images.unsplash.com/photo-1599351957991-b4ea1f1fbf97?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 4.8,
        reviewCount: 234,
      },
      {
        title: 'Bridal Makeup Service',
        description: 'Complete bridal makeup package including trial session, touch-up kit, and professional makeup application on the day.',
        category: 'beauty',
        price: 12000,
        duration: 120,
        image: 'https://images.unsplash.com/photo-1487412947cee-618cfc5422ca?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 5.0,
        reviewCount: 89,
      },
      {
        title: 'Facial Treatment',
        description: 'Customized facial treatments for all skin types. Includes cleansing, extraction, massage, and nourishing mask.',
        category: 'beauty',
        price: 3500,
        duration: 75,
        image: 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 4.7,
        reviewCount: 156,
      },
      {
        title: 'Nail Art & Manicure',
        description: 'Creative nail art designs, gel manicure, and pedicure services. Latest trends and designs available.',
        category: 'beauty',
        price: 2500,
        duration: 60,
        image: 'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=400&h=300&fit=crop',
        capacityPerSlot: 2,
        rating: 4.6,
        reviewCount: 198,
      },

      // Tutoring Services
      {
        title: 'Mathematics Tutoring',
        description: 'One-on-one mathematics coaching for school students. Covers algebra, geometry, and advanced topics with personalized approach.',
        category: 'tutoring',
        price: 1500,
        duration: 60,
        image: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 4.9,
        reviewCount: 142,
      },
      {
        title: 'English Language Classes',
        description: 'Improve your English speaking, writing, and grammar. Suitable for all levels from beginner to advanced.',
        category: 'tutoring',
        price: 2000,
        duration: 60,
        image: 'https://images.unsplash.com/photo-1491841573634-28ca5534993f?w=400&h=300&fit=crop',
        capacityPerSlot: 3,
        rating: 4.8,
        reviewCount: 167,
      },
      {
        title: 'Science Tutoring',
        description: 'Physics, Chemistry, and Biology coaching with practical demonstrations and experiments for better understanding.',
        category: 'tutoring',
        price: 1800,
        duration: 75,
        image: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 4.7,
        reviewCount: 98,
      },

      // Gardening Services
      {
        title: 'Garden Maintenance',
        description: 'Weekly or monthly garden maintenance including grass cutting, plant care, weeding, and general landscaping.',
        category: 'other',
        price: 4000,
        duration: 120,
        image: 'https://images.unsplash.com/photo-1585320033890-cd8a515a8e1f?w=400&h=300&fit=crop',
        capacityPerSlot: 2,
        rating: 4.6,
        reviewCount: 87,
      },
      {
        title: 'Landscape Design',
        description: 'Professional garden design and landscaping consultation. Create your dream outdoor space with expert guidance.',
        category: 'other',
        price: 10000,
        duration: 120,
        image: 'https://images.unsplash.com/photo-1585433707802-83ca82bc9235?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 4.8,
        reviewCount: 64,
      },

      // Repair Services
      {
        title: 'Phone & Device Repair',
        description: 'Professional repair for smartphones, tablets, and laptops. Screen replacement, battery change, and software issues.',
        category: 'repair',
        price: 3000,
        duration: 90,
        image: 'https://images.unsplash.com/photo-1606933248051-5ce8adc20e02?w=400&h=300&fit=crop',
        capacityPerSlot: 2,
        rating: 4.7,
        reviewCount: 211,
      },
      {
        title: 'Furniture Repair & Restoration',
        description: 'Expert repair and restoration of wooden, upholstered, and modern furniture. Refinishing and reupholstering available.',
        category: 'repair',
        price: 5500,
        duration: 150,
        image: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&h=300&fit=crop',
        capacityPerSlot: 1,
        rating: 4.5,
        reviewCount: 73,
      },
    ];

    // Add future slots to each service
    const servicesWithSlots = services.map((service) => ({
      ...service,
      availableSlots: generateFutureSlots(),
    }));

    // Insert services
    const inserted = await Service.insertMany(servicesWithSlots);
    console.log(`✓ Successfully inserted ${inserted.length} services into the database`);

    // Summary
    console.log('\nSeed Summary:');
    console.log(`- Total services: ${inserted.length}`);
    console.log(`- Categories: cleaning, plumbing, electrical, beauty, tutoring, repair, other`);
    console.log(`- Each service has 240+ available slots spanning 60 days`);
    console.log(`- Slots generated for weekdays only (Mon-Fri)`);
    console.log(`- Each day has 4 time slots: 09:00, 11:00, 14:00, 16:00`);

    await mongoose.disconnect();
    console.log('\n✓ Disconnected from MongoDB');
    process.exit(0);
  } catch (error) {
    console.error('✗ Seed failed:', error instanceof Error ? error.message : error);
    process.exit(1);
  }
};

seedServices();
