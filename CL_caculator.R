# functions to transform 

cl2suvr <- function (CL_value = NULL,intercept = 1.031, slope = 1.172){
  
  if (is.null(CL_value)){
    
    stop("Please provide a Centiloid value")
    
  
  }
  
  
  SUVR <- intercept + ((CL_value*slope)/100)
  
  return(SUVR)
}





suvr2cl <- function (suvr_value = NULL,intercept = 1.031, slope = 1.172){
  
  if (is.null(suvr_value)){
    
    stop("Please provide an SUVR value")
    
    
  }
  
  
  CL <- 100*((suvr_value - intercept) / slope)
  
  return(CL)
}


## In the Villenueve lab we use gray matter cerebellum as a reference
## region. Ever wondered the equivalent in Prevent AD SUVrs to WC CLs?
# This function promises to solve the inquiry.

