patches-own[ number-of-shares 
            ;; Number of shares that each trader has (if negative it implies that the
            ;; trader is 'short' (we assume that there are no limits to short selling).
            
            old-number-of-shares
            ;; It is the number-of-shares at time-1
            
            liquidity 
            ;; It represents the quantity of money which each agent has at the end of every transaction.
            
            portfolio-value
            ;; This variable represents each agent's portfolio, computed as 
            ;; actual stock price times the number of stock in portfolio, after every transaction.
             
             news-sensitivity 
             ;; Sensitivity that the traders have to the news qualitative meaning.
             
             smart-counter
             typical-counter
             risky-counter
             optimists-counter
             pessimists-counter
             ;; Allows the counting of the different type of traders.
             
             random-number] 
             ;; It is a random number between 0 (included) and 1 (not included).
             

 globals [price
         old-price
         price-%variation
         ;; The first is the price of the stock each time, calculated as exp (log-price), the second is the same variabile at time-1,
         ;; while the third is the price per cent variation.
         
         average-price
         min-price
         max-price
         ;; They measure the average, the minimum and the maximum price of the stock.
         
         number-of-yellow
         ;; It counts the number of already failed agents.
         number-of-red
         number-of-green
         number-of-white
      
  
         average-liquidity
         min-liquidity
         max-liquidity
         ;; They measure the average, the minimum and the maximum liquidity of the agents at each time.       
         
         
         average-portfolio-value
         min-portfolio-value
         max-portfolio-value
         ;; They measure the average, the minimum and the maximum portfolio value of the agents at each time.
         time
         ;; It measures the number of transactions in the market.
          
         present-value
         ;; It the value of the share and it is based on the news at disposal.   
         
         return-denominator
         ;; The return of the market is calculated dividing the difference between buyers and sellers by the total amont of operators.       
         
         risky-risky-trades
         risky-typical-trades
         risky-smart-trades
         typical-typical-trades
         typical-smart-trades
         smart-smart-trades
         
         old-best-offer
         track-best-offer
         
         news-qualitative-meaning 
         ;; The news concerning the market get to every operator, and they are the rational component of the decision 
                  
                 
         number-of-fundamentalists
         number-of-imitators
         number-of-optimists
         number-of-pessimists
         ;; They can change, because of the conversions.
         ]

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------

 to setup
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  ;; It creates "fundamentalists" (white), "imitators" (green, still to be differentiated) and "stubborns" (red).
  ask patches
  [ifelse (smart + typical) > 100 
  [user-message "The sum between smart and typical agents must be below or equal to 100!!!"
   stop]
  [set random-number random-float 100
  ifelse random-number <= smart
  [set pcolor white]
  [ifelse (smart < random-number) and (random-number <= (smart + typical))
  [set pcolor green]
  [set pcolor red]]]]
    
  set present-value 1000.0
  set price 1000.0
  set track-best-offer 2.3
  set old-best-offer track-best-offer
  set return-denominator 1
  set time 0
  ask patches
  [set liquidity endowment]

  ;; It shapes the "imitators"
  ask patches with [pcolor = green]
  [set number-of-shares 1 
  set news-sensitivity (random-float max-news-sensitivity)
  set typical-counter 1]    
  ;; It shapes the "fundamentalists"
  ask patches with [pcolor = white]
  [set number-of-shares 1 
  set smart-counter 1]
  ;; It shapes the "stubborns"
  ask patches with [pcolor = red]
  [set number-of-shares 1
  set risky-counter 1]
  
  end

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------

 to go 
  set time time + 1
  old-number
  news-arrival
  typical-decision
  risky-decision
  smart-decision
  balance-and-liquidity-adjustment
  market-clearing  
  fail-or-survive
  do-plot
 end
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Number of shares at time-1 ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; This updates the variable "old-number-of-shares" to the number of shares which every agent had in her portfolio at time-1
 
 to old-number
 ask patches
 [set old-number-of-shares number-of-shares]
 set risky-risky-trades 0
 set risky-typical-trades 0
 set risky-smart-trades 0
 set typical-typical-trades 0
 set typical-smart-trades 0
 set smart-smart-trades 0
 end 

 ;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; News Arrival mechanism ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; The news act as a random normal variable and they change the value of the share.
 
 to news-arrival
  ifelse (random-float 1) >= .5
  [set news-qualitative-meaning 1
  set present-value price + random-float 1.00]
  [set news-qualitative-meaning -1
  set present-value price - random-float 1.00]
 end


 ;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Agent's decision rule ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Whether the "imitators" are optimist and buy the share, depends on the four elements you can find here. If the sum of them is positive the "imitators" are optimist.  
 
   
  to typical-decision
    ask patches with [pcolor = green]
    [ let agent-evaluation ((random-float 0.8) + 0.6) * present-value       ; agent's evaluation of a share
      let best-offer agent-evaluation
      let offer-x 0    ; offer-x is the best offer's x-coordinate  
      let offer-y 0    ; offer-y is the best offer's y-coordinate
      let neighbor-eval agent-evaluation
      ifelse (agent-evaluation > price)
       [ ask neighbors                      ; Agent wants to buy a share --> neighbor places bid (for two more than their evaluation) if they want to sell a share
        [ if pcolor = green [set neighbor-eval ((random-float 0.8) + 0.6) * present-value]
          if pcolor = white [set neighbor-eval ((random-float 0.4) + 0.8) * present-value]
          if pcolor = red [set neighbor-eval ((random-float 1.2) + 0.4) * present-value]
          if neighbor-eval < price    ; Looking only at sellers
          [ if neighbor-eval < best-offer
            [ set best-offer neighbor-eval
              set offer-x pxcor
              set offer-y pycor]
            ]
          ]
        if best-offer < agent-evaluation
        [ set number-of-shares number-of-shares + 1
          set liquidity liquidity - best-offer
          ask neighbors with [pxcor = offer-x and pycor = offer-y]
          [ set number-of-shares number-of-shares - 1
            set liquidity liquidity + best-offer
            set track-best-offer track-best-offer + best-offer
            if pcolor = green [set typical-typical-trades typical-typical-trades + 1]
            if pcolor = white [set typical-smart-trades typical-smart-trades + 1]
            if pcolor = red [set risky-typical-trades risky-typical-trades + 1]]
          ]
         ]
       [ask neighbors                      ; Agent wants to sell a share --> neighbor places bid (for two less than their evaluation) if they want to buy a share
         [ if pcolor = green [set neighbor-eval ((random-float 0.8) + 0.6) * present-value]
           if pcolor = white [set neighbor-eval ((random-float 0.4) + 0.8) * present-value]
           if pcolor = red [set neighbor-eval ((random-float 1.2) + 0.4) * present-value]
           if neighbor-eval > price    ; Looking only at buyers
           [ if neighbor-eval > best-offer
            [ set best-offer neighbor-eval
              set offer-x pxcor
              set offer-y pycor]
            ]
          ]
         if best-offer > agent-evaluation
         [ set number-of-shares number-of-shares - 1
          set liquidity liquidity + best-offer
          set track-best-offer track-best-offer + best-offer
          ask neighbors with [pxcor = offer-x and pycor = offer-y]
          [ set number-of-shares number-of-shares + 1
            set liquidity liquidity - best-offer
            if pcolor = green [set typical-typical-trades typical-typical-trades + 1]
            if pcolor = white [set typical-smart-trades typical-smart-trades + 1]
            if pcolor = red [set risky-typical-trades risky-typical-trades + 1]]
          ]
         ]
       update-price
       ]
  end
 
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; fundamentalist's decision ; 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; The "fundamentalist" buy the share if they think it is understimated, otherwise they sell. 
 ;
 
 to smart-decision
  ask patches with [pcolor = white]
    [ let agent-evaluation ((random-float 0.4) + 0.8) * present-value       ; agent's evaluation of a share
      let best-offer agent-evaluation
      let offer-x 0    ; offer-x is the best offer's x-coordinate
      let offer-y 0    ; offer-y is the best offer's y-coordinate
      let neighbor-eval agent-evaluation
      ifelse (agent-evaluation > price)
       [ ask neighbors                      ; Agent wants to buy a share --> neighbor places bid (for two more than their evaluation) if they want to sell a share
        [ if pcolor = green [set neighbor-eval ((random-float 0.8) + 0.6) * present-value]
          if pcolor = white [set neighbor-eval ((random-float 0.4) + 0.8) * present-value]
          if pcolor = red [set neighbor-eval ((random-float 1.2) + 0.4) * present-value]
          if neighbor-eval < price    ; Looking only at sellers
          [ if neighbor-eval < best-offer
            [ set best-offer neighbor-eval
              set offer-x pxcor
              set offer-y pycor]
          ]
        ]
        if best-offer < agent-evaluation
        [ set number-of-shares number-of-shares + 1
          set liquidity liquidity - best-offer
          set track-best-offer track-best-offer + best-offer
          ask neighbors with [pxcor = offer-x and pycor = offer-y]
          [ set number-of-shares number-of-shares - 1
            set liquidity liquidity + best-offer
            if pcolor = green [set typical-smart-trades typical-typical-trades + 1]
            if pcolor = white [set smart-smart-trades typical-smart-trades + 1]
            if pcolor = red [set risky-smart-trades risky-typical-trades + 1]]
          ]
         ]
       [ask neighbors                      ; Agent wants to sell a share --> neighbor places bid (for two less than their evaluation) if they want to buy a share
         [ if pcolor = green [set neighbor-eval ((random-float 0.8) + 0.6) * present-value]
           if pcolor = white [set neighbor-eval ((random-float 0.4) + 0.8) * present-value]
           if pcolor = red [set neighbor-eval ((random-float 1.2) + 0.4) * present-value]
           if neighbor-eval > price    ; Looking only at buyers
           [ if neighbor-eval > best-offer
            [ set best-offer neighbor-eval
              set offer-x pxcor
              set offer-y pycor]
            ]
          ]
         if best-offer > agent-evaluation
         [ set number-of-shares number-of-shares - 1
          set liquidity liquidity + best-offer
          set track-best-offer track-best-offer + best-offer
          ask neighbors with [pxcor = offer-x and pycor = offer-y]
          [ set number-of-shares number-of-shares + 1
            set liquidity liquidity - best-offer
            if pcolor = green [set typical-smart-trades typical-typical-trades + 1]
            if pcolor = white [set smart-smart-trades typical-smart-trades + 1]
            if pcolor = red [set risky-smart-trades risky-typical-trades + 1]]
          ]
         ]
       update-price
       ]
 end 
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Stubborn's decision       ; 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; The "stubborn" buy or sell the share randomly. 
 ;
 
 to risky-decision
   ;let track-best-offer []
   ask patches with [pcolor = red]
    [ let agent-evaluation ((random-float 1.2) + 0.4) * present-value       ; agent's evaluation of a share
      let best-offer agent-evaluation
      let offer-x 0    ; offer-x is the best offer's x-coordinate
      let offer-y 0    ; offer-y is the best offer's y-coordinate
      let neighbor-eval agent-evaluation
      ifelse (agent-evaluation > price)
       [ ask neighbors                      ; Agent wants to buy a share --> neighbor places bid (for two more than their evaluation) if they want to sell a share
        [ if pcolor = green [set neighbor-eval ((random-float 0.8) + 0.6) * present-value]
          if pcolor = white [set neighbor-eval ((random-float 0.4) + 0.8) * present-value]
          if pcolor = red [set neighbor-eval ((random-float 1.2) + 0.4) * present-value]
          if neighbor-eval < price    ; Looking only at sellers
          [ if neighbor-eval < best-offer
            [ set best-offer neighbor-eval
              set offer-x pxcor
              set offer-y pycor]
            ]
          ]
        if best-offer < agent-evaluation
        [ set number-of-shares number-of-shares + 1
          set liquidity liquidity - best-offer
          set track-best-offer track-best-offer + best-offer
          ask neighbors with [pxcor = offer-x and pycor = offer-y]
          [ set number-of-shares number-of-shares - 1
            set liquidity liquidity + best-offer
            if pcolor = green [set risky-typical-trades typical-typical-trades + 1]
            if pcolor = white [set risky-smart-trades typical-smart-trades + 1]
            if pcolor = red [set risky-risky-trades risky-typical-trades + 1]]
          ]
         ] ; end of if in ifelse. next for agent-evaluation <= price
       [ask neighbors                      ; Agent wants to sell a share --> neighbor places bid (for two less than their evaluation) if they want to buy a share
         [ if pcolor = green [set neighbor-eval ((random-float 0.8) + 0.6) * present-value]
           if pcolor = white [set neighbor-eval ((random-float 0.4) + 0.8) * present-value]
           if pcolor = red [set neighbor-eval ((random-float 1.2) + 0.4) * present-value]
           if neighbor-eval > price    ; Looking only at buyers
           [ if neighbor-eval > best-offer
            [ set best-offer neighbor-eval
              set offer-x pxcor
              set offer-y pycor]
            ]
          ]
         if best-offer > agent-evaluation
         [ set number-of-shares number-of-shares - 1
          set liquidity liquidity + best-offer
          set track-best-offer track-best-offer + best-offer
          ask neighbors with [pxcor = offer-x and pycor = offer-y]
          [ set number-of-shares number-of-shares + 1
            set liquidity liquidity - best-offer
            if pcolor = green [set risky-typical-trades typical-typical-trades + 1]
            if pcolor = white [set risky-smart-trades typical-smart-trades + 1]
            if pcolor = red [set risky-risky-trades risky-typical-trades + 1]]
          ]
         ]
       ]
    update-price
   end

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Balance and liquidity adjustment        ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 to balance-and-liquidity-adjustment
 
 ask patches with [pcolor != yellow]
 [set portfolio-value (price * number-of-shares)
 ifelse number-of-shares > old-number-of-shares
 [set liquidity liquidity - price]
 [set liquidity liquidity + price]]
 end


 ;;;;;;;;;;;;;;;;
 ; Update Price ;
 ;;;;;;;;;;;;;;;;
 ;; We update the price before each agent's decision to trade
 
 to update-price
   set return-denominator (risky-risky-trades + risky-typical-trades + risky-smart-trades + typical-typical-trades + typical-smart-trades + smart-smart-trades)
   ifelse track-best-offer = 0.0
    [set price old-best-offer]
    [ ifelse return-denominator = 0
      [set price old-best-offer]
      [set price track-best-offer / return-denominator]]
 end


 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Market clearing mechanism ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; We compute the price and the return , as they result from the actions undertaken by the operators.The return is the eccess of demand over the supply, divided by the dimension of the market.
 ;
 
   to market-clearing 
   ;; The denominator is the number of trades.
   ;; The numerator is the total value of assets traded in all trades.
   set return-denominator (risky-risky-trades + risky-typical-trades + risky-smart-trades + typical-typical-trades + typical-smart-trades + smart-smart-trades)
   set old-price price
   ifelse (track-best-offer = 0.0)
    [set price old-best-offer]
    [ ifelse return-denominator = 0
      [set price old-best-offer]
      [set price track-best-offer / return-denominator
      set old-best-offer track-best-offer / return-denominator
      set track-best-offer 0.0]]
   
   ask patches
   [ifelse time = 1
   [set price-%variation 0]
   [set price-%variation ln (price / old-price)]]
   ask patches
   [if time = 1
   [set average-price price
    set min-price price
    set max-price price]]
   set average-price average-price * (time - 1) / time + price / time
   ask patches
   [ifelse (price - min-price) > 0
   [set min-price min-price]
   [set min-price price]] 
   ask patches
   [ifelse (max-price - price) > 0
   [set max-price max-price]
   [set max-price price]]        
 end
 
 
 ;;;;;;;;;;;;
 ; Failures ;
 ;;;;;;;;;;;;
 
 to fail-or-survive
 ask patches with [pcolor != yellow]
 [ifelse (liquidity + portfolio-value) < maximum-debt
 [set pcolor yellow
  set number-of-shares 0]
 [ifelse liquidity < maximum-debt and (liquidity + portfolio-value) >= maximum-debt
 [while [liquidity < maximum-debt and (liquidity + portfolio-value) >= maximum-debt]
 [set number-of-shares (number-of-shares - 1)
  set portfolio-value (price * number-of-shares)
  set liquidity liquidity + price]]
 [if portfolio-value < maximum-debt and (liquidity + portfolio-value) >= maximum-debt
 [while[portfolio-value < maximum-debt and (liquidity + portfolio-value) >= maximum-debt] 
 [set number-of-shares (number-of-shares + 1)
  set liquidity liquidity - price 
  set portfolio-value (price * number-of-shares)]]]]]
  ask patches with [pcolor != yellow]
 [if (liquidity + portfolio-value) < maximum-debt
 [set pcolor yellow
  set number-of-shares 0]]

 set number-of-yellow count patches with [pcolor = yellow]
 set number-of-red count patches with [pcolor = red]
 set number-of-green count patches with [pcolor = green]
 set number-of-white count patches with [pcolor = white]
 
 set average-portfolio-value (sum [portfolio-value] of patches) / (count patches with [pcolor != yellow] + .0000000000000000001)
 ;; We need to do that because, if every agent has failed, the program returns a division-by-zero error.   
 set min-portfolio-value min [portfolio-value] of patches
 set max-portfolio-value max [portfolio-value] of patches
 
  set average-liquidity (sum [liquidity] of patches) / (count patches with [pcolor != yellow] + .0000000000000000001)
 ;; We need to do that because, if every agent has failed, the program returns a division-by-zero error.   
 set min-liquidity min [liquidity] of patches
 set max-liquidity max [liquidity] of patches
 end

 ;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Plot Graphics          ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; We draw the graphs of price, of market volatility and of return.
 
 
 to do-plot
  set-current-plot "Price"
  set-current-plot-pen "price"
  plot price
  set-current-plot "Min, Average and Max Portfolio Value"
  set-current-plot-pen "Min-portfolio-value" 
  plot min-portfolio-value
  set-current-plot-pen "Max-portfolio-value" 
  plot max-portfolio-value
  set-current-plot-pen "Average-portfolio-value" 
  plot average-portfolio-value
  set-current-plot "Min, Average and Max Liquidity"
  set-current-plot-pen "Min-liquidity" 
  plot min-liquidity
  set-current-plot-pen "Max-liquidity" 
  plot max-liquidity
  set-current-plot-pen "Average-liquidity" 
  plot average-liquidity
  set-current-plot "Risky-Risky Trades"
  set-current-plot-pen "risky-risky-trades"
  plot risky-risky-trades
  set-current-plot "Risky-Typical Trades"
  set-current-plot-pen "risky-typical-trades"
  plot risky-typical-trades
  set-current-plot "Risky-Smart Trades"
  set-current-plot-pen "risky-smart-trades"
  plot risky-smart-trades
  set-current-plot "Typical-Typical Trades"
  set-current-plot-pen "typical-typical-trades"
  plot typical-typical-trades
  set-current-plot "Typical-Smart Trades"
  set-current-plot-pen "typical-smart-trades"
  plot typical-smart-trades
  set-current-plot "Smart-Smart Trades"
  set-current-plot-pen "smart-smart-trades"
  plot smart-smart-trades
  end
@#$#@#$#@
GRAPHICS-WINDOW
386
10
751
276
35
23
5.0
1
10
1
1
1
0
1
1
1
-35
35
-23
23
0
0
1
ticks
30.0

BUTTON
249
11
309
44
GO
go
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
191
11
251
44
SETUP
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

BUTTON
309
10
381
43
STEP ONCE
go
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
220
57
379
102
NIL
price
4
1
11

MONITOR
220
102
379
147
NIL
present-value
4
1
11

MONITOR
221
145
330
190
NIL
news-qualitative-meaning
0
1
11

SLIDER
2
51
180
84
smart
smart
0
100
5
1
1
NIL
HORIZONTAL

SLIDER
2
10
180
43
max-news-sensitivity
max-news-sensitivity
0
1
0.5
0.01
1
NIL
HORIZONTAL

PLOT
5
362
373
512
PRICE
time
price
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"price" 1.0 0 -13345367 true "" ""

SLIDER
2
84
181
117
typical
typical
0
100
90
1
1
NIL
HORIZONTAL

MONITOR
373
424
530
469
NIL
average-price\n
3
1
11

MONITOR
386
284
443
329
NIL
time
3
1
11

MONITOR
373
468
529
513
NIL
min-price
3
1
11

MONITOR
373
381
529
426
NIL
max-price
3
1
11

SLIDER
3
117
181
150
endowment
endowment
0
5000
4010
10
1
NIL
HORIZONTAL

SLIDER
3
150
190
183
maximum-debt
maximum-debt
-1000000
0
0
10
1
NIL
HORIZONTAL

MONITOR
454
285
511
330
failed
number-of-yellow
3
1
11

MONITOR
375
543
536
588
NIL
max-portfolio-value
3
1
11

MONITOR
375
586
536
631
NIL
average-portfolio-value
3
1
11

MONITOR
375
630
536
675
NIL
min-portfolio-value\n
3
1
11

PLOT
5
515
374
688
Min, Average and Max Portfolio Value
time
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"min-portfolio-value" 1.0 0 -16777216 true "" ""
"average-portfolio-value" 1.0 0 -2674135 true "" ""
"max-portfolio-value" 1.0 0 -11221820 true "" ""

PLOT
537
537
1010
687
Min, Average and Max Liquidity
time
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"min-liquidity" 1.0 0 -16777216 true "" ""
"average-liquidity" 1.0 0 -2674135 true "" ""
"max-liquidity" 1.0 0 -11221820 true "" ""

MONITOR
1008
547
1168
592
NIL
min-liquidity
6
1
11

MONITOR
1008
592
1159
637
NIL
max-liquidity
6
1
11

MONITOR
1008
637
1164
682
NIL
average-liquidity
6
1
11

PLOT
757
10
957
160
Risky-Risky Trades
time
# of trades
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"risky-risky-trades" 1.0 0 -2674135 true "" ""

PLOT
957
10
1157
160
Risky-Typical Trades
time
# of trades
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"risky-typical-trades" 1.0 0 -6459832 true "" ""

PLOT
757
160
957
310
Risky-Smart Trades
time
# of trades
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"risky-smart-trades" 1.0 0 -1604481 true "" ""

PLOT
957
160
1157
310
Typical-Typical Trades
time
# of trades
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"typical-typical-trades" 1.0 0 -10899396 true "" ""

PLOT
757
310
957
460
Typical-Smart Trades
time
# of trades
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"typical-smart-trades" 1.0 0 -6565750 true "" ""

PLOT
957
310
1157
460
Smart-Smart Trades
time
# of trades
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"smart-smart-trades" 1.0 0 -16777216 true "" ""

MONITOR
523
285
580
330
Smarts
number-of-white
0
1
11

MONITOR
587
285
651
330
Typicals
number-of-green
0
1
11

MONITOR
658
286
715
331
Riskys
number-of-red
0
1
11

@#$#@#$#@
## WHAT IS THIS MODEL?
In Trade Clusters, there are three types of agents trading a single stock. They decide to buy when they believe that the present value of the stock is higher than the price and sell when the converse is true. They default (or, if you prefer, leave the market) when they want to buy at a specific price but lack the funds to do so. The three types of agents, Smarts (white patches on the NetLogo screen), Typicals (green), and Riskys (red) differ by how accurate their personal present values are compared to the actual present value. Smarts are right within 20%, Typicals within 40%, and Riskys within 60%. The global present value is the price plus a news factor. When there is good news about the stock (+1), the present value is higher, but when there is bad news (-1), it gets lower. Given all of that, our overarching curiosity was which agents would trade with each other, and that led to numerous smaller questions. For instance, would the Smarts try to take advantage of the Riskys or would they only trust the members of their own clique? To find out the answer, we go into the model.

##HOW TO USE IT
Before you start simulating the model, take a look at the sliders on the left. At the top is sensitivity to the news–should present value be affected more or less by good news and bad news? Afterwards, we get to the percentage of smart and typical agents. If the sum of those two sliders is less than 100, then the remaining percent of agents will be Riskys. (If they are above 100, you will get an error message.) Next up is the endowment–how much cash each of the agents start with at the beginning of the simulation. (They also each are given one share of the stock). Finally, we have the maximum debt, how much agents are able to pay beyond the money they have at any given moment before they default and turn yellow on the NetLogo screen.

Once you set all of those sliders, hit SETUP and then GO. You can also do STEP ONCE if you want to see the process of buying and selling happen for just one cycle before witnessing it for a more extended period. 

##WHAT TO WATCH FOR
As you let the simulation run, there are a variety of factors to watch out for. The thing that may jump out first is the price graph. At times the price will be zigzagging up and down and the graph will be quite amusing to watch. There are also graphs for the minimum, average, and maximum portfolio values (who owns the most stock and how much it’s worth) and liquidity values (who owns the most cash). Next to each of the graphs, the numbers for the minimum, average, and maximum values are listed. You will especially want to look at those if a number gets so high or so low that it leaves the graph or if it went high enough at one point that the scale is completely off. (For an example of how they’re supposed to look, try doing the simulation with all Typicals.) If you ever want to see the values in a graph, you can right-click to export them as a .csv file.

On the right, meanwhile, we have the trades taking place between the different groups of agents. Sometimes all the graphs will look the same, but at other times, there will be clear differences. Be sure to pay attention to the scale–sometimes the pattern on the graphs will look similar, but one graph will have a maximum Y value of 600 while the other has only 300
Then, right under the box with all the agents, we have a variety of “monitors,” as NetLogo calls them. The time is how many trading cycles the model has run through, “failed” is how many agents have defaulted, and “Smarts,” “Typicals,” and “Riskys” are the number of agents of each type. There are 3337 agents to start with (not that I have any idea where that number comes from), and it may be worth noting to click “GO” twice quickly or to multiply 3337 by the slider values to see how many agents you started with of each type. From there, you can watch to find out who will survive and how quickly the defaults occur.

##MECHANICS OF THE MODEL
The big things to explain from this model are how trades happen and how the price is set. In each cycle (or one unit in time), each agent looks at its evaluation and decides whether to buy or sell based on its personal present value and the current price of the stock. As mentioned above, the personal present values are within 20% above or below the actual present value for Smarts, within 40% for the Typicals, and within 60% for the the Riskys. Each cycle, they get a new value within the appropriate range–they do not, for instance, always have a personal present value of 17% above the actual present value.

If the agent’s present value is higher than the current price, he “asks” the agents directly next to him how much they would need to receive in order to sell one share to him. Each agent automatically responds with his own valuation of the present value and the buying agent accepts the lowest offer as long as it is less than his valuation of the stock’s value. If it would be an unfavorable deal for him, the transaction does not go through.

If the first agent decides to sell, meanwhile, each adjacent agent responds with his valuation and the agent who submits the highest offer will get the share as long as it is above the first agent’s valuation. Each agent gets a chance to initiate a transaction in every cycle before the model moves on.

The price, meanwhile, is the average of the best offers that were accepted by the agents. The system records the total price paid to trade shares and the total number of transactions at each moment and the price is the former divided by the latter. Each new accepted trade adds its price to the numerator of that equation and 1 to the denominator. The price changes after each trade and the present value is readjusted to be that number plus a factor based on the news and the news sensitivity values (both mentioned above). That is also worth noting for the graphs–they only record values for the prices, etc. at the end of cycles even though everything is constantly changing within cycles as well. The fact that the trades don’t technically happen instantaneously is irrelevant in the long-run because the order is random. Overall, the price is a weighted average of the price paid for each trade over the course of the simulation.

##WHEN TO STOP
A major thing to note with this model is that sometimes the substance of the simulations in this model can be extremely quick. At no point should every agent default, but often trading will stop or nearly stop. When it is too high, usually what has happened is that every agent still “alive” is surrounded by failed agents. Trading is done with each agent’s adjacent agents, so once there are no more adjacent agents to trade with, an agent can no longer trade. When it’s too low, meanwhile, usually it means that every living agent has already cashed out and nobody wants to buy the stock anymore. Whenever either of those scenarios happen, it’s time to hit the GO button again, maybe look at the results, and move onto a simulation with something different, like a new number of Smarts.

##STORIES AND TAKEAWAYS (WARNING: SPOILERS)
I went through many different versions of the model and saw in it quite a few lessons that are applicable in the real world. I conducted most of these simulations with a news sensitivity of 0.50, an endowment of 3990, and a maximum debt of 0.

All Smarts: Utopia
When every agent in Trade Clusters is a Smart, the dream scenario occurs. Nobody defaults and they all become gazillionaires with very little variance. It takes them some time to calibrate (the price got as low as 2.3), but they all make their money, cash out, and make very few trades the rest of the way. The price (and people’s wealth) will continue to infinity (and you’ll eventually get a warning from NetLogo) as one transaction happens per period for a while between someone with a higher valuation of the stock and another with a lower valuation. The lesson: if everyone was smart, the world would be great. Unfortunately, we are not all smart.

Smarts and Typicals: Everything Falls Apart
Add in just 1% Typicals to the smarts, and the price quickly goes to zero. Some people do slightly well, but they don’t come anywhere near infinite wealth. No one defaults once again, but the Smarts compete to try to prove that they are better than the Typicals and make everyone much worse off because of it. Lessons: don’t be overly competitive–if you truly are better, you don’t need to prove it–and perfection is so easy to destroy. 

The same results hold true nearly all the time whenever there are only Smarts and Typicals in our simulation (although occasionally several Typicals will default early on and give the Smarts a nice round) other than a couple of short stretches like from 85% Smarts and 15% Typicals to 75% and 25% and around 95% and 5% where the Smarts do a little bit better than that. Whenever we increase the number of Typicals, there is a fundamental tradeoff for the Smarts between having access to more Typicals and the Typicals being around more of their own kind and not trading as much with the Smarts. Nearly all the time, the latter outweighs the former. The biggest takeaway from these situations with only Smarts and Typicals is how difficult it is to con an honest man. If he is even-keeled and has integrity, you are never going to be able to get him for more than a few dollars. A major reason for that is strength in numbers–people walking in crowds at night rather than by themselves much more rarely get mugged and it doesn’t matter how clever you are if word quickly spreads warning people about you.

99% Smarts, 1% Riskys: When You See An Opportunity…
When we replace the Typicals with Riskys, though, we get an entirely divergent result. The Smarts are able to exploit the Riskys and eliminate them quickly to get back to the utopian state from above. The major lesson here is the downfalls of ordinary people are desperation and the need for excitement. Once they need a big pile of cash to pay of debts or get so exhilarated by making a quick buck that they are hooked, the con men and swindlers can have a field day. 

A similar pattern holds true no matter how you divide the Smarts and Riskys as long as there are no Typicals. Nearly all the Riskys default, with the only ones that don’t being the ones who are surrounded on all sides by people who default and can no longer trade. The only thing that increasing numbers does for the Riskys is ensure that more Smarts default along with them–no matter how many agents the Riskys have at the beginning, it will be decreased down to a very small number by the end. On the whole, excess risk is never worthwhile in the long-run, a lesson that even con men must internalize. There is a point where you go too far trying to take advantage of someone and get burned. Some people will get lucky if they take a lot of risks (the people who “survive”), but the risk of losing it all long before that is simply too high.


All Typicals: The Real World
We can't say that we expected the all Typicals model to be so interesting. Unlike the Smarts, the Typicals are always going to fluctuate. Even if it seems like they are going off to infinity, they will so often come all the way back down. The price graph ends up looking a great deal like the price graph for a stock, only with the peaks higher and the nadirs lower–I guess we have brokers to make that less extreme. Some people make a decent amount of money for themselves, but others default and most make just a modest return. The lessons from this version of the model are manifold–for instance, we are not smart enough to create a perfect society, nothing in this world lasts forever, and who succeeds and who fails has a lot to do with luck.

Typicals and Riskys: Chaos
The Typicals trust the Riskys more than the Smarts. The Riskys are not trying to take advantage of the Typicals–they’re telling them that they have a legitimate chance to get rich, and they are being entirely honest as they say that. Once the Typicals begin to go along with them, however, their results vary wildly. In the beginning, once we add in just a few Riskys, some Typicals default but most of them end up with a lot more money than they had before. Once the proportion of Riskys gets more substantial, however, some Typicals and Riskys end up rich beyond their wildest dreams but most of them lose everything. The price of the stock gets unbelievably high, but until you make the Risky to Typical ratio until at least 8.5 or 9, the price will nearly always eventually go back down to zero. A few people make it big, but many more default and others end up holding onto the stock for too long and paying dearly for that. One lesson from the part of this is that some risk is worthwhile–it makes sense to incur a small chance of default if it will make you a lot more money on the whole. Afterwards, however, the variance of results will simply get to be too much and at a certain point, you are just getting crazy. It is so important to know when to sell because there is always the chance of making more money, but you can’t get greedy and need to have a number where if you get there, you will sell and be happy with what you have no matter what happens.

All Riskys: The Wild West
This model goes awfully quickly: nearly everyone defaults, but the few that remain make the big bucks. Even though everyone is being just as risky, it doesn’t matter what all the people around you are doing because even when that is true, the strategy is simply very low-percentage. That’s a nice little story about peer pressure–don’t fall for it–as a small chance of being wealthy is not worth the high probability of ruining your life. It’s not even about being a good cowboy–it’s about being a lucky cowboy. Trades ever stop in this simulation is that everyone is surrounded by people who defaulted and have no one with whom to trade.

1/3 Smarts, 1/3 Typicals, 1/3 Riskys: The Smarts Prove Their Worth
This model was originally about trade clusters, but we haven’t mentioned trading between groups a single time in this story section. Let’s do so right now. This model is crazy, with plenty of agents defaulting from all three groups and most of the rest getting very rich, but what stands out is that every single time I have run this simulation, there have been more Smarts left than Typicals and Riskys after just a few cycles, and often as many as both of them combined. To help explain that, look at the graphs on the right about trading within groups. There is a lot more variability within this model than in all of the ones we discussed previously, but every single time, the Smart-Smart trades will be different than any other transaction. Sometimes they simply trade with each other much less, either in terms of how often they trade or how much they trade when they do get together. At other times, it’s more subtle–maybe their graph looks like everyone else’s at the end, but if you were watching at the beginning, you saw a big lull after everyone else had already been trading. Two lessons from that are that yes, the smart people will win the survival of the fittest, and that dividing territory (as smart people or as say drug dealers or con men) is critical for the group's success.

Even when we shift to 22% Smarts, 37% Typicals, and 37% Riskys, the Smarts will still usually finish with the highest number by trading with each other even less. Even at 8%, 46%, and 46%, they can still finish with a higher number than the Riskys. It makes sense that as a group gets smaller, it will trade with each other less, but the slope of the drop-off for the Smarts is much steeper than for say the Typicals, who will trade with each other about as often as before at 40%, 20%, and 40% until nearly all of them have defaulted. Speaking of alignments like that, Smarts will always dominate in such situations, trading with each other an incredibly small amount while slowly taking advantage of the Riskys (who are, in turn, bringing down the Typicals) until nearly all of them default. The Typicals do much better when we keep them and the Smarts the same starting percentage while decreasing the Riskys. The Smarts handle the Typicals much better when there are Riskys around, but they certainly don’t eliminate them in the same way.

There are many more possible alignments, but the last one I will talk about is 80% Typicals, 10% Smarts, and 10% Riskys, which seems like a decent enough comparison for the real world. In that case, what really stands out is how much more the Typicals trade with the Riskys than with the Smarts–and on the other side, how much more the Smarts trade with the Riskys than the Typicals even though the Riskys are another minority. The first part of that goes back to Typicals trusting Riskys more than Smarts, but the second half is more interesting. What it tells us is that Smarts only need an exploitable minority to succeed–it doesn’t even matter if the majority won’t fall for their tricks. We see a similar pattern when there are 90% Typicals and 5% of the other two until most of the Riskys have defaulted.

##CONNECTION TO OPIM 319
For Professor Kimbrough, I will connect this model to the things we have learned in OPIM 319. Firstly, we spent a few lectures on NetLogo and this is a NetLogo model. It is also very strategic, with agents achieving wildly different results based on the construction of the people around them. Even within groups, there is a variety of different types of behavior that we witness. Finally, the preceding section about takeaways was almost entirely about framing. The model returns data and it is up to us to look at the results, make conclusions, and see how we can apply them to the real world.

##ACKNOWLEDGEMENTS
We started with the MULTIAGENT model from Northwestern.

-Caldana M., Cova P., and Viano U., MULTIAGENT, 2006 (http://ccl.northwestern.edu/netlogo/models/community/multiagent)

We changed almost everything, although we needed their interface to get started and did stick with some small conceptual aspects of it like the impact of news. We needed something to go off of having never programmed in NetLogo before, and we were lucky that we found their model and were able to take off from there.
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
Circle -7500403 true true 30 30 240

circle 2
false
0
Circle -7500403 true true 16 16 270
Circle -16777216 true false 46 46 210

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

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
Polygon -7500403 true true 60 270 150 0 240 270 15 105 285 105
Polygon -7500403 true true 75 120 105 210 195 210 225 120 150 75

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
