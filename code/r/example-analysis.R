# Minimal R-first equivalent of the report's damped-response calculation.

m <- 1.0
c <- 0.8
k <- 20.0
x0 <- 0.10

omega_n <- sqrt(k / m)
zeta <- c / (2 * sqrt(k * m))
omega_d <- omega_n * sqrt(1 - zeta^2)

t <- seq(0, 8, length.out = 800)
envelope <- x0 * exp(-zeta * omega_n * t)
x <- envelope * (
  cos(omega_d * t) +
    (zeta * omega_n / omega_d) * sin(omega_d * t)
)

plot(t, x, type = "l", col = "#004d80", lwd = 2,
     xlab = "Time (s)", ylab = "Displacement (m)")
lines(t, envelope, col = "#d07a02", lty = 2)
lines(t, -envelope, col = "#d07a02", lty = 2)
