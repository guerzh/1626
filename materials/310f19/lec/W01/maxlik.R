library(ggplot2)

lik.plot <- function(probs, lik){
  df <- data.frame(probs = probs, lik = lik)
  ggplot(data = df) + 
    geom_line(mapping = aes(x = probs, y = lik)) + 
    geom_vline(xintercept = probs[which.max(lik)], color = "green") +
    annotate("text", x = probs[which.max(lik)], y = 0, label = probs[which.max(lik)])
}

set.seed(0)
r <- rbinom(n = 50, size = 1, prob = 0.9)
r
probs <- seq(0.001, 1, 0.01)
lik <- exp(log(probs)*sum(r) + log(1-probs)*(sum(1-r)))

lik.plot(probs, lik)
