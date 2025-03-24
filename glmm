data <- data.frame(
  Neuron = rep(1:13, times = 4),  
  Session = rep(1:4, each = 13),   
  Latency = c( 29.4486, 18.9356, 16.0869, 23.3789, 22.1325, 13.5192, 13.8208, 35.3588, 19.0793, 14.0878, 12.8069,
               10.2829, 13.3652,
               28.6911, 17.0816, 13.1385, 19.6248, 21.0408, 10.5992, 11.6629, 28.2795, 16.8658, 13.3079, 11.4382,
               9.0819, 10.104,
               23.5938, 16.0425, 10.3799, 15.9373, 18.9769, 8.61344, 9.84631, 27.7863, 14.7947, 11.4037, 9.9863,
               8.9882, 9.3819,
               20.5928, 12.6798, 9.52861, 9.38143, 14.9798, 7.65758, 9.32226, 18.7677, 14.6018, 9.6645, 7.6151,
               7.8844, 7.9953),  
  No = c(  9, 67, 66, 54, 94, 231, 164, 39, 57, 28, 46, 102, 96,
           21, 89, 74, 67, 86, 210, 168, 59, 70, 35, 71, 127, 159,
           63, 102, 76, 60, 105, 183, 172, 51, 80, 71, 91, 132, 174,
           84, 104, 95, 74, 141, 181, 185, 87, 100, 84, 136, 154, 194)  # 'No' 数据

)

data$Latency <- log(data$Latency)
library(lme4)
model <- lmer(Latency ~ Session + (Session | Neuron), data = data)
summary(model)

model_N <- glmer(No ~ Session + (Session | Neuron), data = data , family = poisson)
summary(model_N)

power_analysis <- powerSim(model, nsim=1000) 
summary(power_analysis)

power_analysis <- powerSim(model_N, nsim=1000) 
summary(power_analysis)

data <- data.frame(
  interval_index = rep(1:10, times = 13),
  neuron_id = rep(1:13, each = 10),  
  increment = c(
    -22.52, -4.94, 4.39, 3.37, 4.06, 2.8, 2.2, 2.51, 2.98, 5.15,
    -21.35, -4.51, 2.05, 2.79, 3.39, 3.93, 3.4, 2.16, 2.21, 5.93,
    -31.74, 0.59, 2.16, 3, 2.7, 3.91, 4.79, 3.7, 3.81, 7.06,
    -2.35, -18.59, 1.62, 1.18, 2.49, 0.65, 1.96, 3.12, 3.67, 6.24,
    -4.52, -21.67, 5.91, 2.95, 2.54, 2.2, 2.47, 2.52, 0.88, 6.72,
    -0.82, -3.48, -4.59, -3.62, 1.82, 1.27, -0.13, -2.08, 2.8, 8.82,
    -3.26, -5.2, -4.08, -5.57, -0.82, -0.91, 0.29, 0.66, 3.66, 15.22,
    -36.77, 1.01, 8.08, 6.34, 3.92, 3.51, 2.93, 1.82, 2.88, 6.28,
    -9.03, -2.54, -0.65, 1.6, 2.09, 1.8, 1.33, 0.77, 0.96, 3.66,
    -28.15, -5.28, 6.06, 2.6, 3.31, 2.58, 3.06, 2.9, 2.87, 10.04,
    -24.28, -26.94, -8.65, -0.01, 4.4, 7.89, 6.24, 6.73, 9.73, 24.88,
    -0.32, -7.28, -9.42, 1.3, -3.78, -2.01, 0.47, 4.92, 3.93, 12.19,
    -23.49, -10.35, -3.63, -3.71, -1.51, 1.07, 2.35, 5.76, 8.34, 25.17
  )
)
data$increment<- atan(data$increment)
model_i <- lmer(increment ~ interval_index + (interval_index | neuron_id), data = data)
summary(model_i)

library(ggplot2)
residuals <- resid(model)
dev.new()
qqnorm(residuals)
qqline(residuals)
shapiro.test(residuals)  

library(ggplot2)
residuals <- resid(model_N)
dev.new()
qqnorm(residuals)
qqline(residuals)
shapiro.test(residuals)  

library(ggplot2)
residuals <- resid(model_i)
dev.new()
qqnorm(residuals)
qqline(residuals)
shapiro.test(residuals)  
