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
  final String serviceId;
  final String title;
  final String description;
  final IconData icon;

  const ServiceSubcategory({
    required this.id,
    this.serviceId = 'plumber',
    required this.title,
    required this.description,
    required this.icon,
  });

  // 1. Plumber (Plumbing & Water)
  static const List<ServiceSubcategory> plumbingSubcategories = [
    ServiceSubcategory(
      id: 'plumb_tap',
      serviceId: 'plumber',
      title: 'Tap Repair & Replacement',
      description: 'Valves, washers & mixer spouts',
      icon: Icons.water_drop_outlined,
    ),
    ServiceSubcategory(
      id: 'plumb_leakage',
      serviceId: 'plumber',
      title: 'Leakage & Pipe Repair',
      description: 'Concealed wall & basin joints',
      icon: Icons.water_damage_outlined,
    ),
    ServiceSubcategory(
      id: 'plumb_drainage',
      serviceId: 'plumber',
      title: 'Drainage & Blockage',
      description: 'Siphon traps & clogged drains',
      icon: Icons.grain_rounded,
    ),
    ServiceSubcategory(
      id: 'plumb_sanitary',
      serviceId: 'plumber',
      title: 'Sanitary Fitting',
      description: 'Toilets, cisterns & jet sprays',
      icon: Icons.bathtub_outlined,
    ),
    ServiceSubcategory(
      id: 'plumb_tank',
      serviceId: 'plumber',
      title: 'Water Tank & Motor',
      description: 'Overhead float valves & pumps',
      icon: Icons.water_rounded,
    ),
    ServiceSubcategory(
      id: 'plumb_other',
      serviceId: 'plumber',
      title: 'Other Plumbing',
      description: 'General inspection & pipe routing',
      icon: Icons.build_circle_outlined,
    ),
  ];

  // 2. Electrician (Electrical & Power)
  static const List<ServiceSubcategory> electricianSubcategories = [
    ServiceSubcategory(
      id: 'elec_switch',
      serviceId: 'electrician',
      title: 'Switchboard & Socket',
      description: 'Broken switches, loose sockets & plugs',
      icon: Icons.power_rounded,
    ),
    ServiceSubcategory(
      id: 'elec_fan_light',
      serviceId: 'electrician',
      title: 'Fan & Light Fixture',
      description: 'Ceiling fans, chandeliers & LED panels',
      icon: Icons.lightbulb_outline_rounded,
    ),
    ServiceSubcategory(
      id: 'elec_mcb',
      serviceId: 'electrician',
      title: 'Circuit Breaker & MCB',
      description: 'Tripping diagnostics & load balance',
      icon: Icons.bolt_rounded,
    ),
    ServiceSubcategory(
      id: 'elec_inverter',
      serviceId: 'electrician',
      title: 'Inverter & UPS Wiring',
      description: 'Backup wiring & battery terminal fix',
      icon: Icons.battery_charging_full_rounded,
    ),
    ServiceSubcategory(
      id: 'elec_short_circuit',
      serviceId: 'electrician',
      title: 'Short Circuit Diagnostic',
      description: 'Concealed wiring burn & earth leakage',
      icon: Icons.warning_amber_rounded,
    ),
    ServiceSubcategory(
      id: 'elec_other',
      serviceId: 'electrician',
      title: 'Other Electrical',
      description: 'General wiring & power point setup',
      icon: Icons.electrical_services_rounded,
    ),
  ];

  // 3. Cleaner (Deep Cleaning & Sanitization)
  static const List<ServiceSubcategory> cleanerSubcategories = [
    ServiceSubcategory(
      id: 'clean_deep_home',
      serviceId: 'cleaner',
      title: 'Full Deep Home Cleaning',
      description: 'Floor scrubbing, dusting & sanitization',
      icon: Icons.cleaning_services_rounded,
    ),
    ServiceSubcategory(
      id: 'clean_kitchen',
      serviceId: 'cleaner',
      title: 'Kitchen & Chimney',
      description: 'Oil stains, countertops & degreasing',
      icon: Icons.soup_kitchen_rounded,
    ),
    ServiceSubcategory(
      id: 'clean_bathroom',
      serviceId: 'cleaner',
      title: 'Bathroom Sanitization',
      description: 'Tile descaling, grout & stain removal',
      icon: Icons.wash_rounded,
    ),
    ServiceSubcategory(
      id: 'clean_sofa_carpet',
      serviceId: 'cleaner',
      title: 'Sofa & Carpet Shampoo',
      description: 'Upholstery steam wash & vacuum',
      icon: Icons.weekend_rounded,
    ),
    ServiceSubcategory(
      id: 'clean_balcony_floor',
      serviceId: 'cleaner',
      title: 'Balcony & Floor Scrubbing',
      description: 'Glass panels, railings & deep scrub',
      icon: Icons.window_rounded,
    ),
    ServiceSubcategory(
      id: 'clean_other',
      serviceId: 'cleaner',
      title: 'Move-in / Custom Clean',
      description: 'Pre/post occupancy comprehensive clean',
      icon: Icons.home_outlined,
    ),
  ];

  // 4. Carpenter (Carpentry & Woodwork)
  static const List<ServiceSubcategory> carpenterSubcategories = [
    ServiceSubcategory(
      id: 'carp_door_lock',
      serviceId: 'carpenter',
      title: 'Door & Lock Repair',
      description: 'Sticking doors, latch fix & lock install',
      icon: Icons.door_front_door_outlined,
    ),
    ServiceSubcategory(
      id: 'carp_furniture_assembly',
      serviceId: 'carpenter',
      title: 'Furniture Assembly',
      description: 'Bed frames, tables, desks & flatpacks',
      icon: Icons.chair_rounded,
    ),
    ServiceSubcategory(
      id: 'carp_cupboard_hinge',
      serviceId: 'carpenter',
      title: 'Cupboard & Hinge Fix',
      description: 'Soft-close hinges, sliding doors & handles',
      icon: Icons.kitchen_rounded,
    ),
    ServiceSubcategory(
      id: 'carp_wood_polish',
      serviceId: 'carpenter',
      title: 'Wood Polishing & Touch-up',
      description: 'Varnish, scratch buffing & termite coat',
      icon: Icons.brush_rounded,
    ),
    ServiceSubcategory(
      id: 'carp_window_frame',
      serviceId: 'carpenter',
      title: 'Window Frame & Latch',
      description: 'Wooden frames, pelmets & curtain rods',
      icon: Icons.grid_view_rounded,
    ),
    ServiceSubcategory(
      id: 'carp_other',
      serviceId: 'carpenter',
      title: 'Custom Woodwork',
      description: 'Wall shelves, partitions & repairs',
      icon: Icons.carpenter_rounded,
    ),
  ];

  // 5. Caregiver (Elderly & Patient Care)
  static const List<ServiceSubcategory> caregiverSubcategories = [
    ServiceSubcategory(
      id: 'care_elderly',
      serviceId: 'caregiver',
      title: 'Elderly Daily Assistance',
      description: 'Bathing, dressing & routine daily support',
      icon: Icons.elderly_rounded,
    ),
    ServiceSubcategory(
      id: 'care_post_surgery',
      serviceId: 'caregiver',
      title: 'Post-Surgery Care',
      description: 'Wound care assistance & recovery support',
      icon: Icons.local_hospital_rounded,
    ),
    ServiceSubcategory(
      id: 'care_mobility',
      serviceId: 'caregiver',
      title: 'Mobility & Walking Support',
      description: 'Wheelchair assist, light exercise & strolls',
      icon: Icons.nordic_walking_rounded,
    ),
    ServiceSubcategory(
      id: 'care_medication',
      serviceId: 'caregiver',
      title: 'Medication & Vital Tracking',
      description: 'BP/sugar logging, timely dose reminders',
      icon: Icons.monitor_heart_rounded,
    ),
    ServiceSubcategory(
      id: 'care_bedridden',
      serviceId: 'caregiver',
      title: 'Bedridden Patient Care',
      description: 'Repositioning, hygiene & feeding care',
      icon: Icons.bed_rounded,
    ),
    ServiceSubcategory(
      id: 'care_other',
      serviceId: 'caregiver',
      title: 'Companion & Respite Care',
      description: 'Emotional companionship & clinic escorts',
      icon: Icons.volunteer_activism_rounded,
    ),
  ];

  // 6. Driver (On-demand & Chauffeur)
  static const List<ServiceSubcategory> driverSubcategories = [
    ServiceSubcategory(
      id: 'drive_city_hourly',
      serviceId: 'driver',
      title: 'City Chauffeur (Hourly)',
      description: 'Intra-city errands, meetings & shopping',
      icon: Icons.directions_car_rounded,
    ),
    ServiceSubcategory(
      id: 'drive_outstation',
      serviceId: 'driver',
      title: 'Outstation Trip Driver',
      description: 'Highway trips, weekend outstation travel',
      icon: Icons.commute_rounded,
    ),
    ServiceSubcategory(
      id: 'drive_airport',
      serviceId: 'driver',
      title: 'Airport Transfer Driver',
      description: 'On-time terminal pickup & drop',
      icon: Icons.flight_takeoff_rounded,
    ),
    ServiceSubcategory(
      id: 'drive_daily_commute',
      serviceId: 'driver',
      title: 'Daily Office Commute',
      description: 'Dedicated recurring morning & evening driver',
      icon: Icons.access_time_filled_rounded,
    ),
    ServiceSubcategory(
      id: 'drive_night_valet',
      serviceId: 'driver',
      title: 'Night Driver Service',
      description: 'Late night returns & dining chauffeurs',
      icon: Icons.nightlife_rounded,
    ),
    ServiceSubcategory(
      id: 'drive_other',
      serviceId: 'driver',
      title: 'Luxury & SUV Specialist',
      description: 'Automatic, EV & luxury vehicle handling',
      icon: Icons.car_rental_rounded,
    ),
  ];

  // 7. Gardener (Lawn & Plant Care)
  static const List<ServiceSubcategory> gardenerSubcategories = [
    ServiceSubcategory(
      id: 'gard_lawn_mowing',
      serviceId: 'gardener',
      title: 'Lawn Mowing & Trimming',
      description: 'Grass cut, perimeter neatening & clearing',
      icon: Icons.grass_rounded,
    ),
    ServiceSubcategory(
      id: 'gard_pruning_weeding',
      serviceId: 'gardener',
      title: 'Plant Pruning & Weeding',
      description: 'Deadhead flowers, shrub shaping & weeding',
      icon: Icons.content_cut_rounded,
    ),
    ServiceSubcategory(
      id: 'gard_soil_manuring',
      serviceId: 'gardener',
      title: 'Soil Manuring & Fertilizing',
      description: 'Organic compost, potting mix & root feeds',
      icon: Icons.eco_rounded,
    ),
    ServiceSubcategory(
      id: 'gard_pest_care',
      serviceId: 'gardener',
      title: 'Pest Control & Plant Care',
      description: 'Neem oil spray, fungal treatment & tonic',
      icon: Icons.pest_control_rounded,
    ),
    ServiceSubcategory(
      id: 'gard_balcony_setup',
      serviceId: 'gardener',
      title: 'Balcony Garden Setup',
      description: 'Potted plant styling & drip irrigation',
      icon: Icons.yard_rounded,
    ),
    ServiceSubcategory(
      id: 'gard_other',
      serviceId: 'gardener',
      title: 'Repotting & Landscaping',
      description: 'Planter upgrades & garden maintenance',
      icon: Icons.park_rounded,
    ),
  ];

  // 8. Appliance Tech (Appliances & Electronics)
  static const List<ServiceSubcategory> applianceSubcategories = [
    ServiceSubcategory(
      id: 'appl_ac_service',
      serviceId: 'appliance',
      title: 'AC Service & Gas Charging',
      description: 'Filter foam wash, cooling coil & gas top-up',
      icon: Icons.ac_unit_rounded,
    ),
    ServiceSubcategory(
      id: 'appl_fridge_repair',
      serviceId: 'appliance',
      title: 'Refrigerator Cooling Fix',
      description: 'Compressor diagnostic, thermostat & defrost',
      icon: Icons.kitchen_rounded,
    ),
    ServiceSubcategory(
      id: 'appl_washing_machine',
      serviceId: 'appliance',
      title: 'Washing Machine Drum/Motor',
      description: 'Drain pump, spinning issues & error codes',
      icon: Icons.local_laundry_service_rounded,
    ),
    ServiceSubcategory(
      id: 'appl_microwave_oven',
      serviceId: 'appliance',
      title: 'Microwave & Oven Repair',
      description: 'Heating element, magnetron & touch panel',
      icon: Icons.microwave_rounded,
    ),
    ServiceSubcategory(
      id: 'appl_ro_purifier',
      serviceId: 'appliance',
      title: 'Water Purifier (RO) Service',
      description: 'Filter membrane replacement & TDS check',
      icon: Icons.water_drop_rounded,
    ),
    ServiceSubcategory(
      id: 'appl_other',
      serviceId: 'appliance',
      title: 'Geyser & Water Heater',
      description: 'Thermostat coil change & tank scale cleanup',
      icon: Icons.hot_tub_rounded,
    ),
  ];

  static List<ServiceSubcategory> getSubcategoriesForService(String serviceId) {
    switch (serviceId.toLowerCase().trim()) {
      case 'plumber':
      case 'plumbing':
        return plumbingSubcategories;
      case 'electrician':
      case 'electrical':
        return electricianSubcategories;
      case 'cleaner':
      case 'cleaning':
        return cleanerSubcategories;
      case 'carpenter':
      case 'carpentry':
        return carpenterSubcategories;
      case 'caregiver':
      case 'caregiving':
        return caregiverSubcategories;
      case 'driver':
      case 'driving':
        return driverSubcategories;
      case 'gardener':
      case 'gardening':
        return gardenerSubcategories;
      case 'appliance':
      case 'appliances':
        return applianceSubcategories;
      default:
        return plumbingSubcategories;
    }
  }
}
