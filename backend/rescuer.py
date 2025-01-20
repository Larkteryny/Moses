import math
from request import Request

class Rescuer():
    def __init__(self,latitude,longitude,capacity):
        self.latitude: float = latitude
        self.longitude: float = longitude
        self.capacity: float = capacity

    # Returns distance from longitude and latitude coords of 2 points
    def dist(self, request: Request):
        distance = math.acos(math.sin(self.latitude) * math.sin(request.latitude) +
                             math.cos(self.latitude) * math.cos(request.latitude) * math.cos(request.longitude - self.longitude)) * 6371
        return distance

    def reduce_capacity(self, amount):
        self.capacity = max(self.capacity - amount, 0)

    def __str__(self):
        return f"{self.latitude}({self.longitude})"

