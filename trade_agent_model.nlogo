patches-own[ my-sentiment 
             ;; Each "imitator" can have a positive sentiment (+1), in which case he is 'bullish',
             ;; that is he believes the market will rise, or he can have a 
             ;; negative sentiment (-1) in which case he is 'bearish', that is he believes the market will fall.
             ;; If the sentiment is positive the trader buys one share if it is negative he sells
             ;; one share.
             
             my-convinction
             ;; It's the equivalent of my-sentiment, but for the "fundamentalists"; it is based on rational criteria. As the name suggests, 
             ;; it represents the conviction of losing or gaining money by holding the share and so it determines the buy or the sell of the share.          
             
             my-decision
             ;; It's the same of the previous ones for "stubborns".
             
             my-total
             ;; Represents the sum of sentiment, convinction and decision of neighbors, weighted by propensity to be influenced by them.
                                        
             number-of-shares 
            ;; Number of shares that each trader has (if negative it implies that the
            ;; trader is 'short' (we assume that there are no limits to short selling).
            
            old-number-of-shares
            ;; It is the number-of-shares at time-1
            
            liquidity 
            ;; It represents the quantity of money which each agent has at the end of every transaction.
            
            portfolio-value
            ;; This variable represents each agent's portfolio, computed as 
            ;; actual stock price times the number of stock in portfolio, after every transaction.
             
             opinion-vol 
             ;; Volatility in a "imitator"'s own interpretation of the news.
              
             behavior-vol
             ;; Probability that the "fundamentalists" will be influenced by the sentiments of the neighbours and will start to act as "imitators". 

                          
             propensity-to-sentiment-contagion
             propensity-to-sentiment-contagion-base
             ; Propensity to be influenced by neighbours' sentiments regarding the news qualitative nature.
             
             propensity-to-imitation
             ;; propensity of "imitators" to copy the behaviour of the "fundamentalists".
             
             propensity-to-decision
             ;; propensity of "imitators" to copy the behaviour of the "stubborns".
             
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
             

 globals [log-price
          log-price-%variation
          ;; The first is the current price, due to the sum of demand and supply; it moves according to the market returns. 
          ;; The second is the variation of the price, as a percentage of the current price, determined by demand and supply.
         
         price
         old-price
         price-%variation
         ;; The first is the price of the stock each time, calculated as exp (log-price), the second is the same variabile at time-1,
         ;; while the third is the price per cent variation.
         
         average-price
         min-price
         max-price
         ;; They measure the average, the minimum and the maximum price of the stock.
         
         average-return
         min-return
         max-return
         ;; They measure the average, the minimum and the maximum return of the stock.
         
         number-of-yellow
         ;; It counts the number of already failed agents.
      
  
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
         
         return-numerator1
         return-numerator2
         return-numerator3
         return-numerator
         return-denominator
         return
         ;; The return of the market is calculated dividing the difference between buyers and sellers by the total amont of operators.       
      
         news-qualitative-meaning 
         ;; The news concerning the market get to every operator, and they are the rational component of the decision 
                  
                 
         number-of-fundamentalists
         number-of-imitators
         number-of-optimists
         number-of-pessimists
         ;; They can change, because of the conversions.
                          
         indicator-volatility
         ;; It is the variability of the market's quotations.
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
    
  set present-value 0
  set log-price 0
  set time 0
  ask patches
  [set liquidity endowment]

  ;; It shapes the "imitators"
  ask patches with [pcolor = green]
  [set number-of-shares 1 
  set opinion-vol sigma + random-float 0.1
  set news-sensitivity (random-float max-news-sensitivity)
  set propensity-to-sentiment-contagion-base (random-float max-propensity-to-sentiment-contagion-base)
  set propensity-to-sentiment-contagion propensity-to-sentiment-contagion-base
  set propensity-to-imitation random-float max-propensity-to-imitation
  set propensity-to-decision random-float max-propensity-to-decision
  set typical-counter 1]    
  ;; It shapes the "fundamentalists"
  ask patches with [pcolor = white]
  [set number-of-shares 1 
  set behavior-vol max-behavior-vol
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
  update-market-sentiment
  ;modify-categories
  compute-indicator-volatility
  do-plot
 end
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Number of shares at time-1 ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; This updates the variable "old-number-of-shares" to the number of shares which every agent had in her portfolio at time-1
 
 to old-number
 ask patches
 [set old-number-of-shares number-of-shares]
 end


 ;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; News Arrival mechanism ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; The news act as a random normal variable and they change the value of the share.
 
 to news-arrival
  ifelse (random-float 1) >= .5
  [set news-qualitative-meaning 1
  set present-value present-value + random-float 1.00]
  [set news-qualitative-meaning -1
  set present-value present-value - random-float 1.00]
 end


 ;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Agent's decision rule ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Whether the "imitators" are optimist and buy the share, depends on the four elements you can find here. If the sum of them is positive the "imitators" are optimist.  
 
   
  to typical-decision
    ask patches with [pcolor = green]
   [let random-value random-float 0.8
   ifelse ((present-value * random-value) > (log-price * 0.4))
   [set my-decision 1
   set number-of-shares number-of-shares + 1]
   [set my-decision -1
   set number-of-shares number-of-shares - 1]]
  ;ask patches
  ;[if (pcolor != red) and (pcolor != white) and (pcolor != yellow)
  ;[ifelse all-or-just-neighbors?
  ;[set my-total (propensity-to-sentiment-contagion * sum [my-sentiment] of patches +
  ;propensity-to-imitation * sum [my-convinction] of patches + propensity-to-decision * sum [my-decision] of patches +
  ;news-sensitivity * (news-qualitative-meaning) + random-normal epsilon opinion-vol)]
  ;[set my-total (sum [ propensity-to-sentiment-contagion * my-sentiment +
  ;propensity-to-imitation * my-convinction + propensity-to-decision * my-decision +
  ;news-sensitivity * (news-qualitative-meaning) + random-normal epsilon opinion-vol ] of neighbors ) ]]]
  ;ask patches
  ;[if (pcolor != red) and (pcolor != white) and (pcolor != yellow)
  ;  [ifelse (my-total > 1)
  ;    [set my-sentiment 1
  ;    set number-of-shares number-of-shares + 1
  ;    set optimists-counter 1
  ;    set pessimists-counter 0]
  ;      [ifelse (my-total > 0)
  ;        [ifelse strong-change?
  ;        [set my-sentiment -1
  ;        set number-of-shares number-of-shares - 1
  ;        set pessimists-counter 1
  ;        set optimists-counter 0]
  ;        [set my-sentiment 1
  ;        set number-of-shares number-of-shares + 1
  ;        set pessimists-counter 0
  ;        set optimists-counter 1]]
  ;          [ifelse (my-total = 0)
  ;            [ifelse weak-change?
  ;            [set my-sentiment 1
  ;            set number-of-shares number-of-shares + 1
  ;            set pessimists-counter 0
  ;            set optimists-counter 1]   
  ;            [set my-sentiment -1
  ;            set number-of-shares number-of-shares - 1
  ;            set pessimists-counter 1
  ;            set optimists-counter 0]]
  ;    [set my-sentiment -1
  ;    set number-of-shares number-of-shares - 1
  ;    set pessimists-counter 1
  ;    set optimists-counter 0]]]]]
  
  ;; separate pessimists from optimists:
  ;ask patches
  ;[if (pcolor != red) and (pcolor != white) and (pcolor != yellow)
  ;[if my-sentiment = 1
  ;[set pcolor blue + 3]
  ;if my-sentiment = -1
  ;[set pcolor black]]]
  end
 
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; fundamentalist's decision ; 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; The "fundamentalist" buy the share if they think it is understimated, otherwise they sell. 
 ;
 
 to smart-decision
  ask patches with [pcolor = white] 
  [let random-value random-float 0.4
  ifelse ((present-value * random-value) > (log-price * 0.2)) 
  [set my-convinction 1
  set number-of-shares number-of-shares + 1]
  [set my-convinction -1
  set number-of-shares number-of-shares - 1]]
 end 
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Stubborn's decision       ; 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; The "stubborn" buy or sell the share randomly. 
 ;
 
 to risky-decision
   ask patches with [pcolor = red]
   [let random-value random-float 1.2
   ifelse ((present-value * random-value) > (log-price * 0.6))
   [set my-decision 1
   set number-of-shares number-of-shares + 1]
   [set my-decision -1
   set number-of-shares number-of-shares - 1]]
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


 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Market clearing mechanism ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; We compute the price and the return , as they result from the actions undertaken by the operators.The return is the eccess of demand over the supply, divided by the dimension of the market.
 ;
 
   to market-clearing 
   ;; The denominator is the number of agents.
   set return-denominator count patches with [pcolor != yellow]
   ;; The numerator is the difference between sellers and buyers.
   set return-numerator1 sum [my-convinction] of patches 
   set return-numerator2 sum [my-sentiment] of patches
   set return-numerator3 sum [my-decision] of patches
   set return-numerator (return-numerator1 + return-numerator2 + return-numerator3)
   ;; The return modifies the price of the share.
   ask patches
   [ifelse return-denominator = 0
   [set return 0] 
   [set return return-numerator / return-denominator]]
   set old-price price
   set log-price log-price + return
   set price exp log-price
   
   ask patches
   [ifelse time = 1
   [set price-%variation 0]
   [set price-%variation ln (price / old-price)]]
   ask patches
   [if time = 1
   [set average-price price
    set min-price price
    set max-price price
    set average-return return
    set min-return return
    set max-return return]]
   set average-price average-price * (time - 1) / time + price / time
   set average-return average-return * (time - 1) / time + return / time
   ask patches
   [ifelse (price - min-price) > 0
   [set min-price min-price]
   [set min-price price]] 
   ask patches
   [ifelse (max-price - price) > 0
   [set max-price max-price]
   [set max-price price]] 
   ask patches
   [ifelse (return - min-return) > 0
   [set min-return min-return]
   [set min-return return]] 
   ask patches
   [ifelse (max-return - return) > 0
   [set max-return max-return]
   [set max-return return]]       
 end
 
 
 ;;;;;;;;;;;;
 ; Failures ;
 ;;;;;;;;;;;;
 
 to fail-or-survive
 ask patches with [pcolor != yellow]
 [ifelse (liquidity + portfolio-value) < maximum-debt
 [set pcolor yellow
  set number-of-shares 0
  set my-convinction 0
  set my-decision 0
  set my-sentiment 0]
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
  set number-of-shares 0
  set my-convinction 0
  set my-decision 0
  set my-sentiment 0]]

 set number-of-yellow count patches with [pcolor = yellow]
 
 set average-portfolio-value (sum [portfolio-value] of patches) / (count patches with [pcolor != yellow] + .0000000000000000001)
 ;; We need to do that because, if every agent has failed, the program returns a division-by-zero error.   
 set min-portfolio-value min [portfolio-value] of patches
 set max-portfolio-value max [portfolio-value] of patches
 
  set average-liquidity (sum [liquidity] of patches) / (count patches with [pcolor != yellow] + .0000000000000000001)
 ;; We need to do that because, if every agent has failed, the program returns a division-by-zero error.   
 set min-liquidity min [liquidity] of patches
 set max-liquidity max [liquidity] of patches
 end

 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Update market sentiment ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; If a good news is followed by an increase of the price, the confidence of the "imitators" in other people's sentiments increases.

 to update-market-sentiment
  ask patches 
  [if (pcolor != red) and (pcolor != white) and (pcolor != yellow)
  [if (return > 0) and (news-qualitative-meaning > 0)
  [set propensity-to-sentiment-contagion  propensity-to-sentiment-contagion-base + return]
  if (return > 0) and (news-qualitative-meaning < 0)
  [set propensity-to-sentiment-contagion  propensity-to-sentiment-contagion-base - return]
  if (return < 0) and (news-qualitative-meaning < 0)
  [set propensity-to-sentiment-contagion  propensity-to-sentiment-contagion-base - return] 
  if (return < 0) and (news-qualitative-meaning > 0)
  [set propensity-to-sentiment-contagion  propensity-to-sentiment-contagion-base + return]]]    
 end
    
   
 ;;;;;;;;;;;;;;;;;;;;;;;;
 ; Change agents' type  ;
 ;;;;;;;;;;;;;;;;;;;;;;;;
 ;; If many colleagues are optimist or pessimist, the "fundamentalist" can change their type and become "imitators" 
 ;; Randomly the "imitators" become "fundamentalist".
 
 ;to modify-categories
  ;; It trasforms some "imitators" in "fundamentalist". 
 ; ask patches 
 ;   [if (pcolor != red) and (pcolor != white) and (pcolor != yellow)
 ; [if (random-float 3000) < new-fundamentalists
 ; [set pcolor white
 ; set behavior-vol max-behavior-vol
 ; set smart-counter 1]]]
 ; ;; Here the opposite happens
 ; ask patches with [pcolor = white]
 ; [set number-of-optimists sum [optimists-counter] of neighbors
 ; set number-of-pessimists sum [pessimists-counter] of neighbors]
 ; ask patches with [pcolor = white]
 ; [if (number-of-pessimists) > behavior-vol
 ; [change-type1]]
 ; ask patches with [pcolor = white]
 ; [if (number-of-optimists) > behavior-vol
 ; [change-type2]]
 ;end
   
    to change-type1 ;; The "fundamentalist" become pessimistic.
    ask patches with [pcolor = white]
    [if (random-float 100) < change-probability
    [set pcolor black]]
    set opinion-vol (sigma + random-float 0.1)
    set news-sensitivity (random-float max-news-sensitivity)
    set propensity-to-sentiment-contagion (random-float max-propensity-to-sentiment-contagion-base)
    set typical-counter 1
    set pessimists-counter 1
    set smart-counter 0
   end
   to change-type2 ;; The "fundamentalist" become optimistic.
    ask patches with [pcolor = white]
    [if (random-float 100) < change-probability
    [set pcolor blue + 3]]
    set opinion-vol (sigma + random-float 0.1)
    set news-sensitivity (random-float max-news-sensitivity)
    set propensity-to-sentiment-contagion (random-float max-propensity-to-sentiment-contagion-base)
    set typical-counter 1
    set optimists-counter 1
    set smart-counter 0
   end

 
 ;;;;;;;;;;;;;;;;;;;;;;;;
 ; Deviations to EMH    ;
 ;;;;;;;;;;;;;;;;;;;;;;;;
 ;; The volatility of the share market refers to the absolute value of the return.  
 

 to compute-indicator-volatility
  set indicator-volatility abs(return)
 end



 ;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Plot Graphics          ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; We draw the graphs of price, of market volatility and of return.
 
 
 to do-plot
  set-current-plot "Price"
  set-current-plot-pen "price"
  plot price
  set-current-plot "Return"
  set-current-plot-pen "return"
  plot return
  set-current-plot "Volatility"
  set-current-plot-pen "indicator-volatility"
  plot indicator-volatility
  set-current-plot "Price-%variation"
  set-current-plot-pen "Price-%variation"
  plot price-%variation
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
248
45
308
78
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
190
45
250
78
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
308
44
380
77
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
197
181
262
226
NIL
price
6
1
11

MONITOR
262
181
371
226
NIL
present-value
2
1
11

MONITOR
262
230
371
275
NIL
news-qualitative-meaning
0
1
11

MONITOR
197
230
262
275
NIL
return
2
1
11

SLIDER
7
174
185
207
smart
smart
0
100
33
1
1
NIL
HORIZONTAL

SLIDER
284
10
376
43
sigma
sigma
0.5
1
0.9
0.0010
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
0.67
0.01
1
NIL
HORIZONTAL

SLIDER
2
75
180
108
max-propensity-to-sentiment-contagion-base
max-propensity-to-sentiment-contagion-base
0
1
0.78
0.01
1
NIL
HORIZONTAL

SLIDER
2
42
180
75
max-propensity-to-imitation
max-propensity-to-imitation
0
1
0.64
0.01
1
NIL
HORIZONTAL

SLIDER
8
239
186
272
max-behavior-vol
max-behavior-vol
0
8
4
1
1
NIL
HORIZONTAL

SLIDER
192
10
284
43
epsilon
epsilon
-1
1
0.04
0.01
1
NIL
HORIZONTAL

SLIDER
7
141
185
174
new-fundamentalists
new-fundamentalists
0
10
3
1
1
NIL
HORIZONTAL

SLIDER
8
271
186
304
change-probability
change-probability
0
100
50
1
1
NIL
HORIZONTAL

PLOT
5
336
373
486
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

PLOT
4
485
372
635
RETURN
time
return
0.0
100.0
-0.1
0.1
true
false
"" ""
PENS
"return" 1.0 0 -955883 true "" ""

PLOT
372
485
741
635
VOLATILITY
time
indicator-volatility
0.0
100.0
0.0
1.5
true
false
"" ""
PENS
"indicator-volatility" 1.0 0 -8630108 true "" ""

PLOT
372
335
741
485
PRICE-%VARIATION
time
price-%variation
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"price-%variation" 1.0 0 -5825686 true "" ""

SLIDER
7
207
186
240
typical
typical
0
100
33
1
1
NIL
HORIZONTAL

SWITCH
194
143
378
176
weak-change?
weak-change?
0
1
-1000

SWITCH
194
111
378
144
strong-change?
strong-change?
1
1
-1000

SWITCH
193
79
378
112
all-or-just-neighbors?
all-or-just-neighbors?
0
1
-1000

MONITOR
760
439
855
484
NIL
average-price\n
3
1
11

MONITOR
862
438
959
483
NIL
average-return
3
1
11

MONITOR
406
281
463
326
NIL
time
3
1
11

MONITOR
757
338
854
383
NIL
min-price
3
1
11

MONITOR
759
387
854
432
NIL
max-price
3
1
11

MONITOR
861
338
958
383
NIL
min-return
3
1
11

MONITOR
861
388
959
433
NIL
max-return
3
1
11

SLIDER
8
303
186
336
endowment
endowment
0
1000000
0
10
1
NIL
HORIZONTAL

SLIDER
192
284
379
317
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
478
282
540
327
NIL
log-price
6
1
11

MONITOR
549
282
606
327
failed
number-of-yellow
3
1
11

MONITOR
401
694
521
739
NIL
max-portfolio-value
3
1
11

MONITOR
401
748
544
793
NIL
average-portfolio-value
3
1
11

MONITOR
402
641
518
686
NIL
min-portfolio-value\n
3
1
11

PLOT
3
635
372
808
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
558
647
758
797
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
779
646
856
691
NIL
min-liquidity
6
1
11

MONITOR
782
701
863
746
NIL
max-liquidity
6
1
11

MONITOR
788
757
892
802
NIL
average-liquidity
6
1
11

SLIDER
4
108
183
141
max-propensity-to-decision
max-propensity-to-decision
0
1
0.67
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

The aim of our program is the creation of a financial market in which a single stock is traded; the agents (three categories) who act on such market are characterized by bounded rationality and differentiated into three types according to their behavior (Imitator, Fundamentalist and Stubborn); moreover, every agent has a tied budget, expressed by an endowment and a maximum debt they can reach before default. Through the imposition of some conditions, in part introduced by the user who can easy interact with the program and in part determined casually, we have realized some interesting simulations with various results, demonstrating that simple hypotheses are sufficient to induce complessity.

## HOW TO USE IT

Click the SET UP button to setup the operators (patches).  
Click the GO button to run the simulation.  
The operators, or agents, can be divided into three categories: �imitator� (I), �fundamentalist� (FD) and "stubborn" (ST).  
With the sliders FUNDAMENTALISTS and IMITATORS you can choose the average percentage of fundamentalists and imitators; the percentage of Stubborns is determined residually.   
The I are characterized, as in AFM (Artificial Financial Markets, see below), by the volatility of their opinions, the sensitivity to the news, the propensity to sentiment contagion, imitation and decision (the sentiment contagion refers to the sentiments of the I surrounding the patch; the imitation is concerned with the FD neighbours; the decision with the ST neighbors).   
To set these features you can use the slides provided. Each slide defines the maximal value which the features can reach. Then every operator gets a randomly-distributed value between 0 and the maximum.  
The FD have only one feature: the behavior volatility, which determines their chances of turning into I.

The procedure "GO" is based on the AFM model. First, new informations arrive on the market and the news have a uniform distribution between 0 and 1. Despite all the values which the news can have, every value above 0.5 is turned into 1 (good news) and every value below 0.5 is turned into -1 (bad news).  
The I act first: they set up their opinion (they can be optimistic or pessimistic) and then decide between buying and selling.   
As in AFM, the opinion is the result of many factors: the opinion of the I neighbours (as it was in the last period) multiplied by the propensity to sentiment contagion, the mood of the FD and ST neighbours multiplied by the propensity to imitation and decision, the nature of the news, multiplied by the news-sensitivity, and a random value normally distributed (the mean of the random value is set by the slider EPSILON, while its variance is set by the slider OPINION-VOL).  
The behavior of the I is partially rational, as the new information affects their behavior. On the other hand it is partially irrational, as it takes into account the behavior of the neighbours during the last period, and there is also a random component in their decision rule.  
Another type of agent is Stubborn: they buy or sell the share randomly, they are not influenced by other agents.  
After the trading is completed, the price and the return of the share are obtained as a result of everybody�s action, and the program notes the agents' balance.  
If the return of the share moves in the direction �suggested� by the new information, the irrational operators become more confident on their neighbours, and the herding behavior of the I increases. That means the propensity to market contagion increases by the amount of the return. The effect is the same if after good news the return increases, or after bad news the return decreases. If the news are not followed by the expected movement of return, the confidence decreases.  
At the end of every period, every patch has a certain chance of changing the type: the I have a chance set by the slider NEW FUNDAMENTALIST of turning into fundamentalists.   
On the other hand FD can turn optimistic or pessimistic if one of the three groups has a number of members at least as big as the value of the slider OPINION VOLATILITY surrounding the fundamentalist patch. Only the ST cannot change into anyone else, and no-one else can become ST.


## THINGS TO NOTICE

With the model described above, we have realized a great number of simulations, changing the parameters from time to time and turning on or off the switches, obtaining some interesting results.   
Our model, as Artificial Financial Market, presents very frequent crashes and bubbles, normally due to an unusual dominance of one mood over the other in the I (Noise Traders in AFM).   
At the beginning, if endowment and maximum debt are high, the market will be more stable (even if  price or return fluctuations are possible),especially in the starting phases of the market and the failed agents are unusual. In our simulation we have fixed endowment at 30 and maximum debt at zero; different values of these parameters would postponed the same scenarios.


## THINGS TO TRY 

How can be the results different?   
Watch how different are result when all-or-just-neighbors? switch is ON or OFF; when strong-change? switch is ON or OFF; when weak-change? is ON or OFF: the first one refers to the fact the user can choose if the I decide their behavior on the basis of the 8 closest patches or of the whole world; the other ones refers to the majority required to change their opinion.   
It is also interesting to look at composition of the operators; the behaviour of agents that are affected by other operators produces different situations in the market, in price and return fluctuations and in case of default.  
In general we can say that when imitators are affected only by their own 8 neighbours, the market is very stable, especially if �weak change� switch is activated. Otherwise if imitators are affected by all agents the market (especially in a second phase: 51st-100th steps) presents very frequent crashes and bubbles.  
Moreover the results of simulations can vary when the weight of each kind of agents changes, in fact we can see that if the market is dominated by fundamentalists it is less stable and this instability continues during the simulation and produces a great number of failed agents, also because there are relevant bubbles. At the contrary, a market dominated by imitators is unstable in a first moment, but it became homogeneous step to step and defaults stop.  
A scenario dominated by stubborns is more stable at the beginning, but it becomes unstable during the second phase, price rises producing a real �explosion� that determines a great number of defaults.



## NETLOGO FEATURES

The screen is the market, where the agents, which are rapresented by patches, assumes different color.  
The agents who enliven the market through the sale and the purchase of actions are divided into three categories, based on their behavior:   
1] Fondamentalists (white). They decide to buy or sell the asset if its present value is greater or smaller than the price of the asset;   
2] Imitators (green). They base their decision on the behavior of their eight neighbors or, if the all-or-just-neighbors? switch is turn on, of all the other agents who operate in the market. At first, they become optimistic, changing their color (violet), or pessimists (black), as a result of the arrival of the news on the asset; subsequently they will modify their opinion basing on the behavior of the other agents. The user can choose the degree of dependency of their decisions, activating the switch called strong-change?, in which case such agents will change their decision only with a strong majority of purchases or sales operated by their neighbors, or the switch weak-change?, in which case they change the direction of their exchange decisions simply with a parity of purchases and sales of the neighbors; if such switches were not activated, the agent imitator would follow the behavior of the absolute majority of the neighbors. The user can choose the weight, in terms of percentages, that the imitators give to the decision of all tipology of agents;   
3] Stubborns (red). The stubborns represent the noise traders of the market, deciding randomly whether to buy or to sell the asset.  
The user can choose the maximum percentage of agents of type fondamentalists and imitators (whose sum must not be over 100, otherwise there will be a message of error and the program will stop), therefore the program extracts a random number on the basis of which the proportion of such tipology of agents is determined; the number of stubborns is determined residually.  
The sum of the decisions of every agent determines the return of the asset, that will modify the price: every step the program re-computes the value of the balance of the operators, that is the number of own assets times the asset price, and the liquidity, modified by adding (in case of sale) or subtracting (in case of purchase) an amount equal to the price of the asset.   
An agent fails when her portfolio value and her liquidity is inferior than themaximum debt established by the user of the program. If only liquidity is inferior than maximum debt agent sells his shares to exceed its threshold value; otherwise if only portfolio value is inferior than maximum debt, because of a great number of short sales, liquidity is mobilized to buy assets just to get the portfolio value over its superior limit again.  
Failed agents change their colour and they become yellow, they stop to belong to one of the three typologies of agents and lose their shares, moreover they don�t affect the other agents� behaviour any more.  
The simulation has also six graphs: the price, the variation of price as a percentage, the return, the volatility of return, the minimum-average-maximum portfolio value and the minimum-average-maximum liquidity.

## SETTING THE PARAMETERS

It can be interesting to see what happens to the market by changing MAX-NEWS-SENSIBILITY, PROPENSITY-TO-IMITATION, PROPENSITY-TO SENTIMENT-CONTAGION and PROPENSITY-TO-DECISION (they characterize the behaviour of imitators with respect to news and to the opinion of imitators, fondamentalists and stubborns).

## EXTENDING THE MODEL

As explained before, in this market agents can swap only one type of stock per time; furthermore, the number of shares is potentially infinite, because agents can sell or buy the stock when they want with an "invisible counterpart" and the stock price is calculated on the basis of the direction of the trades and not on the operators' opinion.  
What would happen if these restrictions were removed?


## CREDITS AND REFERENCES

To write our program, we started from these these models:  
- Wilensky U., VOTING, 1998 ( http://ccl.northwestern.edu/netlogo/models/Voting )  
- Gon�alves C.P., ARTIFICIAL FINANCIAL MARKET, 2003
 ( http://ccl.northwestern.edu/netlogo/models/community/Artificial%20Financial%20Market )  
- Bizzotto J. - S.Bolatto - S.Minardi, LMMODEL, 2005  
( http://web.econ.unito.it/terna/tesine/luxandmarchesi )
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
