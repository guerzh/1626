library(ggplot2)


lik.plot <- function(probs, lik){
  df <- data.frame(probs = probs, lik = lik)
  ggplot(data = df) + 
    geom_line(mapping = aes(x = probs, y = lik)) + 
    geom_vline(xintercept = probs[which.max(lik)], color = "green") +
    annotate("text", x = probs[which.max(lik)], y = 0, label = probs[which.max(lik)])
}

posterior <- function(r, prob, prior){
  lik <- exp(log(probs)*sum(r) + log(1-probs)*(sum(1-r)))
  post <- lik * prior
  post/sum(post)
}

set.seed(0)
probs <- seq(0.001, 1, 0.002)

r <- rbinom(n = 50, size = 1, prob = 0.99)
prior <- dnorm(x = probs, mean = 0.5, sd = 0.05) + 0.00000001
prior <- prior/sum(prior)

lik.plot(probs, prior)
lik.plot(probs, posterior(r, probs, prior))


r <- rbinom(n = 50, size = 1, prob = 0.7)
prior <- dnorm(x = probs, mean = 0.5, sd = 0.12)
prior <- prior/sum(prior)
probs <- seq(0.001, 1, 0.002)
lik.plot(probs, prior)
lik.plot(probs, posterior(r, probs, prior))



prior <- dnorm(x = probs, mean = 0.5, sd = 0.2)
prior <- prior/sum(prior)
probs <- seq(0.001, 1, 0.002)
lik.plot(probs, prior)
lik.plot(probs, posterior(r, probs, prior))

prior <- dnorm(x = probs, mean = 0.5, sd = 0.3)
prior <- prior/sum(prior)
probs <- seq(0.001, 1, 0.002)
lik.plot(probs, prior)
lik.plot(probs, posterior(r, probs, prior))

prior <- dnorm(x = probs, mean = 0.5, sd = 0.01)
prior <- prior/sum(prior)
probs <- seq(0.001, 1, 0.002)
lik.plot(probs, prior)
lik.plot(probs, posterior(r, probs, prior))

