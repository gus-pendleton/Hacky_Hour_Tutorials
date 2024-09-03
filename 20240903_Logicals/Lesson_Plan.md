---
title: "Logical Operators in R"
author: Augustus Pendleton
format: html
editor: visual
editor_options: 
  chunk_output_type: console
---



## Using logical operators in R

Today, we'll learn about how we can use logical operators in R. This allows us to make decisions based on values in our data. We'll cover the basic logical operators that are commonly used, and functions in which you use them. 


## Load packages and data

::: {.cell layout-align="center"}

```{.r .cell-code}
library(tidyverse)

data <- read_csv("data/Animal_Data.csv")
```
:::


Let's preview our data:


::: {.cell layout-align="center"}

```{.r .cell-code}
data
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 8 × 2
  Animal       Weight_lb
  <chr>            <dbl>
1 Dog               30  
2 Cat               12  
3 Cow             1400  
4 Goldfish           0.2
5 Turtle             1  
6 Garter Snake       3  
7 Chicken            7  
8 Pig              400  
```
:::
:::


## Logical Operators

In order to make decisions, we need to use logical operators. Below, I demonstrate the ones I use often:


::: {.cell layout-align="center"}

```{.r .cell-code}
# Equality ("is")

1 == 1
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::

```{.r .cell-code}
"Dog" == "Dog"
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::

```{.r .cell-code}
"Dog" == "Cat"
```

::: {.cell-output .cell-output-stdout}
```
[1] FALSE
```
:::

```{.r .cell-code}
# Inequality ("is not")

1 != 2
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::

```{.r .cell-code}
1 != 1
```

::: {.cell-output .cell-output-stdout}
```
[1] FALSE
```
:::

```{.r .cell-code}
# Greater than/lesser than

1 > 2
```

::: {.cell-output .cell-output-stdout}
```
[1] FALSE
```
:::

```{.r .cell-code}
1 < 2
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::

```{.r .cell-code}
1 < 1
```

::: {.cell-output .cell-output-stdout}
```
[1] FALSE
```
:::

```{.r .cell-code}
# Great than or equal to/lesser than or equal to

1 >= 2
```

::: {.cell-output .cell-output-stdout}
```
[1] FALSE
```
:::

```{.r .cell-code}
1 <= 1
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::

```{.r .cell-code}
# Note - these have surpising results for characters (don't do this!)

"Dog" < "Moose"
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::

```{.r .cell-code}
"Whale" < "Fox"
```

::: {.cell-output .cell-output-stdout}
```
[1] FALSE
```
:::
:::


A very common logical operator I use to check if a string matches a set of values is the `%in%` operator:


::: {.cell layout-align="center"}

```{.r .cell-code}
"Dog" %in% c("Cat","Dog","Moose")
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::

```{.r .cell-code}
"Cow" %in% c("Cat","Dog","Moose")
```

::: {.cell-output .cell-output-stdout}
```
[1] FALSE
```
:::
:::


We can also modify and combine logical values using `!`, `&`, and `|` operators


::: {.cell layout-align="center"}

```{.r .cell-code}
# ! "flips" a logical value

(1 > 2)
```

::: {.cell-output .cell-output-stdout}
```
[1] FALSE
```
:::

```{.r .cell-code}
!(1 > 2)
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::

```{.r .cell-code}
# & means "AND" - both conditions have to be TRUE to return a TRUE

TRUE & FALSE
```

::: {.cell-output .cell-output-stdout}
```
[1] FALSE
```
:::

```{.r .cell-code}
TRUE & TRUE
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::

```{.r .cell-code}
(1 > 2) & (4 < 5)
```

::: {.cell-output .cell-output-stdout}
```
[1] FALSE
```
:::

```{.r .cell-code}
# `|` means "OR" - just one of the conditions have to be TRUE to return a true

TRUE | FALSE
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::

```{.r .cell-code}
TRUE | TRUE
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::

```{.r .cell-code}
(1 > 2) | (4 < 5)
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::
:::


Finally, there are many functions which will return a logical result. For instance, we can check the type of data we have.


::: {.cell layout-align="center"}

```{.r .cell-code}
is.numeric(1)
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::

```{.r .cell-code}
is.numeric("dog")
```

::: {.cell-output .cell-output-stdout}
```
[1] FALSE
```
:::

```{.r .cell-code}
is.character("dog")
```

::: {.cell-output .cell-output-stdout}
```
[1] TRUE
```
:::
:::


## Writing an IF statement

Often, we use logicals to make a decision about how to treat a value that we pass to R. We do this using a fundamental piece of programming called an "IF" statement. Here, we'll write a basic one. 


::: {.cell layout-align="center"}

```{.r .cell-code}
value <- 8

# Only do the stuff in the curly brackets IF the logical is true
if(value > 4){
  print("Value greater than 4")
}
```

::: {.cell-output .cell-output-stdout}
```
[1] "Value greater than 4"
```
:::

```{.r .cell-code}
value <- 2

if(value > 4){
  print("Value greater than 4")
}
```
:::


This is a great start! Often, we might want to do something else if the value didn't meet our condition. Here, we'll add in an else statement


::: {.cell layout-align="center"}

```{.r .cell-code}
value <- 8

if(value > 4){
  print("Value greater than 4")
}else{
  print("Value less than 4")
}
```

::: {.cell-output .cell-output-stdout}
```
[1] "Value greater than 4"
```
:::
:::


Fun! We can expand this more by adding additional else if statements



::: {.cell layout-align="center"}

```{.r .cell-code}
value <- 8

if(value > 10){
  print("Value greater than 10")
}else if(value > 4){
  print("Value between 4 and 10")
}else{
    print("Value less than 4")
}
```

::: {.cell-output .cell-output-stdout}
```
[1] "Value between 4 and 10"
```
:::
:::


## Applying logic to vectors.

Often, we want to use our logical operators to make decisions across many values, typically stored in a dataframe or a vector. All of R's logical operators are "vectorized", meaning that if you apply them to a vector, they'll return a vector of logical values. 


::: {.cell layout-align="center"}

```{.r .cell-code}
# A reminder of our data
data$Animal
```

::: {.cell-output .cell-output-stdout}
```
[1] "Dog"          "Cat"          "Cow"          "Goldfish"     "Turtle"      
[6] "Garter Snake" "Chicken"      "Pig"         
```
:::

```{.r .cell-code}
data$Weight_lb
```

::: {.cell-output .cell-output-stdout}
```
[1]   30.0   12.0 1400.0    0.2    1.0    3.0    7.0  400.0
```
:::

```{.r .cell-code}
data$Weight_lb > 4
```

::: {.cell-output .cell-output-stdout}
```
[1]  TRUE  TRUE  TRUE FALSE FALSE FALSE  TRUE  TRUE
```
:::

```{.r .cell-code}
data$Animal == "Cat"
```

::: {.cell-output .cell-output-stdout}
```
[1] FALSE  TRUE FALSE FALSE FALSE FALSE FALSE FALSE
```
:::

```{.r .cell-code}
# Remember, we can also "reverse" or combine logicals

!(data$Animal == "Cat")
```

::: {.cell-output .cell-output-stdout}
```
[1]  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
```
:::

```{.r .cell-code}
(data$Animal != "Cow") & (data$Weight_lb > 100) 
```

::: {.cell-output .cell-output-stdout}
```
[1] FALSE FALSE FALSE FALSE FALSE FALSE FALSE  TRUE
```
:::
:::


Often, we want to use logicals to return a value IF some condition is true. For example, maybe we want to classify animals as "small" if their weight is of a certain size. Let's first try to use an IF statement to accomplish this task. 


::: {.cell layout-align="center"}

```{.r .cell-code}
if(data$Weight_lb < 10){
  "small"
}else{
  "big"
}
```

::: {.cell-output .cell-output-error}
```
Error in if (data$Weight_lb < 10) {: the condition has length > 1
```
:::
:::


Hmm - this gives us an error. It tells us that "the condition has length > 1". If statements expect their condition (the value inside the parenthesis) to be just a single TRUE or FALSE. Because we passed it a vector, it cannot decide which choice to make. 

One option to fix this is to write a for loop (see tutorial from 20231107 if interested) to loop over the values of our vector and make each decision individually. Alternatively, R already has a function called `ifelse` to make decisions across a vector and return their corresponding values. Let's put it into action.


::: {.cell layout-align="center"}

```{.r .cell-code}
ifelse(data$Weight_lb < 10, # Condition to evaluate for each value in the vector
       "small", # Value to return if TRUE
       "big" # Value to return if FALSE
       )
```

::: {.cell-output .cell-output-stdout}
```
[1] "big"   "big"   "big"   "small" "small" "small" "small" "big"  
```
:::
:::


`ifelse` is particularly useful when combined with a function from the `tidyverse` called mutate, which allows us to add a new colum onto a dataframe!


::: {.cell layout-align="center"}

```{.r .cell-code}
mutate(
  data,  # Our data object
  size_class =  ifelse(Weight_lb < 10,
                      "small",
                      "big")
)
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 8 × 3
  Animal       Weight_lb size_class
  <chr>            <dbl> <chr>     
1 Dog               30   big       
2 Cat               12   big       
3 Cow             1400   big       
4 Goldfish           0.2 small     
5 Turtle             1   small     
6 Garter Snake       3   small     
7 Chicken            7   small     
8 Pig              400   big       
```
:::
:::


If we want to have more complicated decisions that would use "else if" statements, we can "nest" `ifelse` functions.


::: {.cell layout-align="center"}

```{.r .cell-code}
mutate(
  data,
  size_class =  ifelse(Weight_lb < 10,
                      "small",
                      ifelse(Weight_lb < 100,
                             "medium",
                             "big"))
)
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 8 × 3
  Animal       Weight_lb size_class
  <chr>            <dbl> <chr>     
1 Dog               30   medium    
2 Cat               12   medium    
3 Cow             1400   big       
4 Goldfish           0.2 small     
5 Turtle             1   small     
6 Garter Snake       3   small     
7 Chicken            7   small     
8 Pig              400   big       
```
:::
:::


As we add more conditions, it can get complicated to read the nested `ifelse` statements. In this case, the `case_when` function can be very handy


::: {.cell layout-align="center"}

```{.r .cell-code}
mutate(
  data,
  size_class =  case_when(Weight_lb < 10 ~ "small",
                          Weight_lb < 100 ~ "medium",
                          Weight_lb >= 100 ~ "big")
)
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 8 × 3
  Animal       Weight_lb size_class
  <chr>            <dbl> <chr>     
1 Dog               30   medium    
2 Cat               12   medium    
3 Cow             1400   big       
4 Goldfish           0.2 small     
5 Turtle             1   small     
6 Garter Snake       3   small     
7 Chicken            7   small     
8 Pig              400   big       
```
:::
:::


We can use mutate to add multiple columns, all with different logical operators.


::: {.cell layout-align="center"}

```{.r .cell-code}
mutate(
  data,
  size_class =  case_when(Weight_lb < 10 ~ "small",
                          Weight_lb < 100 ~ "medium",
                          Weight_lb >= 100 ~ "big"),
  
  is_livestock = ifelse(Animal %in% c("Cow","Chicken","Pig"),
                        "Livestock",
                        "Not Livestock")
)
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 8 × 4
  Animal       Weight_lb size_class is_livestock 
  <chr>            <dbl> <chr>      <chr>        
1 Dog               30   medium     Not Livestock
2 Cat               12   medium     Not Livestock
3 Cow             1400   big        Livestock    
4 Goldfish           0.2 small      Not Livestock
5 Turtle             1   small      Not Livestock
6 Garter Snake       3   small      Not Livestock
7 Chicken            7   small      Livestock    
8 Pig              400   big        Livestock    
```
:::
:::


We can also use logical operators in the `filter` command, to select rows that match a specific condition. Here, I also switch to a tidier notation using the pipe operator to chain commands together. 



::: {.cell layout-align="center"}

```{.r .cell-code}
data %>%
  mutate(
      size_class =  case_when(Weight_lb < 10 ~ "small",
                              Weight_lb < 100 ~ "medium",
                              Weight_lb >= 100 ~ "big"),
      
      is_livestock = ifelse(Animal %in% c("Cow","Chicken","Pig"),
                            "Livestock",
                            "Not Livestock")
  ) %>%
  filter(size_class == "small")
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 4 × 4
  Animal       Weight_lb size_class is_livestock 
  <chr>            <dbl> <chr>      <chr>        
1 Goldfish           0.2 small      Not Livestock
2 Turtle             1   small      Not Livestock
3 Garter Snake       3   small      Not Livestock
4 Chicken            7   small      Livestock    
```
:::
:::


We can filter on multiple conditions, by either separating logical conditions by commas (meaning AND between conditions) or using our logical operators. 


::: {.cell layout-align="center"}

```{.r .cell-code}
data %>%
  mutate(
      size_class =  case_when(Weight_lb < 10 ~ "small",
                              Weight_lb < 100 ~ "medium",
                              Weight_lb >= 100 ~ "big"),
      
      is_livestock = ifelse(Animal %in% c("Cow","Chicken","Pig"),
                            "Livestock",
                            "Not Livestock")
  ) %>%
  filter(size_class == "small",
         is_livestock == "Livestock")
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 1 × 4
  Animal  Weight_lb size_class is_livestock
  <chr>       <dbl> <chr>      <chr>       
1 Chicken         7 small      Livestock   
```
:::

```{.r .cell-code}
data %>%
  mutate(
      size_class =  case_when(Weight_lb < 10 ~ "small",
                              Weight_lb < 100 ~ "medium",
                              Weight_lb >= 100 ~ "big"),
      
      is_livestock = ifelse(Animal %in% c("Cow","Chicken","Pig"),
                            "Livestock",
                            "Not Livestock")
  ) %>%
  filter(size_class == "small" | is_livestock == "Livestock")
```

::: {.cell-output .cell-output-stdout}
```
# A tibble: 6 × 4
  Animal       Weight_lb size_class is_livestock 
  <chr>            <dbl> <chr>      <chr>        
1 Cow             1400   big        Livestock    
2 Goldfish           0.2 small      Not Livestock
3 Turtle             1   small      Not Livestock
4 Garter Snake       3   small      Not Livestock
5 Chicken            7   small      Livestock    
6 Pig              400   big        Livestock    
```
:::
:::


You can combine and apply logical operators in an endless number of ways and they are essential to data analysis. Enjoy!
