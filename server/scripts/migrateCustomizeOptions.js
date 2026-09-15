import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Service from '../models/Service.js';
import connectDB from '../config/db.js';

dotenv.config();

const initialServices = [
  // Main catalog services
  {
    id: 'wash-fold',
    name: 'Wash & Fold',
    unit: 'kg',
    price: 49,
    features: ['Professional washing', 'Gentle drying', 'Neat folding'],
    featured: false,
    displayType: 'main',
    isActive: true,
    sortOrder: 1
  },
  {
    id: 'wash-iron',
    name: 'Wash & Iron',
    unit: 'kg',
    price: 69,
    features: ['Professional washing', 'Steam ironing', 'Crisp hanger delivery'],
    featured: false,
    displayType: 'main',
    isActive: true,
    sortOrder: 2
  },
  {
    id: 'shoe-cleaning',
    name: 'Shoe Cleaning',
    unit: 'pair',
    price: 125,
    features: ['Deep cleaning', 'Protective coating', 'Like new look'],
    featured: false,
    displayType: 'main',
    isActive: true,
    sortOrder: 3
  },
  {
    id: 'dry-cleaning',
    name: 'Dry Cleaning',
    unit: 'item',
    price: 0,
    features: ['Delicate care', 'Stain removal', 'Professional pressing'],
    featured: true,
    displayType: 'main',
    isActive: true,
    sortOrder: 4
  },
  {
    id: 'custom-service',
    name: 'Customize Your Service',
    unit: 'package',
    price: 0,
    features: ['Choose your own services', 'Flexible pricing', 'Tailored to your needs'],
    featured: false,
    displayType: 'main',
    isActive: true,
    sortOrder: 5
  },

  // Official Dry Cleaning Item Selection Reference Price List (15 items)
  {
    id: 'dryclean-tshirt',
    name: 'T-Shirt',
    unit: 'item',
    price: 90,
    features: ['Dry clean', 'Soft finish'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: "Men's Wear",
    isActive: true,
    sortOrder: 10
  },
  {
    id: 'dryclean-shirt',
    name: 'Shirt',
    unit: 'item',
    price: 90,
    features: ['Dry clean', 'Steam press'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: "Men's Wear",
    isActive: true,
    sortOrder: 11
  },
  {
    id: 'dryclean-pant',
    name: 'Pant',
    unit: 'item',
    price: 90,
    features: ['Dry clean', 'Crease finish'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: "Men's Wear",
    isActive: true,
    sortOrder: 12
  },
  {
    id: 'dryclean-stain-removal',
    name: 'T-Shirt / Shirt / Pant - Stain Removal',
    unit: 'item',
    price: 130,
    features: ['Stain treatment', 'Gentle wash'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: "Men's Wear",
    isActive: true,
    sortOrder: 13
  },
  {
    id: 'dryclean-churidar-top',
    name: 'Churidar Top',
    unit: 'item',
    price: 110,
    features: ['Dry clean', 'Delicate care'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: "Women's Wear",
    isActive: true,
    sortOrder: 14
  },
  {
    id: 'dryclean-churidar-bottom',
    name: 'Churidar Bottom',
    unit: 'item',
    price: 90,
    features: ['Dry clean', 'Soft press'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: "Women's Wear",
    isActive: true,
    sortOrder: 15
  },
  {
    id: 'dryclean-saree',
    name: 'Saree',
    unit: 'item',
    price: 300,
    features: ['Dry clean', 'Delicate handling'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: "Women's Wear",
    isActive: true,
    sortOrder: 16
  },
  {
    id: 'dryclean-blouse',
    name: 'Blouse',
    unit: 'item',
    price: 90,
    features: ['Dry clean', 'Steam press'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: "Women's Wear",
    isActive: true,
    sortOrder: 17
  },
  {
    id: 'dryclean-lehenga',
    name: 'Lehenga',
    unit: 'set',
    price: 430,
    features: ['Dry clean', 'Heavy work care'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: "Women's Wear",
    isActive: true,
    sortOrder: 18
  },
  {
    id: 'dryclean-blazer-2pc',
    name: 'Blazer (Two Piece)',
    unit: 'item',
    price: 230,
    features: ['Dry clean', 'Form finish'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: "Men's Wear",
    isActive: true,
    sortOrder: 19
  },
  {
    id: 'dryclean-blazer-3pc',
    name: 'Blazer (Three Piece)',
    unit: 'item',
    price: 290,
    features: ['Dry clean', 'Form finish'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: "Men's Wear",
    isActive: true,
    sortOrder: 20
  },
  {
    id: 'dryclean-carpet',
    name: 'Carpet Cleaning',
    unit: 'sq ft',
    price: 54,
    features: ['Deep clean', 'Fabric safe'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: 'Others',
    isActive: true,
    sortOrder: 21
  },
  {
    id: 'dryclean-toy-cleaning',
    name: 'Toy Cleaning',
    unit: 'item',
    price: 399,
    features: ['Gentle wash', 'Sanitize'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: 'Others',
    isActive: true,
    sortOrder: 22
  },
  {
    id: 'dryclean-bag-cleaning',
    name: 'Bag Cleaning',
    unit: 'item',
    price: 229,
    features: ['Deep clean', 'Soft finish'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: 'Others',
    isActive: true,
    sortOrder: 23
  },
  {
    id: 'dryclean-curtain-cleaning',
    name: 'Curtain Cleaning',
    unit: 'sq ft',
    price: 69,
    features: ['Fabric care', 'Steam finish'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Dry Clean',
    customizeSubcategory: 'Others',
    isActive: true,
    sortOrder: 24
  },

  // Bed Set Clean Options
  {
    id: 'bedset-big-blankets',
    name: 'Big Blankets',
    unit: 'item',
    price: 225,
    features: ['Deep clean', 'Soft finish'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Bed Set Clean',
    isActive: true,
    sortOrder: 40
  },
  {
    id: 'bedset-small-blankets',
    name: 'Small Blankets',
    unit: 'item',
    price: 199,
    features: ['Deep clean', 'Fresh feel'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Bed Set Clean',
    isActive: true,
    sortOrder: 41
  },
  {
    id: 'bedset-bedsheets',
    name: 'Bedsheets',
    unit: 'item',
    price: 129,
    features: ['Deep clean', 'Smooth finish'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Bed Set Clean',
    isActive: true,
    sortOrder: 42
  },

  // Shoe Cleaning Options
  {
    id: 'shoe-sports-shoe',
    name: 'Sports Shoe',
    unit: 'pair',
    price: 210,
    features: ['Deep clean', 'Sole shine'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Shoe Cleaning',
    isActive: true,
    sortOrder: 50
  },
  {
    id: 'shoe-casual-shoe',
    name: 'Casual Shoe',
    unit: 'pair',
    price: 200,
    features: ['Deep clean', 'Fresh finish'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Shoe Cleaning',
    isActive: true,
    sortOrder: 51
  },
  {
    id: 'shoe-formal-leather',
    name: 'Formal/Leather',
    unit: 'pair',
    price: 299,
    features: ['Leather care', 'Polish'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Shoe Cleaning',
    isActive: true,
    sortOrder: 52
  },
  {
    id: 'shoe-boots',
    name: 'Boots',
    unit: 'pair',
    price: 299,
    features: ['Deep clean', 'Leather care'],
    featured: false,
    displayType: 'customize',
    customizeCategory: 'Shoe Cleaning',
    isActive: true,
    sortOrder: 53
  }
];

const runMigration = async () => {
  try {
    await connectDB();
    console.log('Connected to MongoDB for Dry Cleaning official reference price-list migration...');

    // 1. Soft-disable legacy documents without an ID or without displayType field
    await Service.updateMany(
      { $or: [{ id: { $exists: false } }, { id: null }, { displayType: { $exists: false } }] },
      { $set: { isActive: false, displayType: 'legacy' } }
    );

    // 2. Re-categorize old catalog items (premium-bedding, steam-press, blanket-cleaning) so they don't appear in main cards
    await Service.updateMany(
      { id: { $in: ['premium-bedding', 'steam-press', 'blanket-cleaning'] } },
      { $set: { displayType: 'customize', isActive: false } }
    );

    let insertedCount = 0;
    let updatedCount = 0;

    for (const service of initialServices) {
      const result = await Service.updateOne(
        { id: service.id },
        { $setOnInsert: service },
        { upsert: true }
      );

      if (result.upsertedCount > 0) {
        insertedCount++;
      } else {
        // Safe update for price, displayType, sortOrder & features for reference items if they already exist
        const updateRes = await Service.updateOne(
          { id: service.id },
          { 
            $set: { 
              price: service.price, 
              unit: service.unit, 
              name: service.name,
              displayType: service.displayType,
              isActive: service.isActive !== undefined ? service.isActive : true,
              sortOrder: service.sortOrder || 0,
              customizeCategory: service.customizeCategory || '',
              customizeSubcategory: service.customizeSubcategory || ''
            } 
          }
        );
        if (updateRes.modifiedCount > 0) updatedCount++;
      }
    }

    console.log(`Migration completed safely: ${insertedCount} new inserted, ${updatedCount} existing updated.`);
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
};

runMigration();
