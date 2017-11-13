breed [ curves curve]
breed [ hour_ts hour_t]
globals
[
  year-preset
  BERLIN2000DATA
  BERLIN2001DATA
  BERLIN2002DATA
  BERLIN2003DATA
  BERLIN2004DATA
  BERLIN2005DATA
  BERLIN2006DATA
  BERLINAVERAGEDATA
  ROTHAMSTED2009DATA
  ROTHAMSTED2010DATA
  ROTHAMSTED2011DATA
  outdata
  yearnames
  datacount
  testlist
  testdata
  selection_start
  selection_end
  selection_REP
  
  selected_points
  selection_type
  hidden
  curve_hidden
  
]

hour_ts-own
[
  value
]




to setup
  ca
  create-hour_ts 365
  ask hour_ts [set xcor who + 1 set ycor 0 set color blue set size 1.3 set shape "cylinder"]
  ask patches [ set pcolor 67]
  set YearName "Year1"
  set outdata []
  set yearnames []
  set testlist []
  set datacount 0
  set selected_points []
  set selection_REP " "
  set hours_to_add 0
  set MinDailyTemp 15
  set Day 1
  
  set selection_start -10
  set selection_end -10
  
  set hidden false
  set curve_hidden true

  ask patches with [pxcor = 0 and (pycor < 25 and pycor > -1)]
  [
    set pcolor 0
  ]
  
    ask patches with [pxcor = 366 and (pycor < 25 and pycor > -1)]
  [
    set pcolor 0
  ]
  
  ask patches with [pycor = 25 and (pxcor > -1 and pxcor < 366)]
  [
    set pcolor 0
  ]

  ask patches with [pycor = -1  and (pxcor > -1 and pxcor < 366)]
  [
    set pcolor 0
  ]
  
    ask patches with [pycor = 12  and (pxcor > -1 and pxcor < 366)]
  [
    set pcolor 0
  ]
  
  
  draw_world
  parameterise_data
  
  end


to update_plots
   plot-pen-reset
    let i 0
    repeat 364
  [
    ask hour_t i [plot ycor]
    set i i + 1
  ]
  
  
end

to reset_weather
  ask hour_ts [ set ycor 0 set value 0]
  ask curves [die]
  set curve_hidden true
end
   
   
   
to draw_weather
  if (mouse-down? and round mouse-xcor > -1 and  round mouse-xcor < 364 )  
  [ 
    
    ifelse DrawAbsolute
    [
      ask hour_t ceiling(mouse-xcor)
      [
        set value precision mouse-ycor 2
        if value > 24 [ set value 24 ]
        if value < 0 [ set value 0 ]
        set ycor value
      ]
    ]
    [
      ask hour_t ceiling(mouse-xcor)
       [
         set value random-normal (precision mouse-ycor 2) DrawSD
         if value > 24 [ set value 24 ]
         if value < 0 [ set value 0 ]
         set ycor value
       ]
    ]      
  ]
  
end


to select_period
  
  
  if (mouse-down? and round mouse-xcor > -1 and  round mouse-xcor < 364 )  
  [
    set selection_start mouse-xcor
    if selection_start < 0 [set selection_start 0]
    ask hour_ts [set color blue]
    
    
    while [mouse-down?]
    [
      
      ifelse (mouse-xcor > selection_start)      
      [
        if mouse-xcor < 365
        [
          ask hour_ts with [(xcor <= selection_start and xcor > -1) or (xcor >= mouse-xcor and xcor < 364)  ] [set color blue]
          ask hour_ts with [(xcor > selection_start and xcor < mouse-xcor)] [set color white]
          
        ]
              
      ]    
      [
        if mouse-xcor > -1
        [
        ask hour_ts with [(xcor >= selection_start and xcor < 365) or (xcor <= mouse-xcor and xcor > -1) ] [set color blue]
        
        ask hour_ts with [xcor < selection_start and xcor > mouse-xcor] [set color white]
        
        ]
      ]
          
    ]

   
    set selection_end mouse-xcor
    set selection_type "selection"
    set Period "Selection"
    if selection_end > 365 [set selection_end 365]
    if selection_end < 0 [ set selection_end -1]
    
    if selection_end < selection_start 
    [
      let temp selection_start
      set selection_start selection_end
      set selection_end temp
    ] 
        
    set selected_points  hour_ts with [xcor > selection_start and xcor < selection_end]
    ask selected_points [set color red]
    
    ;ask patches with [ pycor < 25 and pycor > -1 and (pxcor > -1 and pxcor < 365) ] [set pcolor 67]
  ]
  
    ask patches with [pxcor = -1 and (pycor < 25 and pycor > -1)]
  [
    set pcolor 0
  ]
  
    ask patches with [pxcor = 365  and (pycor < 25 and pycor > -1)]
  [
    set pcolor 0
  ]
  
  reset_scale
  selection_REP_set


end
  
to reset_scale
    ask patches with [pycor = 12  and (pxcor > -2 and pxcor < 366)]
  [
    set pcolor 0
  ]
end
  
  
to make_selection
   set selection_start SelectionStart
   set selection_end SelectionEnd
   ask hour_ts with [xcor > selection_start and xcor < selection_end] [set color red]
end


  
to clear_selection
  set selected_points []
  set selection_start -10
  set selection_end -10
  ask hour_ts [set color blue]
  set selection_REP " "  
end
  
 
to save_year

  ifelse YearName = ""
  [
    user-message "Please enter a name for this year's data"
  ]
  [
  
      if user-yes-or-no? (word "Save this year as " YearName "?")
      [
         let tempdata []
         foreach (sort-on [who] hour_ts)
         [
           ask ? [set tempdata lput ([ycor] of ?) tempdata]
           
         ]
         
         set outdata lput tempdata outdata; ([ycor] of hour_ts) outdata
         set yearnames lput YearName yearnames
         set datacount datacount + 1
     
         output-print (word datacount") " YearName)
     ]
  ]
  reset_weather
  ask curves [die]
  set curve_hidden true
end


to clear_last_year
  if user-yes-or-no? "Clear last year data?"
  [
    set outdata but-last outdata
    set yearnames but-last yearnames
    set datacount 0
    clear-output
    foreach yearnames
    [
     set datacount datacount + 1    
     output-print (word datacount ") " ?)
    ]
    
   ]
  
end

to clear_data
  
  if user-yes-or-no? "Clear data?"
  [
  set outdata []
  set datacount 0
  clear-output  
  reset_weather
  ]
end

to create-output-file

  if is-string? OutputFileName
  [
  
  if user-yes-or-no? (word "Save weather file as " OutputFileName "?")
  
  [
  if file-exists? OutputFileName
  [
     file-delete OutputFileName
  ]
  
  let iter 0
  file-open OutputFileName
  foreach outdata
  [
    file-print (?)
    set iter iter + 1
    
  ]
  file-close-all
  ]
  
  
  ]
end


to data_curve
  
  ifelse curve_hidden = true
  [
   set curve_hidden false
  let i 3
  let curve []
  set curve lput sum([ycor] of hour_ts with [xcor = 0]) curve
  set curve lput (sum([ycor] of hour_ts with [xcor = 0 or xcor = 1]) / 2) curve
  set curve lput (sum([ycor] of hour_ts with [xcor = 0 or xcor = 1 or xcor = 2]) / 3) curve
  let counter [ 0 1 2 ]
  
  ask curves [die]
  repeat 359
  [
    set counter lput i counter
    ifelse i < 7 or i > 350
    [
    set curve lput (sum ([ycor] of hour_ts with [xcor >= (i - 2) and xcor <= (i + 2)]) / 5) curve
    ]
    [
    set curve lput (sum ([ycor] of hour_ts with [xcor >= (i - 3) and xcor <= (i + 3)]) / 7) curve  
    ]
    set i i + 1
  ]
  
  set curve lput sum([ycor] of hour_ts with [xcor = 364]) curve
  set curve lput (sum([ycor] of hour_ts with [xcor = 364 or xcor = 363]) / 2) curve
  set curve lput (sum([ycor] of hour_ts with [xcor = 364 or xcor = 363 or xcor = 362]) / 3) curve
  
  set counter lput 364 counter
  set counter lput 363 counter
  set counter lput 362 counter
  
   
  
  create-curves 365 [ set color red set size 0.1]
  let curvelist []
  ask curves 
  [
    set curvelist lput self curvelist
  ]
  
;  show length counter
;  show length curvelist
;  show length curve
  
  (foreach curvelist counter
  [
    ask ?1
    [
       setxy ?2 (item ?2 curve)
    ]
  ])
  
  ask curves
  [
    if xcor != 364
    [
      create-links-with curves with [xcor = ([xcor] of myself + 1)]
      ask links [set thickness 0.5]
    ]
  ]
    
  ]
  [
  
    set curve_hidden true
    ask curves [die]
  ]
  end
  
    
  
  
 to hide_plot
   
   ifelse hidden = false
   [
     set hidden true
     ask hour_ts[ht]
   ]
   [
     set hidden false
     ask hour_ts[st]
   ]
     
 end
  
  
 to select_group
   
  let start_date 0
  let end_date 0
  ask hour_ts [set color blue]
  

     if Period = "Day" [ set start_date  Day set end_date Day set selection_type "day"]
     if Period = "Week" [ set start_date  Day set end_date Day + 7 set selection_type "week"]
     if Period = "Month" [
  
  
  if Month = "January" [set start_date 1 set end_date 31]
  if Month = "February" [set start_date 32 set end_date 60]
  if Month = "March" [set start_date 61 set end_date 91]
  if Month = "April" [set start_date 92 set end_date 121]
  if Month = "May" [set start_date 122 set end_date 152]
  if Month = "June" [set start_date 153 set end_date 182]
  if Month = "July" [set start_date 183 set end_date 213]
  if Month = "August" [set start_date 214 set end_date 244]
  if Month = "September" [set start_date 245 set end_date 274]
  if Month = "October" [set start_date 275 set end_date 305]
  if Month = "November" [set start_date 306 set end_date 335]
  if Month = "December" [set start_date 336 set end_date 365]
  set selection_type "month"
     ]
  
  if Period = "Week"
  [
    set start_date Day set end_date Day + 6
  ]
  
     if Period = "Season"
     [
         if Season = "Spring" [set start_date 61 set end_date 152]
         if Season = "Summer" [set start_date 153 set end_date 244]
         if Season = "Autumn" [set start_date 245 set end_date 335]
         if Season = "Winter" [set start_date 336 set end_date 60]
         set selection_type "season"
  
     ]
     
     if Period = "Year"
     [
       set start_date 1 set end_date 365
       set selection_type "year"
     ]
     
     if Period = "Selection"
     [
       set start_date selection_start
       set end_date selection_end
       set selection_type "selection"
     ]
     
     if Period = "Between"
     [
       set start_date SelectionStart
       set end_date SelectionEnd
       set selection_type "between" 
     ]
   
   ifelse start_date <= end_date
   [
     set selected_points hour_ts with [xcor >= start_date and xcor <= end_date]
     
   ]
   [
     set selected_points hour_ts with [xcor <= start_date and xcor >= end_date]
   ]

   
   ask selected_points [set color red]
   selection_REP_set
 end



;;******************************************************************************
to NoForagingProc
 ifelse selected_points = []
 [ user-message "No Points Selected" ]
 [
   ask selected_points
   [
     if random-float 1 < NonForagingProb
     [
       set value 0
       set ycor 0
     ] 
   ] 
 ] 
end

;;******************************************************************************

to add_one [add_amount]
 ifelse selected_points = []
  [
    user-message "No Points Selected"
  ]
  [
    ask selected_points
    [
      set value value + add_amount
      ifelse value > 24 
       [ set ycor 24 ]
       [
         ifelse value < 0 
          [ set ycor 0 ]
          [ set ycor value ]
       ]
      set value ycor
    ]
  ]
end


to add_to_selection
  
   ifelse selected_points = []
  [
    user-message "No Points Selected"
  ]
  [
    
  ifelse hours_to_add > 0
  [
  repeat hours_to_add
  [
    if count selected_points with [ycor < 24] > 0
    [ 
      ask one-of selected_points with [ycor < 24]
       [ set value value + 1 ]     
    ]
  ]
  ]
  [
    set hours_to_add (-1 * hours_to_add)
     repeat hours_to_add
  [
    ask one-of selected_points with [ycor > 0]
    [
      set value value - 1
      
    ]
  ]
  ]
  ]
    ask hour_ts 
    [ 
      if value > 24 [ set value 24 ]
      if value < 0 [ set value 0 ] 
      set ycor value 
    ]
end

to set_selection
    ifelse selected_points = []
  [
    user-message "No Points Selected"
  ]
  [
  ask selected_points
  [
    set value random-normal select_mean select_sd
      
    ifelse value > 24 [set ycor 24]
    [
    ifelse value < 0 [set ycor 0]
    [
      set ycor value
    ]
    ]
    set value ycor
  ]
  ]
  
end

to average_selection
  ifelse selected_points = []
  [ user-message "No Points Selected" ]
  [
    let newMean mean [value] of selected_points
    let newSD standard-deviation [value] of selected_points
    if definedSD = true [ set newSD average_sd ]
    ask selected_points
    [
      set value random-normal newMean newSD
      if value > 24 [ set value 24 ]
      if value < 0 [ set value 0 ]
      set ycor value
    ]
  ]
end


to selection_REP_set
    if selection_type = "day" [set selection_REP replace-item 4 "Day: " (word Day)]
    if selection_type = "week" [set selection_REP replace-item 16 "1 Week; w/c day: " (word Day)]
    if selection_type = "month" [set selection_REP word "Month: " Month ]
    if selection_type = "season" [set selection_REP word "Season: " Season]
    if selection_type = "year" [set selection_REP "Whole Year"]
    if selection_type = "selection" [set selection_REP replace-item 19 (replace-item 28 "Selection from day   to day     " (word precision selection_end 0)) (word precision selection_start 0 )]
    if selection_type = "between"   [set selection_REP replace-item 12  (replace-item 22 "Between day   and day     " (word precision SelectionEnd 0)) (word precision SelectionStart 0 )]
end



to set_weather

let data []

ask curves [die]
set curve_hidden true


if WeatherPresets = "Input File"
[
  file-open InputFilename
  
  let garbage []
  let temp 0
  let sun 0
  
  set garbage file-read-line
  
  while [not file-at-end?]
  [
  
    set garbage file-read 
    
    set temp file-read
    set sun file-read 
    
    ifelse (temp) >= MinDailyTemp
    [
      set data lput sun data
    ]
    [
      set data lput 0 data
    ]
  ]
  
  
       foreach sort hour_ts
    [
      ask ?
      [
        set value (item who data)
        set ycor value
      ]
    ]
    
    
    
 file-close-all
 
]
if WeatherPresets = "YearData"
[
    
    if YearData = "Berlin 2000" [ set data BERLIN2000DATA set YearName "Berlin 2000"]
    if YearData = "Berlin 2001" [ set data BERLIN2001DATA set YearName "Berlin 2001"]
    if YearData = "Berlin 2002" [ set data BERLIN2002DATA set YearName "Berlin 2002"]
    if YearData = "Berlin 2003" [ set data BERLIN2003DATA set YearName "Berlin 2003"]
    if YearData = "Berlin 2004" [ set data BERLIN2004DATA set YearName "Berlin 2004"]
    if YearData = "Berlin 2005" [ set data BERLIN2005DATA set YearName "Berlin 2005"]
    if YearData = "Berlin 2006" [ set data BERLIN2006DATA set YearName "Berlin 2006"]
    if YearData = "Berlin Average" [ set data BERLINAVERAGEDATA set YearName "Berlin Average"]
    if YearData = "Rothamsted 2009" [ set data ROTHAMSTED2009DATA set YearName "Rothamsted 2009"]
    if YearData = "Rothamsted 2010" [ set data ROTHAMSTED2010DATA set YearName "Rothamsted 2010"]
    if YearData = "Rothamsted 2011" [ set data ROTHAMSTED2011DATA set YearName "Rothamsted 2010"]

 
     foreach sort hour_ts
    [
      ask ?
      [
        set value (item who data)
        set ycor value
      ]
    ]
 
]

if WeatherPresets = "UkMonthlyAverages"
[
 
  let Tmax []
  let Sun []
  let TmaxStd [3 4 2 2 3 4 2 2 2 2 3 4]
  let SunStd  [2 3 3 4 4 4 3 3 3 2 2 2]
  ask hour_ts
  [
    set value 0
    set ycor value
  ]
  
 if Station = "Camborne"
 [
  if UkMonthlyAverages = 1982 [ set Tmax [8.9 9.2 9.9 12 14.2 17 18.9 18.2 17.4 13.3 11.4 9.1] set Sun [41.9 68.6 167.9 227.1 2.8 169.9 173.9 141.9 126.4 72.6 73.7 38.4]]
  if UkMonthlyAverages = 1983 [ set Tmax [9.8 6.3 9.6 10.1 12.5 16.3 21.7 2.8 16.8 13.9 11.4 10.4] set Sun [32.8 79.6 82.6 178.4 181.7 173 253.1 234.5 111.5 105.3 47.6 64.6]]
  if UkMonthlyAverages = 1984 [ set Tmax [8.9 8.1 8.3 12.7 12.6 16.4 19.9 20.3 16.9 14.3 11.5 10] set Sun [51.9  68.9  130.2  257.2  204  211.9  279.7  213.6  158.5  101.3  63.7  72.2]]
  if UkMonthlyAverages = 1985 [ set Tmax [6.1 7.9 9 11.7 13.6 15.4 18.3 16.8 17.4 14.3 9.3 10.4] set Sun [81.3  74.8  133.1  180.7  211  191.5  187.5  149.8  147.4  110.8  80.7  48.2]]
  if UkMonthlyAverages = 1986 [ set Tmax [8.7 3.1 9.4 8.7 12.7 16.3 17.6 15.8 14.9 14.4 11.6 10.4] set Sun [49.6  50.5  120.3  189.6  210.1  195.7  147.4  140.1  167.3  100.6  82.9  53]]
  if UkMonthlyAverages = 1987 [ set Tmax [5.5 8 8.6 13.1 12.8 15 18.5 18.7 17.2 13.3 10.9 9.6] set Sun [53.1  70.8  122.7  180.3  231.1  122.8  230.2  213.9  125.4  122  75.3  41.7]]
  if UkMonthlyAverages = 1988 [ set Tmax [10 8.8 9.7 11.5 14 16.8 16.5 17.7 16 14.2 11.2 11 ] set Sun [64  103.6  96.2  142.1  222.9  195.5  161.6  173.3  142.9  91.9  105.1  20.1]]
  if UkMonthlyAverages = 1989 [ set Tmax [10.2 10 10.9 10.4 16.8 17. 20.9 20.2 17.2 15 11.3 10] set Sun [59.5  94.8  90  192.1  282.2  281.7  295.8  251.2  142  84.7  98  52]]
  if UkMonthlyAverages = 1990 [ set Tmax [ 10.4 11.1 11.3 11.5 16.5 16.3 19.7 20.3 17.6 15 10.8 8.6] set Sun [48.3  65.2  139.9  213.7  278.5  177.2  308.4  200.3  184.6  90  107.3  62.6]]
  if UkMonthlyAverages = 1991 [ set Tmax [7.8  6.7  10.6  11  13.2  14.7  17.8  19.2  18.3  13.3  10.8  9.4] set Sun [67.2  90  114.4  165.6  206.6  157.8  124.7  204.1  173.9  83.5  61.5  55.4]]
  if UkMonthlyAverages = 1992 [ set Tmax [7.8  9.2  10.3  11.2  15.6  17.8  19  17.9  15.7  12.1  12.1  8.7] set Sun [73.9  71.6  83.8  135  245.6  237.4  178.2  146.1  101.2  113.6  44.7  48.1]]
  if UkMonthlyAverages = 1993 [ set Tmax [10.5  8.6  10.2  12.4  14.1  16.8  17.3  18  16.1  12  10.2  10.3] set Sun [42  60.7  109.6  152.2  184.6  200.1  176.1  218.3  168.8  143.7  81.2  45.6]]
  if UkMonthlyAverages = 1994 [ set Tmax [9.5  9.1  10.6  10.9  13.6  16.2  19.2  18.5  16.1  14.8  13.4  11.4] set Sun [58.7  71.8  76.9  182.3  168.8  238.7  194.5  174.1  123.3  150  39.6  63.1]]
  if UkMonthlyAverages = 1995 [ set Tmax [9.9  10.4  9.2  11.2  14.9  17.2  20.7  22.5  16.9  16.1  12  8.8] set Sun [34.8  53.8  137.1  169.2  232.8  257.5  233.5  254.1  164.8  119.2  80.6  60.7]]
  if UkMonthlyAverages = 1996 [ set Tmax [9  7.9  8.9  11.5  12.4  16.9  18.5  18.6  17.2  14.7  10.9  7.4] set Sun [44.9  137  93.6  159.9  213.8  256.1  250  242.4  187.4  85.8  76.2  67.8]]
  if UkMonthlyAverages = 1997 [ set Tmax [6.4  10.6  11.1  13.1  15.1  15.8  19  20.5  17.9  15.5  12.8  10.4] set Sun [56.6  67.4  141.3  241  283.9  125.4  243  150.1  185.1  104.4  62.5  86.2]]
  if UkMonthlyAverages = 1998 [ set Tmax [9.6  10.8  11  10.7  15.6  16.2  17.1  18.8  17.7  14.6  10.9  10.3] set Sun [87  109.7  78.1  155.2  226.3  184.9  163.7  250.1  146.3  114.7  87.3  66]]
  if UkMonthlyAverages = 1999 [ set Tmax [10.1  9.6  10.5  12.2  15.5  16  19.5  19.2  18.3  14.6  11.7  10.1] set Sun [68.6  62  137.5  172.1  174.6  206.2  246.1  192.1  173.7  144.1  101  48.9]]
  if UkMonthlyAverages = 2000 [ set Tmax [8.7  10.2  10.3  11.1  15  16.7  18  19.7  18.1  13.5  10.7  9.9] set Sun [79.8  73.9  150.4  178.9  175.6  175.4  197.6  170.6  144.3  96.8  68.4  54.7]]
  if UkMonthlyAverages = 2001 [ set Tmax [8.5  9.3  10.2  11.1  15.1  17.1  18.6  19.3  17.3  16.3  12.2  8.9] set Sun [61.2  103.4  80.4  157.9  283.7  257.3  189.2  202.7  158.2  118.2  79.4  92.8]]
  if UkMonthlyAverages = 2002 [ set Tmax [10.4  10.4  11  12  13.8  14.8  17.2  18.1  18.1  14.5  12.6  9.8] set Sun [49.1  81  102.6  191.7  215.3  153.9  185.1  169.3  217.9  95.1  67.5  46.4]]
  if UkMonthlyAverages = 2003 [ set Tmax [8.4  8.7  11.2  13.2  14  17.4  19  21  18.7  13.7  12.5  10.1] set Sun [76.9  99.2  155.6  210.5  197.3  236.6  131  211.2  183.1  124.3  85.2  51.9  ]]
  if UkMonthlyAverages = 2004 [ set Tmax [9.8  8.8  10  11.9  15  18  17.6  19.5  17.8  13.7  11.6  10.3] set Sun [58.1  101  140.7  172  265.7  244.8  162.1  200.2  145.6  118.2  45.1  42]]
  if UkMonthlyAverages = 2005 [ set Tmax [9.9  7.6  10.1  11.8  13.2  17.5  18.9  19.4  18.1  15.4  11.6  9.5] set Sun [47.8  95.7  100.1  166.7  189.7  202.9  178.6  258.6  148.4  106.4  99.2  68.3]]
  if UkMonthlyAverages = 2006 [ set Tmax [8.1  7.3  8.7  11.5  14.2  18.7  21.3  18.9  19.3  16.2  12.6  10.7  ] set Sun [75.6  59.6  76  177.9  182.1  278  246.5  188  155.6  114.9  103  55.6]]
  if UkMonthlyAverages = 2007 [ set Tmax [10.5  10.3  10.8  14.7  14.7  17.3  17.2  18.1  17.3  15.2  11.9  10.5] set Sun [55.5  63.9  147.1  220.9  188.5  154.9  190.3  239.5  173.7  126.5  60.9  63.3]]
  if UkMonthlyAverages = 2008 [ set Tmax [10.5  10.3  10  11.1  16.3  16.1  17.7  18  16.7  13.6  10.9  8.8] set Sun [43.3  115.1  128.3  190.6  197.4  264.4  182.7  101.6  173.5  125.2  64.4  69.9]]
  if UkMonthlyAverages =  2009 [ set Tmax [8.1  8  10.6  12.2  14.4  18.2  17.9  18.2  16.8  15.2  12.3  8.6] set Sun [72.3  56.5  173.9  180.4  199.8  251  156.4  123.9  163.4  96.2  56.7  80.5]]
  if UkMonthlyAverages = 2010 [ set Tmax [6.7  7.7  9.4  12.3  14.1  17.9  18.6  18.1  17.3  14.7  10.2  6.3] set Sun [103.9  95.9  139.2  231  209.9  286  117.7  154.6  144.9  148.2  84.8  90.9]]
  if UkMonthlyAverages = 2011 [ set Tmax [8.1  10.3  10.9  15  14.6  15.9  17.6  17.6  17.6  15.5  13.4  10.3] set Sun [83  58.5  147.4  239  169.8  202.7  175.8  149.4  138.9  92.4  74.6  28.8]]
  if UkMonthlyAverages = 2012 [ set Tmax [9.9  8.8  11.9  10.7  14.5  15.7  17.3  19  16.4  14  11  10] set Sun [55.1  74.7  159.4  153.8  179.3  108.6  174.8  136.3  147.1  91.8  61.9  37.4]]
   if UkMonthlyAverages = 2013 [ set Tmax [8.9  7.7  7.5  10.3  12.5  15.9  20.8  19.2  17.3  15.8  11  10.7] set Sun [50.4  80.2  89.1  160.5  227.2  190.2  278.3  173.3  114.4  76.5  60.1  44.5]]
 ]
 
 if Station = "Oxford"
 [
  if UkMonthlyAverages = 1982 [ set Tmax [5.5  7.9  10.3  13.8  17.5  21.3  22  21.2  20.1  13.6  10.8  7.7] set Sun [55  33.8  144.7  164.4  187.2  148.4  151.4  159.8  141  66.3  68.5  60.4]]
  if UkMonthlyAverages = 1983 [ set Tmax [9.8  4.8  10.3  11.8  14.8  19.6  26.8  23.5  18  14.3  10.4  8.7] set Sun [54.9  74  89.5  150.5  126.8  180.3  257.5  214.5  92.4  119.7  44.3  62.9]] 
  if UkMonthlyAverages = 1984 [ set Tmax [7.5  6.4  8.2  13.9  14.5  20.8  23.9  23.6  17.9  15  11.3  8.3] set Sun [86.1  66  48.8  236.8  143.4  244.3  249.4  199.8  99.6  88.6  53.8  57.6]]
  if UkMonthlyAverages = 1985 [ set Tmax [3.9  5.5  8.9  13.1  15.7  17.5  21.6  19  19.4  14.5  7.4  9.4] set Sun [51.1  78  112.4  138.3  178.3  165  216  164.9  143.3  100.8  86.1  44.2]]
  if UkMonthlyAverages = 1986 [ set Tmax [6.7  1  9.2  10.2  15.7  20.6  21.5  18.4  16.6  15.3  11.4  9.2] set Sun [76.4  71.2  127.3  139.6  205.6  222.7  201.2  147  171.6  119.7  77.9  64.8]]
  if UkMonthlyAverages = 1987 [ set Tmax [3  7.1  8.2  15.2  15.2  17.8  21.2  21  18.6  14  9  8] set Sun [68.8  67.8  111.6  158.7  168.7  129.3  179.4  158.2  132.3  109.5  43.9  42.9]]
  if UkMonthlyAverages = 1988 [ set Tmax [8.1  8.1  10.2  12.6  17.1  18.7  18.9  20.4  17.9  14.5  9.1  10.1] set Sun [47.7  103.7  85.2  132  178.1  142.3  138.8  178.8  136.9  120  91.4  46.7]]
  if UkMonthlyAverages = 1989 [ set Tmax [9.1  9.9  12  11  19.7  20.8  24.9  23.4  19.9  15.9  9.8  8.2] set Sun [68.2  107  100.9  133.9  300.8  244.4  280.4  269.5  141.6  90.8  104.1  26.5]]
  if UkMonthlyAverages = 1990 [ set Tmax [10  11.3  12.7  13.7  19.2  18.2  23.8  24.7  18.7  15.8  9.8  6.9] set Sun [58.3  95.7  144.1  234.4  285  121.1  268.5  236.6  164.7  124.4  83.7  58.8]]
  if UkMonthlyAverages = 1991 [ set Tmax [6.4  4.7  11.5  12.2  15.3  16.8  22.2  23.2  20.2  13.4  9.9  7] set Sun [66.9  60  87.2  156.6  142.9  150  217.3  241.4  165.4  79.4  57.4  58.4]]
  if UkMonthlyAverages = 1992 [ set Tmax [5.9  8.9  11  13.2  19.7  21.4  21.1  20.3  17.6  11.2  10.9  6.4] set Sun [46.8  67.3  73.3  139.2  262.7  212.2  164  173.6  120.2  101.3  61.5  47.2]]
  if UkMonthlyAverages = 1993 [ set Tmax [9.6  7.1  11  13.2  16.6  20.7  20.8  20.5  16.7  11.9  8  8.7] set Sun [38  54.7  135  111.9  196.7  231.4  190  238.3  107.7  120  76.3  55]]
  if UkMonthlyAverages = 1994 [ set Tmax [8.5  6.7  11.7  12.5  15.3  20.6  24.8  21.1  16.6  14.1  12.7  9.6] set Sun [87  77.6  127.6  177.7  162.1  254.9  248.3  191.8  113.1  137.5  46.7  68.2]]
  if UkMonthlyAverages = 1995 [ set Tmax [8.5  10.4  10.5  14.3  17.8  20  25.1  26.4  18.3  17.3  11.3  4.6] set Sun [61.8  74.9  198.7  190.1  233.5  194.4  247.6  285.1  135.3  139.9  78.1  40.9]]
  if UkMonthlyAverages = 1996 [ set Tmax [6.6  6.2  8.4  13.8  14.1  21.2  23.3  22.4  18.4  15.8  9.6  5.5] set Sun [29.3  103.4  76.4  148.3  185.7  290.7  256.6  211.6  125.3  130.8  101  55.5]]
  if UkMonthlyAverages = 1997 [ set Tmax [5.1  10.4  13.3  14.5  17.4  18.9  22.8  24.9  19.7  14.9  11.7  9] set Sun [51.4  64.2  150.2  189.9  261.4  137.1  231.7  172  169.7  153.8  47.1  55.7]]
  if UkMonthlyAverages = 1998 [ set Tmax [8.3  11.5  11.8  11.9  18.7  19.1  21  22.4  19.6  14.4  9.3  9.4] set Sun [64  113  77.5  105.8  199.8  114  157  225  133.8  94.5  66.3  38.1]]
  if UkMonthlyAverages = 1999 [ set Tmax [9  8.6  11.6  14.3  18.2  19.7  24.2  21.6  20.8  15.1  10.8  8.3] set Sun [51.1  81.3  97.4  147.6  153.6  202.1  235.4  159.2  155.2  144.8  81.1  60.9]]
  if UkMonthlyAverages = 2000 [ set Tmax [8.1  10.2  11.7  12.4  17.2  20.5  20.8  22.7  19.2  14.3  10.6  8.6] set Sun [82.1  104.9  112.6  143.4  189.8  164.6  161.2  209.4  126.1  83.9  69.2  51.9]]
  if UkMonthlyAverages = 2001 [ set Tmax [6.4  8.8  9  12.9  18.5  20.7  23.4  22.7  17.9  17  11.2  6.8] set Sun [83.3  85  74.1  148.2  198.3  226.8  206.1  184.1  123  100.9  86.9  79.2]]
  if UkMonthlyAverages = 2002 [ set Tmax [9.2  11.1  12.4  15.2  16.8  20  22.1  22.8  19.7  14.8  11.8  8.9] set Sun [44.4  80.5  101.1  210  177.5  163.3  178.8  166.2  167.1  104.8  52.3  41.3]]
  if UkMonthlyAverages = 2003 [ set Tmax [7.6  8.4  13.3  15.3  17.5  22.4  23.7  25.5  21.3  14  12  8.7] set Sun [87.7  94.4  154.8  169.8  191.2  213.6  192  228.4  175.3  134.8  78.9  53.6]]
  if UkMonthlyAverages = 2004 [ set Tmax [8.8  8.7  10.9  14.7  18  21.8  22  23.4  20.1  14.7  10.9  8.6] set Sun [62.7  79.1  101.5  150.3  195.5  223.6  169.5  194.1  174.4  102.4  52.4  58.3]]
  if UkMonthlyAverages = 2005 [ set Tmax [9.4  7.3  11.2  14.3  17.2  21.6  22.3  23.1  20.9  17.1  9.9  7.7] set Sun [65.4  66.3  79.3  136.3  226.4  177.6  192  235.7  155.4  92  88  55.7]]
  if UkMonthlyAverages = 2006 [ set Tmax [7.2  6.6  9.2  13.9  17.6  23.1  27.1  21.8  22.1  17.2  12.1  9.4] set Sun [54.9  73.1  95.5  152.5  165.7  246.2  303.7  167.2  156.5  109  101.2  42.7]]
  if UkMonthlyAverages = 2007 [ set Tmax [10.4  9.7  12  17.8  17.5  20.5  20.6  21.7  19.2  15.1  11.3  8.3] set Sun [79.8  67.6  165.4  210.7  165.5  149  195.1  209.2  142.6  102.5  86.9  57.2]]
  if UkMonthlyAverages = 2008 [ set Tmax [10.3  10.5  10.6  13.1  18.7  20.1  22  20.8  17.8  14.6  10.1  6.9] set Sun [62.4  124.1  115.2  161.2  173.2  223.8  198.5  141.8  113.5  132.2  67  73.5]]
  if UkMonthlyAverages = 2009 [ set Tmax [6.3  7.9  12.4  15.6  18.2  22  22.4  22.7  20.2  16.2  12.5  6.8] set Sun [69.3  64.5  161.4  168.4  226.1  203.3  212.3  190.6  163.7  109.7  73.5  61.5]]
  if UkMonthlyAverages = 2010 [ set Tmax [4.7  7.1  11.3  15.8  17.6  23  23.9  21.4  18.8  14.5  8.2  2.7] set Sun [68.2  59.3  130.2  209.5  207.4  230.5  181  141.7  123.1  123.5  53.6  25.8]]
  if UkMonthlyAverages = 2011 [ set Tmax [7  10.4  12.4  19.4  18.9  19.3  21.4  20.7  20.7  17.2  13.5  9.3] set Sun [49.3  34.2  141.5  211.4  208.7  188.5  179.4  157.8  151.7  130.6  64.8  62.6]]
  if UkMonthlyAverages = 2012 [ set Tmax [9.8  7.3  14  12.6  17.7  18.9  20.5  21.8  18.4  13.4  10.1  8.6] set Sun [85.7  71.7  164.3  135.1  185.6  128.3  178.2  168.4  173.2  85.5  74  61.7]]
  if UkMonthlyAverages = 2013 [ set Tmax [6.4  6.2  6.3  12.9  15.9  19.3  25.5  23.1  19  16.3  9.9  10] set Sun [47.8  72.3  60.7  177  193.6  181.3  297.3  205.9  123.1  101.8  85.7  63.6]]
  
 ]
  
  ; Stdev Values are Stdev of month values from Rothamsted Data 2009

     
    
    
    let imonth 1
    let start_date 0
    let end_date 0
   
   
    (foreach Tmax Sun TmaxStd SunStd      
    [
 
    if imonth = 1 [set start_date 1 set end_date 31]
    if imonth  = 2 [set start_date 32 set end_date 60]
    if imonth = 3 [set start_date 61 set end_date 91]
    if imonth = 4 [set start_date 92 set end_date 121]
    if imonth = 5 [set start_date 122 set end_date 152]
    if imonth = 6 [set start_date 153 set end_date 182]
    if imonth = 7 [set start_date 183 set end_date 213]
    if imonth = 8 [set start_date 214 set end_date 244]
    if imonth = 9 [set start_date 245 set end_date 274]
    if imonth = 10 [set start_date 275 set end_date 305]
    if imonth = 11 [set start_date 306 set end_date 335]
    if imonth = 12 [set start_date 336 set end_date 365]
    
    ask hour_ts with [xcor >= start_date - 1 and xcor < end_date]
    [
    ifelse UseStdevValues
    [
      ifelse random-normal ?1 ?3 >= MinDailyTemp
      [
        set value random-normal (?2 / 30) ?4
        if value > 24 [set value 24]
        if value < 0 [set value 0]
        set ycor value
      ]
      [
        set value 0
        set ycor value
      ]
      
    ]
    [
      if ?1 >= MinDailyTemp
      [
        set value (?2 / 30)
        set ycor value
      ]
    ]
        

     ]
    set imonth imonth + 1
    ])

    ]




if WeatherPresets = "Monthly Inputs"
[
  
  
  
    let imonth 1
    let start_date 0
    let end_date 0
   
    repeat 12   
    [
 
    if imonth = 1 [set start_date 1 set end_date 31]
    if imonth  = 2 [set start_date 32 set end_date 60]
    if imonth = 3 [set start_date 61 set end_date 91]
    if imonth = 4 [set start_date 92 set end_date 121]
    if imonth = 5 [set start_date 122 set end_date 152]
    if imonth = 6 [set start_date 153 set end_date 182]
    if imonth = 7 [set start_date 183 set end_date 213]
    if imonth = 8 [set start_date 214 set end_date 244]
    if imonth = 9 [set start_date 245 set end_date 274]
    if imonth = 10 [set start_date 275 set end_date 305]
    if imonth = 11 [set start_date 306 set end_date 335]
    if imonth = 12 [set start_date 336 set end_date 365]
    
    ask hour_ts with [xcor >= start_date - 1 and xcor < end_date]
    [
        let newycor 0
        if imonth = 1 [set newycor random-normal JanMean JanSD ]
        if imonth = 2 [set newycor random-normal FebMean FebSD ]
        if imonth = 3 [set newycor random-normal MarMean MarSD ]
        if imonth = 4 [set newycor random-normal AprMean AprSD ]
        if imonth = 5 [set newycor random-normal MayMean MaySD ]
        if imonth = 6 [set newycor random-normal JunMean JunSD ]
        if imonth = 7 [set newycor random-normal JulMean JulSD ]
        if imonth = 8 [set newycor random-normal AugMean AugSD ]
        if imonth = 9 [set newycor random-normal SepMean SepSD ]
        if imonth = 10 [set newycor random-normal OctMean OctSD ]
        if imonth = 11 [set newycor random-normal NovMean NovSD ]
        if imonth = 12 [set newycor random-normal DecMean DecSD ]
        if newycor < 0 [ set newycor 0]
        if newycor > 24 [ set newycor 24]
        set ycor newycor

     ]
    set imonth imonth + 1
  
    ]





 ]
  
 ask hour_ts 
 [
   if ycor < 0 [ set ycor 0]
   if ycor > 24 [ set ycor 24] 
 ]
 end


to-report MinDailyTempRep
  report "Minimum Daily Temperature for Foraging (C)"
end

to parameterise_data
  
   set BERLIN2000DATA
   [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0   
      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7.2    
      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2.5 0 0 0 0   
      0 0 0 10.7 0 0 0 0 0 0 0 0 0 0 0 7 0 7.9 6.8 4.7 10.8 11.2 11.8 
      11.2 9.9 0 10.7 10.4 4.2 10.6 8.7 5.7 13.3 13.2 12 14 14.1 13.9 
      13.1 10.7 7.1 13.7 14.6 15 15.1 15 13.5 10.3 2.6 5.9 0 6 0 8.4 2.4 
      0.7 12.1 5.8 6.8 8.7 6 10 8.7 14.2 12.3 7.4 3.4 0.2 7.2 13.2 15.8 
      13.9 9.5 11 15.3 4.1 2.1 6 12.7 10.4 15.4 15.1 11.4 8.5 8 1.5 1.5 
      2.4 2.6 1.1 0.1 0 9.5 4.5 2.4 3.9 1.3 2.2 8.3 1.1 3.4 2.8 5.1 0.2 
      6.4 0.5 3.4 5.2 5.4 0.1 0 1.5 0 0.5 7.9 9.8 4.4 1.6 3.8 2.1 0.6 1 
      1.5 10.7 3.8 8.3 7.1 9.3 12.7 6.9 3.6 10.3 3.3 0.2 5.7 11.7 13.4 
      7.8 5.2 9.5 5 4.2 5.4 2 7.3 8.5 9 4.7 13.1 10.5 0 7.5 8.6 4.3 8 
      2.5 0 2.2 1.2 8.1 2.8 0 0.4 5.1 1.2 6.2 2.1 0.1 5.1 0.3 0 11.7 0 
      0 10.4 6.5 11.1 11.3 8.5 1.2 8.8 5.6 10.6 10.3 8.1 3.7 9.4 2.2 0.2 
      0 0 0 0 0 2.2 2.9 2.7 6.9 0 6 3.3 0 0 0 7.4 9.1 8.9 1.7 0 0 0 0 4.1 
      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
  
  
    set BERLIN2001DATA 
    [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2.3 10.3 6.2 5.5 
      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 13 8.1 3.9 6.6 0 3 10.9 13 
      13.2 13.6 4.9 0 0 0 9 14.2 14.2 14.7 13.7 12.2 12.6 2.1 8.3 2.9 5.3 
      10.1 13.1 8.3 7.5 15.3 15.1 14.9 11.6 6.5 0 6.2 3.5 1 2 0 0 0.7 1.2 
      3.1 3.1 1.4 8.9 0 6.9 0 11.3 4.6 6.8 4 8.5 3.2 5.7 14.3 3.3 3.3 2.5 
      6 13.6 13.3 14.3 1.7 10.6 12.8 5.6 0.9 12.6 12.4 11.2 13.1 6.6 0.4 
      0 5.5 5.4 11.1 6.5 2.5 3 0 0.6 8.5 11.9 11.2 5.9 11.1 7.9 11 10.4 
      10.9 14.9 14.5 6.3 12.2 2.7 5.8 12.6 3.9 2.8 5.2 6.5 5.3 5.9 8.5 7.3 
      7.4 1.1 0 5.6 13.3 12.8 6.2 0 2.9 6.6 0 9.3 11.8 8.3 10.3 11 3.8 4 
      4.3 10.9 2.9 3.9 2.5 0.3 1.2 8.1 2.9 1.6 6.2 0 0.2 0 2.1 0.2 1.5 4.2 
      3.8 3.5 0 9.9 0.5 2.6 1.1 9 0 0 0 0 0.8 4.3 0 0 0 2.2 4.5 3.8 9.5 1.1 
      7.9 3.9 7.6 0 7.7 7.5 6.3 1.2 5.5 0 0 1.9 6.9 0 0 0 0 0 5.7 0 0 0 3.1 
      2.2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ] 
    
    set BERLIN2002DATA
    [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 5.9 8.3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 9.7 
    0 0 0 0 0 0 7.2 0 0 0 0 0 0 0 0 0 0 11.2 9.1 2.8 11.2 11 0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 5 0 6.7 13.3 3.3 0 0.2 3.2 0 0 0 0 2.7 1 5.8 0 0 4.5 0 8.1 
    12.7 11.7 5.2 5.6 7.9 6.7 4.3 10.4 13.7 14.7 0 8.6 10.9 12.9 7.7 2.4 1.4 0 
    6.1 0 6.7 11.3 6.1 10.3 13.3 10.4 8.9 7.7 3.9 0 0 0.4 1.7 4.6 1.3 0.2 3 
    4.8 6.2 11.1 14.4 6.4 6 4.3 9.9 6.3 9 10.3 10.1 7.4 8.3 5 1.4 0 2 1.9 0.3 
    12.2 5.7 4.5 12.9 14.5 11.5 8.2 6.9 7.8 0 1.4 6.4 0.9 0.6 0 2.9 11.7 0.9 
    1.6 2 2.9 0.4 8.6 14.3 11.3 11.5 7.1 7.6 0.7 13.4 8.8 0.1 7.5 4.3 2.9 3.7 
    4.7 9.1 0 0 1.2 10.4 6.1 6.3 12.2 12.3 12.9 11.8 9.2 10.7 9 9.3 10.6 10.8 
    10.5 8.5 8.6 6.7 7.8 11.8 10.4 10.6 6.7 10.6 4.8 10.4 10.9 9 7.2 12.1 10.2 
    3.7 8.8 1.5 1.9 3.3 4.3 0.3 2.6 0 0 0 9.4 0 0 0 0.7 6.6 9.3 8.9 6.2 4.3 0 
    0 0 0 0 0 0 0 0 0 0 1.2 0 0 0 0 0 0 0.9 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  ]
    
    set BERLIN2003DATA
    [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 11.5 7.9 0 1.8 0 9.6 8.1 0 9.7 0 0 0 0 0 0 0 0 0 0 0 11.7 
    12.4 12.4 12.5 12.7 0 0 11.8 11.7 12.8 12.4 8.6 8.6 0.1 7.3 4.7 2.9 4.5 7.3 
    9.5 3.1 13.5 12.4 7.7 9.4 11.6 0.5 4.9 10.6 4.1 3.1 4.6 0 5.3 6.7 7.3 1.7 
    5.5 5.9 8.1 1.1 13.1 14.3 5.6 10.3 9.9 15.4 15.4 7.8 14.3 14.4 12.5 13.6 10.9 
    11.4 13.6 13.2 11.2 13.6 9.3 12.4 12.5 8.8 8.9 10.3 13.3 3.6 1.8 5.3 2.8 10.8 
    5.7 10.9 2.7 3.8 13.9 15.2 5.2 11.6 2.3 6.1 8.1 1.3 0.4 0.1 3.6 4.5 3.1 6.2 
    13.4 4.2 6.4 15.7 13.3 13.2 4 6.5 13.4 13.3 8.5 12.6 8.9 6.6 4.2 2.2 7.6 5 
    7.5 12.6 4.6 10.4 5 8.1 12.8 12.8 12.1 13.9 13.8 13.9 14.2 14.4 10.5 13 4.6 
    9.9 9.4 13.3 6 3.6 10.1 9.3 9.4 4.3 6.8 11.9 7.2 2.6 2.7 2.3 4.6 7.8 3.8 10.8 
    2.7 0.8 11.7 11.2 5.7 9.7 2 3.5 0 1.3 3.5 6.1 10.8 8.2 6.9 10.7 11.4 11.3 11.6 
    11.1 2.8 9.6 11.4 11.3 3.1 6.5 2.4 0 9.6 1.7 2.4 3.1 0 0 0 0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]  
    
    set BERLIN2004DATA
    [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.1 0 
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
    0 9.9 7 1.3 0 0 0 0 0 0 0 0 0 0 0 12 10.6 0 6.5 2.5 0 0 0 0 0 0 0 0 0 13.2 13.1 
    12.5 11 8.4 0.5 4.5 3.2 10.4 0 0 10.2 0 2 13.9 11.6 12.5 7.2 0 3.9 5.2 8.2 3.9 
    2.3 0 0 4.4 4.7 0 0 6.6 0 9.6 0.4 8 8.4 8.1 0 0 0 0 1.6 0 0 11.6 15.2 14.8 8.7 
    7.9 0 12.8 4.2 1.1 12.1 8.2 9.4 2.9 4.6 4 9.1 6.2 6.6 5.5 9.6 1 2.6 4.9 11.7 
    11.6 7.7 4.9 5.2 5.4 6.3 0.2 8.6 8.1 4.5 5.8 9.3 7 7.5 6 11.4 13.7 4 3.6 3.9 9.6 
    1 0.8 4.2 2.5 1.1 7.5 10.4 7 9.6 5 3.3 10.3 6.5 6.4 4.1 6.7 11.2 14.8 14.4 11.5 
    9.7 8.3 8.5 12.2 11.9 13.9 12.4 12.6 12.9 13.7 7.3 11.5 4.9 5.2 12 7.5 5.1 6.3 
    6.2 4.2 5.8 10.1 7.1 2.7 2.9 3 1.9 2.1 3.2 0.7 3.8 6.7 12.2 12.4 12.4 12.8 12.4 
    10.7 11.6 12.6 12.5 4.5 5.1 4 5.2 7.8 8.1 11.6 11.7 4.7 2.4 1.5 3.2 0 0 3.9 0 
    0.2 0.8 1 3.5 0.8 3.7 8.7 5.3 9.5 1.9 8.1 0 0 0 0 0 0 0 0 0 0 0 0 0 6.5 9.3 1.3 
    5.4 3.7 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
    
    set BERLIN2005DATA
    [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.8 0.4 
    0 0 0 0 0 0 4.7 7 0 0 0 0 0 0 0 12.3 10.4 11.7 0 9.4 0 0 0 0 0 6.3 2.1 6.7 7 10.2 
    10 11.4 10.3 0 0 0 0 0 4.4 11.7 0 8.4 8.5 6.6 11.7 9.7 5 2.5 7.1 2.3 0 0 0 0 0 
    0 11.8 1.6 0 8.4 0 0 12.7 11 5.7 4.7 0.4 5.4 9.6 12.7 13.9 15 14.2 0 4.3 0 2.8 
    7.9 6.7 2.5 0 0 9.5 6.6 1.2 0 0 11.7 10.2 7.9 11.5 0.4 14.1 11.1 16 11.9 7.2 15.7 
    9.8 8.7 14.8 15.7 15 13.8 10.9 0.1 3.2 9.2 12 0 1.1 2.1 0.1 3 14.3 14.8 14.9 13.7 
    12 11 9.1 7.3 6.4 4.7 4.3 0 3 0.2 4.6 4 2.1 6.8 7.9 6.8 6.9 9.4 8.5 10.1 0 6.4 
    5.6 3.9 5.1 11.1 0.5 0 1.3 8.4 0.6 1.2 4 10.9 6.6 13.7 12.4 8.4 11.5 11.1 0 6.5 
    0.2 5.6 11.3 10 12.8 12 12.8 12.3 8.4 0.9 12.4 12.4 12.5 11.9 11.7 11.7 7.4 0 0.2 
    6.6 6.9 7 0 8.1 11.7 6.8 5 0.7 11.3 11.2 10.3 10.5 3.6 7.4 0.8 0 3.4 1.7 0 0 5.4 
    9.5 10 9.4 8.9 9.2 7.5 9.8 9.7 9.2 9.6 8.6 0 0 0 0 5.7 0 0.2 2.2 0 0 3.3 7.7 8.9 
    8.6 8.2 0 0 0 2.7 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
    
    set BERLIN2006DATA
    [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
    0 0 0 0 1.8 1.5 5 0 0 0 3.8 8.5 0 0 0 0 0 8.2 0 0 0 0 0 0 0 0.1 0 0 6.5 9.6 4.3 
    0 3.7 0 13.1 4.7 0 0 0 0 10.5 5.6 13.4 12.5 11.9 11 12.2 10.6 14.2 14.7 14.1 12.6 
    6.8 4.6 10.5 8.6 1.4 0.3 3.5 6.1 1.5 7.7 5.8 9.9 0 0 1.6 6.6 0 0 2.4 0 11.5 4.4 0 
    0 4.8 9 11.5 11.5 15.6 15.8 15.8 15.7 15.2 7.5 5.6 1.2 9.1 9.8 9 7.7 6.4 9.8 12.4 
    13 9.7 12.3 10.4 10.2 0.7 14.2 15.8 16 16 15.7 12.9 10.6 2.5 12.3 11.7 10.8 13.3 
    8.5 10.3 11.5 13.4 15.7 15.7 15.5 13.9 12 14.1 6 14 12.9 14.8 13.6 5 5 12.9 6 9.3 
    8.5 6.4 3.5 0.6 0.8 9.3 4.6 5.3 2 3.9 8.4 0 9.8 2.2 6.9 8.2 3.7 11.2 7.7 4.9 7 0.9 
    9.6 3.5 2.3 4.2 6.7 1.2 0.2 4.2 0.2 7.7 0 5.1 9.1 3.7 8.5 6.4 5.3 11.9 12.4 11.5 
    12.1 12 11.4 6.4 4.7 9.2 1 8.9 11.3 11.5 11.4 11.3 11.1 9.5 0.1 3 10.2 7.8 3.9 1.3 
    0.4 0.2 2.9 0.9 1.4 4.2 9.8 9.1 6.3 8.2 0 0 0 6.7 9.9 7.9 4.8 0 6 5.3 3.2 2.7 4.4 
    6.3 7.1 0 1.1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4.7 7.7 1.3 0 0 0 0 0 0 0 0 0 0 0 0 
    0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
    
    set BERLINAVERAGEDATA
    [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.84 1.19 0 0.01 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1.03 0 0 0 0 0 0 0 0 0 0 1.39 0 0 0 0 0.11 0.06 2.44 1 0.19 0 0 0 2.31 2.13 0.26 0.83 0.71 2.97 2.46 0.4 5.57 7.53 2.37 4.91 0.36 1.34 0 1.17 0 0 0 0.9 1.97 2.73 4.66 6.13 5.03 4.33 5.29 3.8 5.43 5.79 5.94 4.69 6.33 4.83 3.51 3.64 4.64 6.31 9.49 7.41 7.74 7.21 6.94 6.81 5.66 7.93 7.81 8.03 8.01 7.77 8.06 6.44 5.51 8 6.83 5.47 5.51 8.37 5.77 6.7 4.33 7.76 6.09 4.6 7.21 5.33 8.7 7.73 6.06 6.47 8.37 7.06 7.86 4.84 3.96 5.43 7.29 8.74 7.26 7.87 6.14 10.21 9.04 6.66 6.46 7.16 8.3 6.83 10.13 8.11 8.66 8.03 8.71 7.86 8.37 10.33 7.63 7.79 6.51 3.81 6.19 8.8 7.34 7.27 5.74 5.86 6.06 5.43 8.03 8.47 9.3 6.3 6.81 6.41 6.86 4.97 7.23 8 7.51 7.03 6.67 4.06 8.06 7.24 5.89 8.17 8.17 7.17 10.21 6.46 7.8 8.19 6.27 7.3 6.23 7.43 9.21 8.23 6.87 7.34 7.59 5.13 4.4 5.57 8.34 9.41 7.61 7.17 7.67 8.01 6.73 7.69 6.44 7.97 6.7 6.33 6.97 6.61 4.46 6.71 6.24 5.16 7.99 4.14 6.07 8.94 7.84 7.57 8.27 5.93 6.43 5.31 4.7 6.27 5.19 6.79 4.69 4.79 6.64 8.11 4.39 4.46 6.7 6.3 6.04 7.67 5.26 1.69 2.87 3.43 4.2 5.47 2.97 2.66 5.09 3.39 4.3 1.97 4.16 3.27 3.46 2.3 3.97 2.8 2.66 2.39 1.91 2.27 1.6 0.96 1.8 0.86 2.77 3.53 1.84 1.64 2.71 2.11 1.27 1.39 2.2 0.31 0 0 0.39 0 0 0 0 0 0 0 0 0 0 0 0.67 1.1 0.19 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.14 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

    
    
    ; ROTHAMSTED WEATHER DATA 2009: 
  ;TH: 15C:  
  set ROTHAMSTED2009DATA [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  10.4  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  7.8  0  0  8.9  0  5.4  0  0  0  0  0  0  4.1  6  5.9  0  0  0  0  10.1  12.3  11  9.3  10.5  0  11.5  0  0  11.2  4.5  8  10.3  0  0  5.2  7.5  3.2  0  9.4  10.3  0  11.6  0  0.7  0  0  0  6.9  5.4  8.2  8.7  8.4  12.5  15  7.5  7.5  0.7  6.7  13  15  14.2  14.3  14.9  3.4  11.7  0  0  4.3  2.5  0  0.9  6.5  11.8  5.4  13  5.4  9.4  4.7  6  9.7  2.7  9  5  10.6  13.9  8  2.7  4.7  4.3  10.8  11.7  12.7  12.3  6.2  11.8  9  6.8  4.7  3.7  5.2  9.7  2.2  7.4  7.4  8.7  6.1  3.6  1.9  5.3  3.8  7.8  0.2  7.1  6.1  6.5  11.4  1.8  5.1  6.8  1.6  8.7  8.6  0.9  8.5  5.4  0  5.9  3.2  2.7  9.5  4.8  2.7  8.5  1.8  6.2  3.2  2.6  10.4  7.5  7.5  12.3  5.4  8.4  8.1  11.4  7.3  5.8  2.3  7.4  7.4  8.7  3.8  5.7  7.3  0.4  5.2  7.5  6.1  4.3  0.5  6.7  5.7  7  4.8  9.8  0.8  3.6  0  4.6  1.6  7.7  3.4  4.4  4.9  3.3  1.8  9.7  9.9  8  9.3  0.9  5.2  0.3  5.6  5.5  0.8  4.9  0.1  0.1  0  0  0  4  3.5  0  0  0  0  0  0  0  0  0  0  0  6.2  0.5  4.2  0  1.3  0.6  1.8  0  2.5  0.5  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0.8  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 ]
 
  ; ROTHAMSTED WEATHER DATA 2010: 
  ; TH: 15C:  
    set ROTHAMSTED2010DATA [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  5.3  0  0  0  0  0  5.8  0  0  0  0  0  0  0  0  0  0  0  0  9.3  0  11.4  9.1  10.6  0  0  0  0  0  0  11.8  11.4  0  0  0  0  13.1  11.2  2.4  4.4  10.4  8.1  1.7  0  3  0  0  0  0  0  0  0  0  0  0  0  0  0  8.3  0  6.4  7  8.1  5.9  12.5  14.9  15  14.7  9  5  6.2  10.7  0  10.1  1.1  0  12.8  15.4  12.9  8.5  3.7  5.7  3.1  2.8  0.9  5  4.5  5  6.5  9  12.1  13.9  1.5  0  6.9  9.1  14.6  13  10.2  9  8.9  13.7  14  6.2  7.6  7.3  3.8  10.3  10.2  7.2  7.6  1.4  6.5  12.5  10.8  7.3  4.6  0  2.2  4.1  6.8  9.6  6.3  9.3  5.8  10.3  7.6  1.7  7  2.9  0.9  1.2  2  2  4  6  1.3  3.3  7.3  0.8  5.8  4.6  3  5.8  9.3  1.1  9.6  2.9  2.8  1.4  8  7.2  2.1  6.6  4.9  1.1  1.3  6.3  2.9  8  1.6  0  2.9  7.5  4.7  6  10.2  11.3  11.1  8.5  5.6  2.4  4  5  1.6  4.2  1  3  8.6  2.3  0  5  4.6  6.3  7.3  1.1  5.2  7.5  8.7  1.3  0  0  0  0  0.3  0.1  6.6  0  3.1  1.3  0.1  0.7  5.2  6  4.1  0  6.4  8.6  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  4.7  0  0  0  0  0  0  3.3  2.2  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 ]
  
  ; ROTHAMSTED WEATHER DATA 2011: 
  ; TH: 15degC  
  set ROTHAMSTED2011DATA [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  5.4  1.7  0  0  0  0  0  0  0  0  0  0  0  0  3.2  0  4.9  0  0  3.9  0  0  0  0  0  3.1  1.1  10.1  10.5  10.2  3  7.5  6.5  4.6  0.2  4.8  3.3  3.9  6.1  6.2  0  11.5  10.2  12.5  12  11.1  8.5  10.2  0  0.2  5  3.6  6.6  6.7  11.3  8.5  7.8  12.6  12.7  10.1  12.8  4.6  10.9  6.8  5.3  12.9  12.2  13  13.2  13.6  6.6  11.8  3.2  6.8  10.8  11  2.1  8  7.2  8.7  5.1  3.6  2.6  1.3  9.8  8.6  12.3  9.4  4.5  11.9  13  3.8  4.1  2.9  4.2  1.5  10.8  9.7  9.8  13.5  10.7  2.6  0.9  9.1  8.5  4.5  6.6  9.4  2  6.6  11.8  3.6  5.2  1.3  6.7  9.8  7.1  7.1  5.2  7  7.3  6.7  12  8.9  1.6  11.1  8.2  8.5  8.3  4.8  4.6  8.7  6.7  4.4  3.3  5.6  4.2  8.3  1  2.1  8.1  9.5  3.2  3.1  1.1  3.6  1.4  1.3  8  6.6  12.7  9.2  1.7  2.3  6.9  2.2  11.3  8.7  7.5  6.9  8.7  0.3  3.5  1.8  4.9  7.5  10.1  7.1  2.5  2.8  2  6.4  7.2  3.5  4.1  0.1  9.6  5.4  6.6  8.8  0  4.2  3.2  1.2  5.6  4.4  4.6  0  1  6.2  8.4  5  2  5.8  0  1.2  1.5  1.5  2.3  5.2  6.9  7.5  8.6  7  4.9  5.9  6  6.6  0.2  2.6  5.3  8.4  6.4  6.9  2.7  6.3  9.5  9.7  9.8  9.2  9.7  6.3  4.1  1.3  7  3.3  0.8  2.3  4.7  1.6  2.3  0.1  8.3  9.3  4.5  2.3  8.2  6  0  3.3  9.1  6.4  4.8  2.8  5.8  0  8.3  4.1  0  0  4.1  3.5  0  1.4  0.5  0  0  0  1.1  1.2  0  0.7  5.9  0  0  0  2.2  3  0  0  0  0  0  2  0  2.8  5.6  0  0.3  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0.4  0  0  0  0  0 ] 
 
  
end


to draw_world
  
  ask patches [set plabel-color black]
  ask patch 5 -5 [set plabel "Jan"]
  ask patch 37 -5 [set plabel "Feb"]
  ask patch 67 -5 [set plabel "Mar"]
  ask patch 97 -5 [set plabel "Apr"]
  ask patch 127 -5 [set plabel "May"]
  ask patch 157 -5 [set plabel "Jun"]
  ask patch 190 -5 [set plabel "Jul"]
  ask patch 220 -5 [set plabel "Aug"]
  ask patch 251 -5 [set plabel "Sep"]
  ask patch 280 -5 [set plabel "Oct"]
  ask patch 312 -5 [set plabel "Nov"]
  ask patch 342 -5 [set plabel "Dec"]
  ask patch 372 12 [set plabel "12"]
end
@#$#@#$#@
GRAPHICS-WINDOW
4
266
1213
491
-1
-1
3.1804
1
12
1
1
1
0
0
0
1
-1
375
-20
40
0
0
1
ticks
80.0

BUTTON
6
22
213
89
Start
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
704
496
1215
646
Current Weather 
Day
Hours to forage
0.0
365.0
0.0
24.0
false
false
"" ""
PENS
"Hours" 1.0 0 -16777216 true "" "plot count turtles"

BUTTON
925
44
1141
108
Freehand Draw
draw_weather
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
704
645
1215
678
Draw Plot
update_plots
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1450
582
1607
622
Save Year
save_year
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
1233
521
1448
694
11

INPUTBOX
184
535
352
595
Day
1
1
0
Number

CHOOSER
417
41
661
86
YearData
YearData
"Berlin Average" "Berlin 2000" "Berlin 2001" "Berlin 2002" "Berlin 2003" "Berlin 2004" "Berlin 2005" "Berlin 2006" "Rothamsted 2009" "Rothamsted 2010" "Rothamsted 2011"
8

INPUTBOX
1450
522
1607
582
YearName
Year1
1
0
String

BUTTON
1450
666
1607
726
Clear All Data
clear_data
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1450
621
1607
667
Clear Last Year
clear_last_year
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1626
579
1781
668
CREATE OUTPUT FILE
create-output-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
1626
520
1780
580
OutputFileName
WeatherExample.txt
1
0
String

BUTTON
7
199
213
261
Reset
reset_weather
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
184
596
352
641
Month
Month
"January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December"
6

CHOOSER
184
640
353
685
Season
Season
"Spring" "Summer" "Autumn" "Winter"
2

TEXTBOX
1266
481
1416
518
Year List
24
0.0
1

TEXTBOX
389
505
699
541
Alter Selected Temperatures
24
0.0
1

TEXTBOX
1627
483
1777
520
Output File
24
0.0
1

BUTTON
184
744
354
795
Freehand Select
select_period
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
184
685
269
745
SelectionStart
1
1
0
Number

INPUTBOX
269
685
353
745
SelectionEnd
365
1
0
Number

CHOOSER
7
91
213
136
WeatherPresets
WeatherPresets
"YearData" "UkMonthlyAverages" "Input File" "Monthly Inputs"
0

CHOOSER
416
100
660
145
UkMonthlyAverages
UkMonthlyAverages
1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013
4

SWITCH
530
188
659
221
UseStdevValues
UseStdevValues
1
1
-1000

CHOOSER
529
145
659
190
Station
Station
"Camborne" "Oxford"
1

INPUTBOX
692
81
742
141
MinDailyTemp
15
1
0
Number

BUTTON
975
454
1092
487
Show/Hide Curve
data_curve
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1093
454
1210
487
Hide/Show Data Points
hide_plot
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
1248
42
1307
102
JanMean
0
1
0
Number

INPUTBOX
1248
101
1308
161
FebMean
0
1
0
Number

INPUTBOX
1248
161
1306
221
MarMean
1
1
0
Number

INPUTBOX
1249
225
1307
285
AprMean
5
1
0
Number

INPUTBOX
1249
285
1307
345
MayMean
6
1
0
Number

INPUTBOX
1249
344
1307
404
JunMean
10
1
0
Number

INPUTBOX
1364
42
1424
102
JulMean
9
1
0
Number

INPUTBOX
1364
102
1424
162
AugMean
8
1
0
Number

INPUTBOX
1364
161
1424
221
SepMean
5
1
0
Number

INPUTBOX
1364
225
1425
285
OctMean
3
1
0
Number

INPUTBOX
1364
284
1425
344
NovMean
0
1
0
Number

INPUTBOX
1365
344
1426
404
DecMean
0
1
0
Number

INPUTBOX
1306
42
1359
102
JanSD
0
1
0
Number

INPUTBOX
1306
102
1359
162
FebSD
0.5
1
0
Number

INPUTBOX
1306
160
1359
221
MarSD
2
1
0
Number

INPUTBOX
1307
225
1360
286
AprSD
3
1
0
Number

INPUTBOX
1307
285
1360
345
MaySD
3
1
0
Number

INPUTBOX
1306
344
1360
404
JunSD
3
1
0
Number

INPUTBOX
1423
42
1473
102
JulSD
3
1
0
Number

INPUTBOX
1424
101
1474
161
AugSD
3
1
0
Number

INPUTBOX
1424
161
1474
221
SepSD
3
1
0
Number

INPUTBOX
1425
226
1476
286
OctSD
2
1
0
Number

INPUTBOX
1425
285
1476
345
NovSD
1
1
0
Number

INPUTBOX
1425
344
1476
404
DecSD
0
1
0
Number

TEXTBOX
1246
10
1426
46
Monthly Inputs
24
0.0
1

SWITCH
925
110
1072
143
DrawAbsolute
DrawAbsolute
0
1
-1000

INPUTBOX
1071
110
1140
170
DrawSD
2
1
0
Number

BUTTON
441
542
496
575
+1
add_one 1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
441
575
496
608
+5
add_one 5
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
13
535
183
580
Period
Period
"Day" "Week" "Month" "Season" "Year" "Selection" "Between"
3

INPUTBOX
386
662
483
722
select_mean
8
1
0
Number

INPUTBOX
483
662
616
722
select_sd
3
1
0
Number

BUTTON
386
653
616
686
Set selection
set_selection
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
386
542
441
575
-1
add_one -1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
386
575
441
608
-5
add_one -5
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
15
821
354
886
NIL
selection_REP
17
1
16

INPUTBOX
388
822
489
882
average_sd
2
1
0
Number

BUTTON
388
810
617
848
Average of Selection
average_selection
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
7
137
213
198
Load Weather
set_weather
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
386
608
441
641
-10
add_one -10
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
441
608
496
641
+10
add_one 10
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
445
704
473
722
mean
11
0.0
1

TEXTBOX
562
700
627
718
std. dev.
11
0.0
1

TEXTBOX
434
859
481
877
std. dev.
11
0.0
1

BUTTON
99
799
184
851
Clear Selection
clear_selection
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
12
503
147
540
Select Days
24
0.0
1

TEXTBOX
419
10
679
38
Weather Data Sources
24
0.0
1

BUTTON
184
799
354
851
SELECT
select_group
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
489
848
617
881
definedSD
definedSD
1
1
-1000

INPUTBOX
387
744
616
804
hours_to_add
0
1
0
Number

BUTTON
387
732
617
765
Add Hours to Selection
add_to_selection
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
55
583
175
779
Select a day (of year)..\n\n\nor a month..\n\n\nor a season..\n\n\nor a period..\n\n\nor make a freehand selection
11
0.0
1

BUTTON
15
799
100
851
Select all
set Period \"Year\"\nselect_group
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
465
784
615
802
(total hours randomly distributed)
9
0.0
1

TEXTBOX
395
885
614
908
if definedSD \"off\": SD from selection is used
11
0.0
1

TEXTBOX
223
52
373
234
1.) press start to setup\n\n\n\n2.) select weather data source\n\n\n\n3.) load weather\n\n\n\n4.) reset to 0
11
0.0
1

INPUTBOX
692
45
907
105
InputFilename
WeatherInput.txt
1
0
String

TEXTBOX
749
107
899
135
min. foraging temperature\n(default 15C)
11
0.0
1

TEXTBOX
693
10
886
68
Read from Infile
24
0.0
1

TEXTBOX
924
10
1217
42
Draw Daily Foraging Hours
24
0.0
1

TEXTBOX
1263
441
1474
472
CREATE OUTPUT
24
0.0
1

TEXTBOX
1239
699
1433
727
Press \"Save Year\" to add weather data to your output file
11
0.0
1

TEXTBOX
1630
672
1784
728
Press \"Create Output File\" to write your data in a text file, which serves as weather input file for the BEEHAVE model
11
0.0
1

INPUTBOX
505
557
615
617
NonForagingProb
0.5
1
0
Number

BUTTON
505
542
615
583
Non-foraging Days
NoForagingProc
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
512
617
611
647
Probability for 0 hrs foraging
11
0.0
1

TEXTBOX
536
456
616
474
Day of Year
14
0.0
1

TEXTBOX
22
310
182
328
Daily Foraging Hours:
14
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
1.0
-0.2 1 1.0 0.0
0.0 0 0.0 1.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
