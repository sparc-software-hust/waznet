const adminStatistic = {
  'scraper': {
    'count_scraper': "Số lượng người tham gia",
    'kg_co2e_reduced': "Tổng kg CO₂e giảm được",
    'kg_collected': "Tổng kg rác thu gom được",
    'expense_reduced': "Chi phí giảm được nhờ thu gom",
  },

  'household': {
    'count_household': "Số lượng người tham gia",
    'kg_co2e_plastic_reduced': "Lượng kg CO₂e giảm được từ giảm sử dụng nhựa",
    'kg_co2e_recycle_reduced': "Lượng kg CO₂e giảm được từ tái chế",
    'kg_recycle_collected': "Khối lượng rác tái chế thu gom được",
  }
};

const scraperInput = [
  {
    'factor_id': 1,
    'unit_value': 1.64,
    'kilo_plastic_collected': "Khối lượng rác nhựa thu gom được (kg)",
  },
  {
    'factor_id': 2,
    'unit_value': 3.90,
    'kilo_paper_collected': "Khối lượng giấy thu gom được (kg)",
  },
  {
    'factor_id': 3,
    'unit_value': 6.79,
    'kilo_metal_garbage_collected': "Khối lượng rác kim loại thu gom được (kg)",
  }
];

const householdInput = [
  {
    'factor_id': 1,
    'unit_value': 0.001578,
    'plastic_bag_rejected': "Số lượng túi nilon từ chối sử dụng (cái)",
  },
  {
    'factor_id': 2,
    'unit_value': 0.08,
    'pet_bottle_rejected': "Số lượng chai nhựa từ chối sử dụng nhờ mua bình cá nhân (cái)",
  },
  {
    'factor_id': 3,
    'unit_value': 0.05,
    'plastic_cup_rejected': "Số lượng cốc nhựa từ chối sử dụng nhờ mua bình cá nhân (cái)",
  },
  {
    'factor_id': 4,
    'unit_value': 0.00146,
    'plastic_straw_rejected': "Số lượng ống hút nhựa từ chối sử dụng (cái)",
  },

  {
    'factor_id': 5,
    'unit_value': 1.64,
    'kilo_plastic_recycled': "Khối lượng rác nhựa phân loại để tái chế (kg)",
  },
  {
    'factor_id': 6,
    'unit_value': 3.90,
    'kilo_paper_recycled': "Khối lượng giấy phân loại để tái chế (kg)",
  },
  {
    'factor_id': 7,
    'unit_value': 6.79,
    'kilo_metal_garbage_recycled': "Khối lượng rác kim loại phân loại để tái chế (kg)", 
  },
  {
    'factor_id': 8,
    'unit_value': 2.15,
    'kilo_organic_garbage_to_fertilizer': "Khối lượng rác hữu cơ ủ để làm phân bón (kg)",
  },
];
