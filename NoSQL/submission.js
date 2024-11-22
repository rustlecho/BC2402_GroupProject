use "finalProject"
//Q1 
db.customer_support.distinct("category")
db.customer_support.find({ category:" "})

// Base on the github the main category will be the capital letter only, therefore we will remove the incorrect category 
db.customer_support.deleteMany({category: {$nin : ["CONTACT","CANCEL","FEEDBACK","INVOICE","ORDER","PAYMENT","REFUND","SHIPPING"]}})
db.customer_support.aggregate([
  { $group: { _id: "$category" } },
  { $count: "distinctCategoryCount" }
])
// has 8 distinct category 

//Q2 
db.customer_support.aggregate([
    {
        $match: {
          flags : {$regex: "Q"}, // Colloquial variation
          flags : {$regex: "W"} // Offensive language
        }
    },
    {
        $group: { _id: {Category:"$category"}, total:{$sum:1}}
    }
])

// Q3 




//Q4 
db.flight_delay.aggregate([
    // Step 1: Add Month field by extracting from Date, and count ArrDelay occurrences by Month, Origin, and Dest
    {
      $addFields: {
        Month: { $substr: ["$Date", 3, 2] }  // Extract month part (characters at index 3 and 4)
      }
    },
    {
      $group: {
        _id: { Month: "$Month", Origin: "$Origin", Dest: "$Dest" },
        Cnt: { $sum: 1 }  // Count occurrences of ArrDelay
      }
    },
    {
      $project: {
        Month: "$_id.Month",
        Origin: "$_id.Origin",
        Dest: "$_id.Dest",
        Cnt: 1,
        _id: 0
      }
    },
    
    // Step 2: Store max Cnt per Month in an array
    {
      $group: {
        _id: "$Month",
        maxCnt: { $max: "$Cnt" },
        entries: { $push: { Origin: "$Origin", Dest: "$Dest", Cnt: "$Cnt" } }
      }
    },
    
    // Step 3: Unwind the entries array and filter to retain only records with max Cnt
    {
      $unwind: "$entries"
    },
    {
      $match: {
        $expr: { $eq: ["$entries.Cnt", "$maxCnt"] }
      }
    },
    
    // Step 4: Project the final result with Month, Origin, Dest, and Cnt
    {
      $project: {
        Month: "$_id",
        Origin: "$entries.Origin",
        Dest: "$entries.Dest",
        Cnt: "$entries.Cnt",
        _id:0
      }
    }
  ]);

  //Q5 

  //Q6

//Average ratios requested by the Question.
print("1. Average Ratios Grouped by Sales Channel and Route:");
db.customer_booking.aggregate([
  {
    $group: {
      _id: { sales_channel: "$sales_channel", route: "$route" },
      avg_wants_extra_baggage: { $avg: "$wants_extra_baggage" },
      avg_wants_in_flight_meals: { $avg: "$wants_in_flight_meals" },
      avg_length_of_stay: { $avg: "$length_of_stay" },
      avg_flight_duration: { $avg: "$flight_duration" }
    }
  },
  {
    $project: {
      sales_channel: "$_id.sales_channel",
      route: "$_id.route",
      avg_wants_extra_baggage_per_flight_hour: {
        $divide: ["$avg_wants_extra_baggage", "$avg_flight_duration"]
      },
      avg_wants_in_flight_meals_per_flight_hour: {
        $divide: ["$avg_wants_in_flight_meals", "$avg_flight_duration"]
      },
      avg_length_of_stay_per_flight_hour: {
        $divide: ["$avg_length_of_stay", "$avg_flight_duration"]
      },
      _id: 0
    }
  },
  {
    $sort: { route: 1 } // Sort by route in ascending order
  }
]).forEach(printjson);


// Overall Average ratios with no group by.
print("2. Overall Average Ratios Without Group By:");
db.customer_booking.aggregate([
  {
    $group: {
      _id: null,
      avg_wants_extra_baggage: { $avg: "$wants_extra_baggage" },
      avg_wants_in_flight_meals: { $avg: "$wants_in_flight_meals" },
      avg_length_of_stay: { $avg: "$length_of_stay" },
      avg_flight_duration: { $avg: "$flight_duration" }
    }
  },
  {
    $project: {
      avg_wants_extra_baggage_per_flight_hour: {
        $divide: ["$avg_wants_extra_baggage", "$avg_flight_duration"]
      },
      avg_wants_in_flight_meals_per_flight_hour: {
        $divide: ["$avg_wants_in_flight_meals", "$avg_flight_duration"]
      },
      avg_length_of_stay_per_flight_hour: {
        $divide: ["$avg_length_of_stay", "$avg_flight_duration"]
      },
      _id: 0
    }
  }
]).forEach(printjson);

// Ratios grouped by Sales Channel only.
print("3. Ratios Grouped by Sales Channel:");
db.customer_booking.aggregate([
  {
    $group: {
      _id: "$sales_channel",
      avg_wants_extra_baggage: { $avg: "$wants_extra_baggage" },
      avg_wants_in_flight_meals: { $avg: "$wants_in_flight_meals" },
      avg_length_of_stay: { $avg: "$length_of_stay" },
      avg_flight_duration: { $avg: "$flight_duration" }
    }
  },
  {
    $project: {
      sales_channel: "$_id",
      avg_wants_extra_baggage_per_flight_hour: {
        $divide: ["$avg_wants_extra_baggage", "$avg_flight_duration"]
      },
      avg_wants_in_flight_meals_per_flight_hour: {
        $divide: ["$avg_wants_in_flight_meals", "$avg_flight_duration"]
      },
      avg_length_of_stay_per_flight_hour: {
        $divide: ["$avg_length_of_stay", "$avg_flight_duration"]
      },
      _id: 0
    }
  }
]).forEach(printjson);

// Statistical distribution of flight_duration.
print("4. Statistical Distribution of Flight Duration:");
db.customer_booking.aggregate([
  {
    $group: {
      _id: null,
      mean_flight_duration: { $avg: "$flight_duration" },
      min_flight_duration: { $min: "$flight_duration" },
      max_flight_duration: { $max: "$flight_duration" },
      std_dev_flight_duration: { $stdDevPop: "$flight_duration" },
      total_flights: { $count: {} }
    }
  },
  {
    $project: { _id: 0 }
  }
]).forEach(printjson);

// Variables split by Short and Long flights.
print("5. Variables Split by Short and Long Flights:");
db.customer_booking.aggregate([
  {
    $addFields: {
      flight_segment: {
        $cond: [{ $lte: ["$flight_duration", 7] }, "Short Flights", "Long Flights"]
      }
    }
  },
  {
    $group: {
      _id: "$flight_segment",
      avg_extra_baggage: { $avg: "$wants_extra_baggage" },
      avg_preferred_seat: { $avg: "$wants_preferred_seat" },
      avg_in_flight_meals: { $avg: "$wants_in_flight_meals" },
      avg_length_of_stay: { $avg: "$length_of_stay" }
    }
  }
]).forEach(printjson);

//Meal preference rattio split by flight hour
print("1. Meal Preference Ratio Split by Flight Hour:");
db.customer_booking.aggregate([
  {
    $addFields: {
      rounded_flight_duration: { $round: ["$flight_duration", 0] }
    }
  },
  {
    $group: {
      _id: "$rounded_flight_duration",
      total_meals: { $sum: "$wants_in_flight_meals" },
      total_flights: { $count: {} }
    }
  },
  {
    $project: {
      rounded_flight_duration: "$_id",
      total_meals: 1,
      total_flights: 1,
      meal_preference_ratio: { $divide: ["$total_meals", "$total_flights"] },
      _id: 0
    }
  },
  {
    $sort: { rounded_flight_duration: 1 }
  }
]).forEach(printjson);

//Overall rations split by flight duration.
print("2. Overall Ratios Split by Flight Duration:");
db.customer_booking.aggregate([
  {
    $addFields: {
      rounded_flight_duration: { $round: ["$flight_duration", 0] }
    }
  },
  {
    $group: {
      _id: "$rounded_flight_duration",
      avg_extra_baggage_preference: { $avg: "$wants_extra_baggage" },
      avg_preferred_seat_preference: { $avg: "$wants_preferred_seat" },
      avg_in_flight_meal_preference: { $avg: "$wants_in_flight_meals" },
      avg_length_of_stay: { $avg: "$length_of_stay" }
    }
  },
  {
    $project: {
      rounded_flight_duration: "$_id",
      avg_extra_baggage_preference: 1,
      avg_preferred_seat_preference: 1,
      avg_in_flight_meal_preference: 1,
      avg_length_of_stay: 1,
      _id: 0
    }
  },
  {
    $sort: { rounded_flight_duration: 1 }
  }
]).forEach(printjson);

// Correlation of Length of stay and Flight Duration
print("3. Correlation of Length of Stay and Flight Duration:");

let stats = db.customer_booking.aggregate([
  {
    $group: {
      _id: null,
      avg_flight_duration: { $avg: "$flight_duration" },
      avg_length_of_stay: { $avg: "$length_of_stay" }
    }
  }
]).toArray()[0];

let avg_flight_duration = stats.avg_flight_duration;
let avg_length_of_stay = stats.avg_length_of_stay;

let correlation = db.customer_booking.aggregate([
  {
    $group: {
      _id: null,
      numerator: {
        $avg: {
          $multiply: [
            { $subtract: ["$flight_duration", avg_flight_duration] },
            { $subtract: ["$length_of_stay", avg_length_of_stay] }
          ]
        }
      },
      flight_duration_variance: {
        $avg: {
          $pow: [{ $subtract: ["$flight_duration", avg_flight_duration] }, 2]
        }
      },
      length_of_stay_variance: {
        $avg: {
          $pow: [{ $subtract: ["$length_of_stay", avg_length_of_stay] }, 2]
        }
      }
    }
  },
  {
    $project: {
      correlation: {
        $divide: [
          "$numerator",
          {
            $sqrt: {
              $multiply: ["$flight_duration_variance", "$length_of_stay_variance"]
            }
          }
        ]
      }
    }
  }
]).toArray()[0].correlation;

print(`Correlation between Flight Duration and Length of Stay: ${correlation}`);



  //Q7 
db.airlines_reviews.aggregate([
    {
        $addFields: {
            Month: { $substr: ["$MonthFlown", 0, 3] } // Extract the month part
        }
    },
    {
        $match: {
            Month: { $in: ["Jun", "Jul", "Aug", "Sep"] } // Match months June to September
        }
    },
    {
        $group: {
            _id: { Airline: "$Airline", Class: "$Class"}, // Group by Airline
            avgSeatComfort: { $avg: "$SeatComfort" }, 
            avgFoodnBeverages : {$avg : "$FoodnBeverages"},
            avgInflightEnterainment : {$avg : "$InflightEntertainment"},
            avgValueForMoney :{ $avg : "$ValueForMoney"},
            avgOverallRating : {$avg: "$OverallRating"}
        }
    },
    {
    $project: {
      Airline: "$_id.Airline",
      Class: "$_id.Class",
      avgSeatComfort: 1,
      avgFoodnBeverages :1,
      avgInflightEnterainment : 1,
      avgValueForMoney : 1,
      avgOverallRating : 1,
      _id: 0
    }
  },
  {
        $sort: { 
            Airline: 1, 
            Class: 1    
        }
  },
  {
      $unionWith: { coll: "airlines_reviews", 
      pipeline: [
        {
            $addFields: {
                Month: { $substr: ["$MonthFlown", 0, 3] } // Extract the month part
            }
        },
        {
            $match: {
                Month: { $nin: ["Jun", "Jul", "Aug", "Sep"] } // Match months June to September
            }
        },
        {
            $group: {
                _id: { Airline: "$Airline", Class: "$Class"}, // Group by Airline
                avgSeatComfort: { $avg: "$SeatComfort" }, 
                avgFoodnBeverages : {$avg : "$FoodnBeverages"},
                avgInflightEnterainment : {$avg : "$InflightEntertainment"},
                avgValueForMoney :{ $avg : "$ValueForMoney"},
                avgOverallRating : {$avg: "$OverallRating"}
            }
        },
        {
        $project: {
          Airline: "$_id.Airline",
          Class: "$_id.Class",
          avgSeatComfort: 1,
          avgFoodnBeverages :1,
          avgInflightEnterainment : 1,
          avgValueForMoney : 1,
          avgOverallRating : 1,
          _id: 0
        }
      },
      {
        $sort: { 
            Airline: 1, 
            Class: 1    
        }
      }
    ] }
  },
])


// Q8 

// Q9 

// Q10 
