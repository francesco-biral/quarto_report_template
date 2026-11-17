"""Standalone version of the damped-response example used in the report."""

import numpy as np
import matplotlib.pyplot as plt

m, c, k, x0 = 1.0, 0.8, 20.0, 0.10
omega_n = np.sqrt(k / m)
zeta = c / (2 * np.sqrt(k * m))
omega_d = omega_n * np.sqrt(1 - zeta**2)

t = np.linspace(0, 8, 800)
envelope = x0 * np.exp(-zeta * omega_n * t)
x = envelope * (
    np.cos(omega_d * t)
    + (zeta * omega_n / omega_d) * np.sin(omega_d * t)
)

fig, ax = plt.subplots()
ax.plot(t, x, color="#004d80", label="Displacement")
ax.plot(t, envelope, "--", color="#d07a02", label="Envelope")
ax.plot(t, -envelope, "--", color="#d07a02")
ax.set(xlabel="Time (s)", ylabel="Displacement (m)")
ax.legend(frameon=False)
plt.show()
