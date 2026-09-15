import mongoose from 'mongoose';

const serviceSchema = new mongoose.Schema(
  {
    id: {
      type: String,
      required: true,
      unique: true,
      trim: true
    },
    name: {
      type: String,
      required: true,
      trim: true
    },
    unit: {
      type: String,
      required: true,
      trim: true
    },
    price: {
      type: Number,
      required: true
    },
    surahiUnitCost: {
      type: Number,
      default: 0
    },
    features: {
      type: [String],
      default: []
    },
    featured: {
      type: Boolean,
      default: false
    },
    displayType: {
      type: String,
      enum: ['main', 'customize'],
      default: 'main'
    },
    customizeCategory: {
      type: String,
      trim: true,
      default: ''
    },
    customizeSubcategory: {
      type: String,
      trim: true,
      default: ''
    },
    isActive: {
      type: Boolean,
      default: true
    },
    sortOrder: {
      type: Number,
      default: 0
    },
    stainRemovalPrice: {
      type: Number,
      default: 0
    },
    hasStainRemoval: {
      type: Boolean,
      default: false
    },
    premiumCleanPrice: {
      type: Number,
      default: 0
    },
    hasPremiumClean: {
      type: Boolean,
      default: false
    }
  },
  {
    timestamps: true
  }
);

const Service = mongoose.model('Service', serviceSchema);

export default Service;
