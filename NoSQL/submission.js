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