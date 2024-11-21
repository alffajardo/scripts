#!/usr/bin/Rscript

# Function to convert Centiloid (CL) to SUVR
cl2suvr <- function(CL_value = NULL, intercept = 1.031, slope = 1.172) {
  
  if (is.null(CL_value)) {
    stop("Please provide a Centiloid value")
  }
  
  SUVR <- intercept + ((CL_value * slope) / 100)
  
  return(SUVR)
}

# Function to convert SUVR to Centiloid (CL)
suvr2cl <- function(suvr_value = NULL, intercept = 1.031, slope = 1.172) {
  
  if (is.null(suvr_value)) {
    stop("Please provide an SUVR value")
  }
  
  CL <- 100 * ((suvr_value - intercept) / slope)
  
  return(CL)
}

# Function to convert Gray Matter SUVR to Centiloid (CL)
gmsuvr2CL <- function(suvr_value = NULL) {
  
  if (is.null(suvr_value)) {
    stop("Please provide a Gray Matter SUVR value")
  }
  
  # Adjusted formula with the updated intercept and slope
  suvr_corr <- -0.0246 + (suvr_value * 0.796)
  CL <- suvr2cl(suvr_corr)
  
  return(CL)
}

# Function to convert Centiloid (CL) to Gray Matter SUVR
CL2gmsuvr <- function(cl_value = NULL) {
  
  if (is.null(cl_value)) {
    stop("Please provide a Centiloid (CL) value")
  }
  
  # Convert CL to corrected SUVR using cl2suvr
  suvr_corr <- cl2suvr(cl_value)
  
  # Apply the inverse correction formula with the updated intercept and slope
  suvr_value <- (suvr_corr + 0.0246) / 0.796
  
  return(suvr_value)
}

## In the Villeneuve lab, we use gray matter cerebellum as a reference
## region. Ever wondered the equivalent in Prevent AD SUVRs to WC CLs?
# This function promises to solve the inquiry.

