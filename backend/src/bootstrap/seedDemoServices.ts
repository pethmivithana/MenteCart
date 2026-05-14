import { Service } from '../models/Service';
import { logger } from '../utils/logger';

function buildSlots(daysAhead: number): { date: string; time: string; capacity: number; bookedCount: number }[] {
  const slots: { date: string; time: string; capacity: number; bookedCount: number }[] = [];
  const times = ['09:00', '14:00', '17:00'];
  for (let d = 0; d < daysAhead; d++) {
    const dt = new Date();
    dt.setUTCDate(dt.getUTCDate() + d);
    const y = dt.getUTCFullYear();
    const m = String(dt.getUTCMonth() + 1).padStart(2, '0');
    const day = String(dt.getUTCDate()).padStart(2, '0');
    const date = `${y}-${m}-${day}`;
    for (const time of times) {
      slots.push({ date, time, capacity: 6, bookedCount: 0 });
    }
  }
  return slots;
}

/**
 * Inserts demo services when the database has none (development-friendly).
 * Idempotent: skips if any service already exists.
 */
export async function seedDemoServicesIfEmpty(): Promise<void> {
  try {
    const count = await Service.countDocuments();
    if (count > 0) {
      return;
    }

    const slots = buildSlots(21);

    await Service.insertMany([
      {
        title: 'Mindful Counseling Session',
        description:
          'One-on-one counseling session with a licensed therapist. Confidential, supportive environment.',
        price: 89.99,
        duration: 60,
        category: 'other',
        image: 'https://via.placeholder.com/400x300?text=Counseling',
        capacityPerSlot: 6,
        availableSlots: slots,
        isActive: true,
      },
      {
        title: 'Stress Management Workshop',
        description: 'Group workshop on breathing techniques, CBT basics, and daily stress reduction.',
        price: 45,
        duration: 90,
        category: 'fitness',
        image: 'https://via.placeholder.com/400x300?text=Workshop',
        capacityPerSlot: 10,
        availableSlots: slots,
        isActive: true,
      },
      {
        title: 'Career Coaching',
        description: 'Structured session to clarify goals, resume feedback, and interview preparation.',
        price: 120,
        duration: 45,
        category: 'tutoring',
        image: 'https://via.placeholder.com/400x300?text=Coaching',
        capacityPerSlot: 4,
        availableSlots: slots,
        isActive: true,
      },
      {
        title: 'Sleep Hygiene Consultation',
        description: 'Personalized plan for better sleep including routine and environment review.',
        price: 65,
        duration: 30,
        category: 'other',
        image: 'https://via.placeholder.com/400x300?text=Sleep',
        capacityPerSlot: 8,
        availableSlots: slots,
        isActive: true,
      },
    ]);

    logger.info({ count: 4 }, 'Seeded demo services (empty database)');
  } catch (err) {
    logger.error({ err }, 'Demo service seed failed — continuing without seed');
  }
}
