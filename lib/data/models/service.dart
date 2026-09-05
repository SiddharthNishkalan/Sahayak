import 'package:flutter/material.dart';

class ServiceItem {
  final String id;
  final String title;
  final String description;
  final int basePrice;
  final String priceUnit;
  final int nearCount;
  final IconData icon;

  const ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.basePrice,
    required this.priceUnit,
    required this.nearCount,
    required this.icon,
  });

  static const List<ServiceItem> defaultServices = [
    ServiceItem(
      id: 'plumber',
      title: 'Plumber',
      description: 'Leaks, taps, piping',
      basePrice: 249,
      priceUnit: 'base',
      nearCount: 22,
      icon: Icons.plumbing_rounded,
    ),
    ServiceItem(
      id: 'electrician',
      title: 'Electrician',
      description: 'Wiring, fans, fixtures',
      basePrice: 299,
      priceUnit: 'base',
      nearCount: 34,
      icon: Icons.bolt_rounded,
    ),
    ServiceItem(
      id: 'cleaner',
      title: 'Cleaner',
      description: 'Deep cleaning, dusting',
      basePrice: 399,
      priceUnit: 'base',
      nearCount: 18,
      icon: Icons.cleaning_services_rounded,
    ),
    ServiceItem(
      id: 'carpenter',
      title: 'Carpenter',
      description: 'Furniture, doors, repairs',
      basePrice: 349,
      priceUnit: 'base',
      nearCount: 12,
      icon: Icons.carpenter_rounded,
    ),
    ServiceItem(
      id: 'caregiver',
      title: 'Caregiver',
      description: 'Elderly & patient care',
      basePrice: 499,
      priceUnit: 'day',
      nearCount: 15,
      icon: Icons.volunteer_activism_rounded,
    ),
    ServiceItem(
      id: 'driver',
      title: 'Driver',
      description: 'On-demand & trips',
      basePrice: 199,
      priceUnit: 'hr',
      nearCount: 27,
      icon: Icons.directions_car_rounded,
    ),
    ServiceItem(
      id: 'gardener',
      title: 'Gardener',
      description: 'Lawn, pruning, plants',
      basePrice: 249,
      priceUnit: 'visit',
      nearCount: 9,
      icon: Icons.yard_rounded,
    ),
    ServiceItem(
      id: 'appliance',
      title: 'Appliance Tech',
      description: 'AC, Fridge, Washing machine',
      basePrice: 349,
      priceUnit: 'diag',
      nearCount: 16,
      icon: Icons.home_repair_service_rounded,
    ),
  ];
}

class ServiceSubcategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const ServiceSubcategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  static const List<ServiceSubcategory> plumbingSubcategories = [
    ServiceSubcategory(
      id: 'tap',
      title: 'Tap Repair & Replacement',
      description: 'Valves, washers & mixer spouts',
      icon: Icons.water_drop_outlined,
    ),
    ServiceSubcategory(
      id: 'leakage',
      title: 'Leakage & Pipe Repair',
      description: 'Concealed wall & basin joints',
      icon: Icons.water_damage_outlined,
    ),
    ServiceSubcategory(
      id: 'drainage',
      title: 'Drainage & Blockage',
      description: 'Siphon traps & clogged drains',
      icon: Icons.grain_rounded,
    ),
    ServiceSubcategory(
      id: 'sanitary',
      title: 'Sanitary Fitting',
      description: 'Toilets, cisterns & jet sprays',
      icon: Icons.bathtub_outlined,
    ),
    ServiceSubcategory(
      id: 'tank',
      title: 'Water Tank & Motor',
      description: 'Overhead float valves & pumps',
      icon: Icons.water_rounded,
    ),
    ServiceSubcategory(
      id: 'other',
      title: 'Other Plumbing',
      description: 'General inspection & inquiry',
      icon: Icons.build_circle_outlined,
    ),
  ];
}
