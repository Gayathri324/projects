# Load the dataset
tetuan_city_power <- read.csv("Tetuan City power consumption.csv") 

# Select variables of temperature and three power consumption zones
new_data <- tetuan_city_power[c(2, 7:9)] 

# Select unique a dataset with unique values
tetaun_data <- unique(new_data)
View(tetaun_data)


set.seed(1000)

# Select training dataset with 250 observations
new_power <-tetaun_data[sample(nrow(tetaun_data), 250), ]
View(new_power)

# Integrate three power consumption values and stored in as a new variable
new_power$Power_Consumption <- new_power$Zone.1.Power.Consumption + 
  new_power$Zone.2..Power.Consumption + new_power$Zone.3..Power.Consumption

# Select temperature variable and integrated power consumption variable
power_data <- new_power[c(1, 5)]
View(power_data)
dim(power_data)

# Calculate the mean of integrated power consumption values
mean_power_consumption <- mean(power_data$Power_Consumption)
mean_power_consumption

# Print 1 if mean > power consumption value and 0 if mean < power consumption value 
# Stored 1 and 0 as Y variable
power_data$Y <- ifelse(power_data$Power_Consumption > mean_power_consumption, 1, 0)
View(power_data)

# Select temperature variable and Y variable
power_data_tetaun_city <- power_data[c(1, 3)]
View(power_data_tetaun_city)


################## Random Walk Metropolis Algorithm #######################
set.seed(122)

# Define the formula
formula <- Y ~ Temperature

# Initial values for the coefficients
initial_coefficients <- c(0, 0)

# Number of iterations for the Random Walk Metropolis algorithm
num_iterations <- 10000

# Proposal distribution standard deviation
proposal_sd <- c(0.1, 0.1)

# Storage for sampled coefficients
coefficients_samples <- matrix(0, num_iterations, length(initial_coefficients))

# Initialize the coefficients
coefficients_samples[1, ] <- initial_coefficients



for (i in 2:num_iterations) {
  # Propose new coefficients using rnorm
  proposed_coefficients <- rnorm(length(initial_coefficients), mean = coefficients_samples[i - 1, ], sd = proposal_sd)
  beta1 <- proposed_coefficients[1]
  beta2 <- proposed_coefficients[2]
  
  # Calculate likelihood for proposed coefficients
  linear_predictors_proposed <- beta1 + beta2 * power_data_tetaun_city$Temperature
  likelihood_proposed <- sum(linear_predictors_proposed^power_data_tetaun_city$Y*(1 - linear_predictors_proposed)^(1 - power_data_tetaun_city$Y)) 
  
  
  linear_predictors_current <- coefficients_samples[i-1, 1] + (coefficients_samples[i-1, 2]*power_data_tetaun_city$Temperature)
  likelihood_current <- sum(linear_predictors_current^power_data_tetaun_city$Y*(1 - linear_predictors_current)^(1 - power_data_tetaun_city$Y)) 
  
  # Calculate log prior for proposed and current coefficients
  prior_proposed <- sum(dnorm(proposed_coefficients, mean = 0, sd = 1, log = FALSE))
  prior_current <- sum(dnorm(coefficients_samples[i - 1, ], mean = 0, sd = 1, log = FALSE))
  
  # Calculate acceptance probability
  acc_prob <- (likelihood_proposed * prior_proposed) / (likelihood_current * prior_current)
  
  
  # Accept or reject the proposed coefficients
  if (runif(1) < acc_prob) {
    coefficients_samples[i, ] <- proposed_coefficients
  } else {
    coefficients_samples[i, ] <- coefficients_samples[i - 1, ]
  }
}

# Display the summary of coefficient samples
summary(coefficients_samples)

## Formulate the probability for Y to be 1 at a given temperature ####

new_data_Y_1 <- power_data_tetaun_city[power_data_tetaun_city$Y==1, ]
new_data_Y_1

summary(new_data_Y_1)

beta_0 <- mean(coefficients_samples[,1])
beta_1 <- mean(coefficients_samples[,2])


# Calculate pr(Y=1|Temperature) for each temperature value
temperature <- new_data_Y_1$Temperature
pr_Y_1 <- 1/(1 + exp(-(beta_0+beta_1*temperature)))

# Plot mean pr(Y=1|Temperature) against Temperature
plot(temperature,pr_Y_1, xlab = "Temperature", ylab = "pr(Y=1|Temperature)", main = "Probability of Y=1 vs. Temperature", pch = 20, col = "purple")


# Plot trace plots for the coefficients
par(mfrow=c(3,2))
plot(coefficients_samples[, 1], type="l", xlab="Iteration", ylab="Beta0", main="Trace Plot - Beta0")
abline(h = mean(coefficients_samples[, 1]), col = "red")

plot(coefficients_samples[, 2], type="l", xlab="Iteration", ylab="Beta1", main="Trace Plot - Beta1")
abline(h = mean(coefficients_samples[, 2]), col = "red")

# Plot density plots for the coefficients


plot(density(coefficients_samples[, 1]), type="l", xlab="Beta0", ylab="Density", main="Posterior Distribution - Beta0")
abline(v = mean(coefficients_samples[, 1]), col = "red")
#legend("topright", legend = c("Mean"),
       #col = c("red"), lwd =  1)


plot(density(coefficients_samples[, 2]), type="l", xlab="Beta1", ylab="Density", main="Posterior Distribution - Beta1")
abline(v = mean(coefficients_samples[, 2]), col = "red") 
#legend("topright", legend = c("Mean"),
       #col = c("red"), lwd =  1)


# Plot histograms plots for the coefficients

hist(coefficients_samples[, 1], main = "Histogram of Beta0 Posterior", xlab = "Beta0")
abline(v = mean(coefficients_samples[, 1]), col = "red")  

# Plot histogram of posterior samples for Beta1
hist(coefficients_samples[, 2], main = "Histogram of Beta1 Posterior", xlab = "Beta1")
abline(v = mean(coefficients_samples[, 2]), col = "red")  



################## Random Walk Metropolis Algorithm #######################

set.seed(100)

# Define the formula
formula <- Y ~ Temperature

# Initial values for the coefficients
initial_coefficients <- c(0, 0)

# Number of iterations for the Random Walk Metropolis algorithm
num_iterations <- 10000

# Proposal distribution standard deviation
proposal_sd <- c(0.1, 0.1)

# Store the sample coefficients
coeff_samples <- matrix(0, num_iterations, length(initial_coefficients))

# Initial values for the coefficients
initial_coeff <- c(0, 0)

# Initialize the coefficients
coeff_samples[1, ] <- initial_coeff

for (i in 2:num_iterations) {
  # Propose new coefficients using rnorm
  proposed_coeff <- rnorm(length(initial_coeff), mean = coeff_samples[i - 1, ], sd = proposal_sd)
  
  # Calculate log likelihood for proposed coefficients
  linear_predict_proposed <- proposed_coeff[1] + (proposed_coeff[2] * power_data_tetaun_city$Temperature)
  log_likelihood_proposed <- sum(power_data_tetaun_city$Y * linear_predict_proposed - log(1 + exp(linear_predict_proposed)))
  
  linear_predict_current <- coeff_samples[i-1, 1] + (coeff_samples[i-1, 2]*power_data_tetaun_city$Temperature)
  log_likelihood_current <- sum(power_data_tetaun_city$Y * linear_predict_current - log(1 + exp(linear_predict_current)))
  
  # Calculate log prior for proposed and current coefficients
  log_prior_proposed <- sum(dnorm(proposed_coeff, mean = 0, sd =1 , log = TRUE))
  log_prior_current <- sum(dnorm(coeff_samples[i - 1, ], mean = 0, sd =1, log = TRUE))
  
  # Calculate acceptance probability
  acceptance_prob <- exp(log_likelihood_proposed + log_prior_proposed - log_likelihood_current - log_prior_current)
  
  
  # Accept or reject the proposed coefficients
  if (runif(1) < acceptance_prob) {
    coeff_samples[i, ] <- proposed_coeff
  } else {
    coeff_samples[i, ] <- coeff_samples[i - 1, ]
  }
  
}

# Display the summary of coefficient samples
summary(coeff_samples)


# Plot trace plots for the coefficients
par(mfrow=c(3,2))
plot(coeff_samples[, 1], type="l", xlab="Iteration", ylab="Beta0", main="Trace Plot - Beta0")
abline(h = mean(coeff_samples[, 1]), col = "red")

plot(coeff_samples[, 2], type="l", xlab="Iteration", ylab="Beta1", main="Trace Plot - Beta1")
abline(h = mean(coeff_samples[, 2]), col = "red")

# Plot density plots for the coefficients

plot(density(coeff_samples[, 1]), type="l", xlab="Beta0", ylab="Density", main="Posterior Distribution - Beta0")
abline(v = mean(coeff_samples[, 1]), col = "red")


plot(density(coeff_samples[, 2]), type="l", xlab="Beta1", ylab="Density", main="Posterior Distribution - Beta1")
abline(v = mean(coeff_samples[, 2]), col = "red") 


# Plot histograms plots for the coefficients

hist(coeff_samples[, 1], main = "Histogram of Beta0 Posterior", xlab = "Beta0")
abline(v = mean(coeff_samples[, 1]), col = "red") 



# Plot histogram of posterior samples for Beta1
hist(coeff_samples[, 2], main = "Histogram of Beta1 Posterior", xlab = "Beta1")
abline(v = mean(coeff_samples[, 2]), col = "red")  


## Formulate the probability for Y to be 1 at a given temperature ####

# Select Y=1 observations
new_data_Y_1 <- power_data_tetaun_city[power_data_tetaun_city$Y==1, ]
new_data_Y_1

summary(new_data_Y_1)

# Calculate the mean of beta_0 and beta_1 coeffients
beta_0 <- mean(coeff_samples[,1])
beta_1 <- mean(coeff_samples[,2])


# Calculate pr(Y=1|Temperature) for each temperature value
temperature <- new_data_Y_1$Temperature
pr_Y_1 <- 1/(1 + exp(-(beta_0+beta_1*temperature)))

# Plot mean pr(Y=1|Temperature) against Temperature
plot(temperature,pr_Y_1, xlab = "Temperature", ylab = "pr(Y=1|Temperature)", main = "Probability of Y=1 vs. Temperature", pch = 20, col = "purple")

############## Predict Probability ############################

# Suggest Temperature values

temperature_values <- c(1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95)

# Calculate prediction probability
Prediction_probability <- 1/(1 + exp(-(beta_0+beta_1*temperature_values)))

# Y values based on predicted probabilities
Y <- rbinom(length(temperature_values), size = 1, prob = Prediction_probability)

#Store the results
prediction_values <- data.frame(Temperature = temperature_values, Probability = Prediction_probability, Y = Y )

print(prediction_values)
