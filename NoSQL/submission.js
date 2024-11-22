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

db.flight_delay.aggregate([
  {
    $match: {
      Cancelled: 1
    }
  },
  {
    $group: {
      _id: "$Airline",
      Status: { $first: "Cancelled" }, 
      count: { $sum: 1 }
    }
  },
  {
    $unionWith: {
      coll: "flight_delay",
      pipeline: [
        {
          $match: {
            $or: [
              { ArrDelay: { $ne: 0 } },
              { DepDelay: { $ne: 0 } },
              { CarrierDelay: { $ne: 0 } },
              { WeatherDelay: { $ne: 0 } },
              { NASDelay: { $ne: 0 } },
              { SecurityDelay: { $ne: 0 } },
              { LateAircraftDelay: { $ne: 0 } }
            ]
          }
        },
        {
          $group: {
            _id: "$Airline",
            Status: { $first: "Delayed" },  
            count: { $sum: 1 }
          }
        }
      ]
    }
  },
  {
    $project: {
      Airline: "$_id",
      Status: 1,
      count: 1,
      _id: 0
    }
  },
  {
    $sort: { Airline: 1 }
  }
]);


//Q4 
db.flight_delay.aggregate([
    {
      $addFields: {
        Month: { $substr: ["$Date", 3, 2] }  
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
    {
      $group: {
        _id: "$Month",
        maxCnt: { $max: "$Cnt" },
        entries: { $push: { Origin: "$Origin", Dest: "$Dest", Cnt: "$Cnt" } }
      }
    },
    {
      $unwind: "$entries"
    },
    {
      $match: {
        $expr: { $eq: ["$entries.Cnt", "$maxCnt"] }
      }
    },
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
db.sia_stock.aggregate([
    {
        $addFields: {
            Year: { $substr: ["$StockDate", 6, 4] },
            Quarter: {
                "$switch": {
                    branches: [
                        { case: { $in: [{ $substr: ["$StockDate", 0, 2] }, ["01", "02", "03"]] }, then: 1 },
                        { case: { $in: [{ $substr: ["$StockDate", 0, 2] }, ["04", "05", "06"]] }, then: 2 },
                        { case: { $in: [{ $substr: ["$StockDate", 0, 2] }, ["07", "08", "09"]] }, then: 3 }
                    ],
                    default: 4
                }
            }
        }
    },
    {
        $addFields: {
            YearQuarter: {
                $concat: [
                    "$Year", "-",
                    { $toString: "$Quarter" }
                ]
            }
        }
    },
    {
        $group: {
            _id: { YearQuarter: "$YearQuarter", Year: "$Year", Quarter: "$Quarter" },
            quarter_end_High: { $avg: "$High" },
            quarter_end_Low: { $avg: "$Low" },
            quarter_avg: { $avg: "$Price" }
        }
    },
    {
        $sort: { "_id.YearQuarter": 1 }
    },
    {
        $setWindowFields: {
            sortBy: { "_id.YearQuarter": 1 },
            output: {
                previous_quarter_high: {
                    $shift: { output: "$quarter_end_High", by: -1 }
                },
                previous_quarter_low: {
                    $shift: { output: "$quarter_end_Low", by: -1 }
                },
                previous_quarter_avg: {
                    $shift: { output: "$quarter_avg", by: -1 }
                }
            }
        }
    },
    {
        $addFields: {
            QoQ_high_change: {
                $cond: {
                    if: {
                        $and: [
                            { $ne: ["$previous_quarter_high", null] },
                            { $ne: ["$previous_quarter_high", 0] }
                        ]
                    },
                    then: {
                        $multiply: [
                            { $divide: [
                                { $subtract: ["$quarter_end_High", "$previous_quarter_high"] },
                                "$previous_quarter_high"
                            ] },
                            100
                        ]
                    },
                    else: null
                }
            },
            QoQ_low_change: {
                $cond: {
                    if: {
                        $and: [
                            { $ne: ["$previous_quarter_low", null] },
                            { $ne: ["$previous_quarter_low", 0] }
                        ]
                    },
                    then: {
                        $multiply: [
                            { $divide: [
                                { $subtract: ["$quarter_end_Low", "$previous_quarter_low"] },
                                "$previous_quarter_low"
                            ] },
                            100
                        ]
                    },
                    else: null
                }
            },
            QoQ_avg_change: {
                $cond: {
                    if: {
                        $and: [
                            { $ne: ["$previous_quarter_avg", null] },
                            { $ne: ["$previous_quarter_avg", 0] }
                        ]
                    },
                    then: {
                        $multiply: [
                            { $divide: [
                                { $subtract: ["$quarter_avg", "$previous_quarter_avg"] },
                                "$previous_quarter_avg"
                            ] },
                            100
                        ]
                    },
                    else: null
                }
            }
        }
    },
    {$match: {"_id.Year" : "2023"}},
    {
        $project: {
            "quarter_end_High": 1,
            "quarter_end_Low": 1,
            "quarter_avg": 1,
            "QoQ_high_change": 1,
            "QoQ_low_change": 1,
            "QoQ_avg_change": 1
        }
    }
]);


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

//Initial method of using recommendations and OverallRating
db.airlines_reviews.find({$or:[{"OverallRating":{$elemMatch: {$lte:5}}}, 
    {"Recommended":"no"}]})
// after adding the json file to collection, we did keyword extraction on the title for complaint columns
db.cleaned_reviews.aggregate([
     { 
    $match: { "complaints": "yes" } 
  },
  { $project: { words: { $split: [ { $toLower: "$Title" }, " " ] } } },
  { $unwind: "$words" },
  { $match: { words: { $nin: ["down","as","too","felt","up","their","them","than","they", "have","are","us","by","that","this","it","not","very","no","me","at","has","an","the", "is", "and", "in", "to", "a", "of", "with", "was", "i", "", "on", "for", "my", "were", "we"] } } },
  { $group: { _id: "$words", count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 100 }
]);

// full-text search for reviews - common complaints 
db.cleaned_reviews.createIndex({ "Reviews": "text" });
//delay
db.cleaned_reviews.aggregate([ 
    {$match:{$text:{$search:"delay late"}}},
    {$match: { "complaints": "yes" } },
    { 
    $group: {"_id":0,
      count: { $sum: 1 }
    }
  }
  ])

//food
db.cleaned_reviews.aggregate([ 
    {$match:{$text:{$search:" tasteless food meal"}}},
    {$match: { "complaints": "yes" } },
    { 
        $group: {"_id":0,
      count: { $sum: 1 }
    }
  }
  ])

//service
db.cleaned_reviews.aggregate([ 
    {$match:{$text:{$search:" service "}}},
    {$match: { "complaints": "yes" } }, 
    { 
       $group: {"_id":0,
      count: { $sum: 1 }
    }
  }
  ])

//seat
db.cleaned_reviews.aggregate([ 
    {$match:{$text:{$search:" seat uncomfortable seats seating"}}},
    {$match: { "complaints": "yes" } },
    { 
       $group: {"_id":0,
      count: { $sum: 1 }
    }
  }
  ])

//entertainemnt
db.cleaned_reviews.aggregate([ 
    {$match:{$text:{$search:" entertainment "}}},
    {$match: { "complaints": "yes" } },
    { 
       $group: {"_id":0,
      count: { $sum: 1 }
    }
  }
  ])

//compensation
db.cleaned_reviews.aggregate([ 
    {$match:{$text:{$search:" compensation refund "}}},
    {$match: { "complaints": "yes" } },
    { 
        $group: {"_id":0,
      count: { $sum: 1 }
    }
  }
  ])

//baggage
  db.cleaned_reviews.aggregate([ 
    {$match:{$text:{$search:" baggage luggage "}}},
    {$match: { "complaints": "yes" } },
    { 
        $group: {"_id":0,
      count: { $sum: 1 }
    }
  }
  ])

//Top 5 issues for each airline and type of traveller
//delay
db.cleaned_reviews.aggregate([ 
    {$match:{$text:{$search:"delay late"}}},
    {$match: { "complaints": "yes" } },
    { 
    $group: {
      _id: { 
        airline: "$Airline", 
        typeofTraveller: "$TypeofTraveller"
      },
      count: { $sum: 1 }
    }
  }
  ])

//food
db.cleaned_reviews.aggregate([ 
    {$match:{$text:{$search:" tasteless food meal"}}},
    {$match: { "complaints": "yes" } },
    { 
    $group: {
      _id: { 
        airline: "$Airline", 
        typeofTraveller: "$TypeofTraveller"
      },
      count: { $sum: 1 }
    }
  }
  ])

//service
db.cleaned_reviews.aggregate([ 
    {$match:{$text:{$search:" service "}}},
    {$match: { "complaints": "yes" } },
    { 
    $group: {
      _id: { 
        airline: "$Airline", 
        typeofTraveller: "$TypeofTraveller"
      },
      count: { $sum: 1 }
    }
  }
  ])

  //seat
db.cleaned_reviews.aggregate([ 
    {$match:{$text:{$search:" seat uncomfortable "}}},
    {$match: { "complaints": "yes" } },
    { 
    $group: {
      _id: { 
        airline: "$Airline", 
        typeofTraveller: "$TypeofTraveller"
      },
      count: { $sum: 1 }
    }
  }
  ])

 //entertainemnt
db.cleaned_reviews.aggregate([ 
    {$match:{$text:{$search:" entertainment "}}},
    {$match: { "complaints": "yes" } },
    { 
    $group: {
      _id: { 
        airline: "$Airline", 
        typeofTraveller: "$TypeofTraveller"
      },
      count: { $sum: 1 }
    }
  }
  ])

//compensation
db.cleaned_reviews.aggregate([ 
  {$match:{$text:{$search:" compensation refund "}}},
  {$match: { "complaints": "yes" } },
  { 
  $group: {
    _id: { 
      airline: "$Airline", 
      typeofTraveller: "$TypeofTraveller"
    },
    count: { $sum: 1 }
  }
}
])

 //baggage
db.cleaned_reviews.aggregate([ 
  {$match:{$text:{$search:" baggage luggage "}}},
  {$match: { "complaints": "yes" } },
  { 
  $group: {
    _id: { 
      airline: "$Airline", 
      typeofTraveller: "$TypeofTraveller"
    },
    count: { $sum: 1 }
  }
}
])

// Q9 

// Q10 
//use associated words to denote exceptional circumstances
db.cleaned_reviews.updateMany({ $text: { $search: "delay miss late weather condition prevent disaster strikes security restrictions defects  typhoon wind turbulence control unrest" } , Airline: "Singapore Airlines", "complaints":"yes"}, {$set:{"exceptional":true}})

//find the issues with exceptional circumstances
db.cleaned_reviews.aggregate([
  {
    $match: {
      "exceptional":true,
      Airline: "Singapore Airlines",
     "complaints":"yes"
    }
  },
  { $project: { words: { $split: [ { $toLower: "$Title" }, " " ] } } },
  { $unwind: "$words" },
  { $match: { words: { $nin: ["down","as","too","felt","up","their","them","than","they", "have","are","us","by","that","this","it","not","very","no","me","at","has","an","the", "is", "and", "in", "to", "a", "of", "with", "was", "i", "", "on", "for", "my", "were", "we"] } } },
  {
    $group: {
      _id: "$words",
      count: { $sum: 1 }
    }
  },
  {
    $sort: {
      count: -1
    }
  },
  {
    $limit: 100
  }
]);

//find significance of each issue
//compensation
db.cleaned_reviews.aggregate([ 
  {$match:{$text:{$search:" compensation refund  remunerate pay"}}},
  {$match: { "complaints": "yes","exceptional":true ,Airline: "Singapore Airlines"}},
  { 
  $group: {"_id":0,
    count: { $sum: 1 }
  }
}])

//communication
db.cleaned_reviews.aggregate([ 
  {$match:{$text:{$search:" communication information customer"}}},
  {$match: { "complaints": "yes","exceptional":true ,Airline: "Singapore Airlines"}},
  { 
  $group: {"_id":0,
    count: { $sum: 1 }
  }
}])

//delay
db.cleaned_reviews.aggregate([ 
  {$match:{$text:{$search:" late delay"}}},
  {$match: { "complaints": "yes","exceptional":true ,Airline: "Singapore Airlines"}},
  { 
  $group: {"_id":0,
    count: { $sum: 1 }
  }
}])
// General chatbot response
// 1. Delete documents not matching specific categories
db.customer_support_with_tone.deleteMany({
  category: { $nin: ['CONTACT', 'CANCEL', 'FEEDBACK', 'INVOICE', 'ORDER', 'PAYMENT', 'REFUND', 'SHIPPING'] }
});

// 2. Count the number of documents in the collection
db.customer_support_with_tone.countDocuments();

// 3. Percentage of Each Instruction Tone
db.customer_support_with_tone.aggregate([
  {
    $group: {
      _id: "$tone_instruction", // Group by instruction tone
      count: { $sum: 1 } // Count the number of occurrences
    }
  },
  {
    $project: {
      instruction_tone: "$_id", // Rename the _id field
      percentage: { $multiply: [{ $divide: ["$count", 9074] }, 100] } // Calculate percentage
    }
  },
  { $sort: { percentage: -1 } } // Sort by percentage in descending order
]);

// 4. Percentage of Each Response Tone
db.customer_support_with_tone.aggregate([
  {
    $group: {
      _id: "$tone", // Group by response tone
      count: { $sum: 1 } // Count the number of occurrences
    }
  },
  {
    $project: {
      response_tone: "$_id", // Rename the _id field
      percentage: { $multiply: [{ $divide: ["$count", 9074] }, 100] } // Calculate percentage
    }
  },
  { $sort: { percentage: -1 } } // Sort by percentage in descending order
]);

// 5. Responses that have fear or sadness tone
db.customer_support_with_tone.find({
  tone: { $in: ['fear', 'sadness'] } // Match documents with tone 'fear' or 'sadness'
}, {
  response: 1, // Include only the 'response' field
  _id: 0 // Exclude the _id field from the result
});

// 6. Number of Instruction Tone and Response Tone
db.customer_support_with_tone.aggregate([
  {
    $match: {
      tone_instruction: { $in: ['anger', 'neutral', 'sadness', 'surprise'] } // Filter for specific instruction tones
    }
  },
  {
    $group: {
      _id: { instruction_tone: "$tone_instruction", response_tone: "$tone" }, // Group by instruction and response tone
      cnt: { $sum: 1 } // Count the number of occurrences
    }
  },
  {
    $sort: { "_id.instruction_tone": 1, cnt: -1 } // Sort by instruction tone and count in descending order
  }
]);

// 7. Response tone that has complaint intent
db.customer_support_with_tone.aggregate([
  {
    $match: { category: "FEEDBACK" } // Filter for 'FEEDBACK' category
  },
  {
    $group: {
      _id: { intent: "$intent", response_tone: "$tone" }, // Group by intent and response tone
      cnt: { $sum: 1 } // Count the number of occurrences
    }
  },
  {
    $sort: { "_id.intent": 1, cnt: -1 } // Sort by intent and count in descending order
  }
]);

