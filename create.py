import math
import simplekml

# Tommy Trojan coordinates
kml = simplekml.Kml()
Tommyt_x = -118.28563
Tommyt_y = 34.02051

# Spirograph parameters
R = 90
r = 36
a = 44
nRev = 5

# Constants
cos = math.cos
sin = math.sin
pi = math.pi

# Generate Spirograph curve points
t = 0.0
while t < nRev * 2 * pi:
    x = (R + r) * cos((r / R) * t) - a * cos((1 + r / R) * t)
    y = (R + r) * sin((r / R) * t) - a * sin((1 + r / R) * t)
    kml.newpoint(coords=[(Tommyt_x + (x / 100000), Tommyt_y + (y / 100000))])
    t += 0.01

# Save KML file
kml.save('Spirograph.kml')
print("KML file generated successfully!")
