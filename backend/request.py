class Request(object):
    def __init__(self,number_of_people,danger_level, injury_number, latitude, longitude, importance):
        self.number_of_people = number_of_people
        self.danger_level = danger_level
        self.injury_number = injury_number
        self.latitude = latitude
        self.longitude = longitude
        self.importance = importance

    def recalc_importance(self):
        self.importance = (self.number_of_people ** 0.5) * self.danger_level
        if self.injury_number > 0:
            self.importance *= self.injury_number ** 0.5

    def __str__(self):
        return f"{self.latitude}({self.longitude})"