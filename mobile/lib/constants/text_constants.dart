const adminStatistic = {
  'scraper': {
    'count_scraper': "Số lượng người tham gia",
    'kg_co2e_reduced': "Tổng kg CO₂e giảm được",
    'kg_collected': "Tổng kg rác thu gom được",
    'expense_reduced': "Chi phí giảm được nhờ thu gom",
  },

  'household': {
    'count_household': "Số lượng người tham gia",
    'kg_co2e_plastic_reduced': "Lượng kg CO₂e giảm được do từ chối sử dụng nhựa",
    'kg_co2e_recycle_reduced': "Lượng kg CO₂e giảm được từ tái chế",
    'kg_recycle_collected': "Lượng kg rác tái chế thu gom được",
  }
};

const scraperDetailContribution = {
  1: "kg rác NHỰA thu gom",
  2: "kg rác GIẤY thu gom",
  3: "kg rác KIM LOẠI thu gom"
};
const householdDetailContribution = {
  1: "túi nilon từ chối sử dụng khi đi chợ",
  2: "chai nhựa PET từ chối mua nhờ mang bình cá nhân",
  3: "cốc dùng một lần từ chối sử dụng nhờ mang bình nước cá nhân",
  4: "ống hút nhựa từ chối sử dụng",
  5: "kg rác NHỰA phân loại để tái chế",
  6: "kg rác GIẤY phân loại để tái chế",
  7: "kg rác KIM LOẠI phân loại để tái chế",
  8: "kg rác HỮU CƠ được ủ thành phân bón",
  9: "kg rác phát sinh tổng cộng hàng ngày"
};

const scraperStatistic = {
  'days_joined': "Số ngày đã tham gia",
  'kg_co2e_reduced': "Tổng kg CO₂e giảm được",
  'kg_collected': "Tổng kg rác thu gom được",
  'expense_reduced': "Chi phí giảm được nhờ thu gom",
};

const householdStatistic = {
  'days_joined': "Số ngày đã tham gia",
  'kg_co2e_plastic_reduced': "Lượng kg CO₂e giảm được do từ chối sử dụng nhựa",
  'kg_co2e_recycle_reduced': "Lượng kg CO₂e giảm được từ tái chế",
  'kg_recycle_collected': "Lượng kg rác tái chế thu gom được",
};

const scraperInput = {
  1: {
    'unit_value': 1.64,
    'kilo_plastic_collected': "Khối lượng rác nhựa thu gom được (kg)",
  },
  2: {
    'unit_value': 3.90,
    'kilo_paper_collected': "Khối lượng giấy thu gom được (kg)",
  },
  3: {
    'unit_value': 6.79,
    'kilo_metal_garbage_collected': "Khối lượng rác kim loại thu gom được (kg)",
  }
};
const householdInput = {
  1: {
    'unit_value': 0.001578,
    'plastic_bag_rejected': "Số lượng túi nilon từ chối sử dụng (cái)",
  },
  2: {
    'unit_value': 0.08,
    'pet_bottle_rejected': "Số lượng chai nhựa từ chối sử dụng nhờ mang bình cá nhân (cái)",
  },
  3: {
    'unit_value': 0.05,
    'plastic_cup_rejected': "Số lượng cốc nhựa từ chối sử dụng nhờ mang bình cá nhân (cái)",
  },
  4: {
    'unit_value': 0.00146,
    'plastic_straw_rejected': "Số lượng ống hút nhựa từ chối sử dụng (cái)",
  },
  5: {
    'unit_value': 0.0,
    'total_kilo_garbage_growth_daily': "Khối lượng rác phát sinh tổng cộng hàng ngày (kg)",
  },
  6: {
    'unit_value': 1.64,
    'kilo_plastic_recycled': "Khối lượng rác nhựa phân loại để tái chế (kg)",
  },
  7: {
    'unit_value': 3.90,
    'kilo_paper_recycled': "Khối lượng giấy phân loại để tái chế (kg)",
  },
  8: {
    'unit_value': 6.79,
    'kilo_metal_garbage_recycled': "Khối lượng rác kim loại phân loại để tái chế (kg)", 
  },
  9: {
    'unit_value': 2.15,
    'kilo_organic_garbage_to_fertilizer': "Khối lượng rác hữu cơ ủ để làm phân bón (kg)",
  },
};
