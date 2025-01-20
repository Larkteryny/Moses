# Libraries imported to be used
from supabase import create_client, Client
from rescuer import Rescuer
from request import Request

def calc_importance(number_of_people, people_with_injuries, danger_level):
    importance = (number_of_people ** 0.5) * danger_level
    if people_with_injuries > 0:
        importance *= people_with_injuries ** 0.5
    return importance

def assign_rescues(requests, responders):
    available_responders = [i for i in range(len(responders))]
    instructions = [[] for _ in range(len(responders))]

    while len(available_responders) and any(req.number_of_people != 0 for req in requests):
        for i in available_responders[::-1]:
            responder = responders[i]
            if not any(req.number_of_people != 0 for req in requests):
                # All requests fulfilled, return
                return instructions

            # Find "most worth it" request
            mwi_worth = 0
            mwi_i = 0
            for j, req in enumerate(requests):
                worth = req.importance / responder.dist(req)
                if worth > mwi_worth:
                    mwi_worth = worth
                    mwi_i = j

            instructions[i].append(mwi_i)
            temp_number_of_people = requests[mwi_i].number_of_people
            requests[mwi_i].injury_number = max(requests[mwi_i].injury_number - responder.capacity, 0)
            requests[mwi_i].number_of_people = max(requests[mwi_i].number_of_people - responder.capacity, 0)
            requests[mwi_i].recalc_importance()
            responder.reduce_capacity(temp_number_of_people)

            if responder.capacity == 0:  # Responder can no longer help anymore requests
                available_responders.remove(i)

    return instructions

if __name__=="__main__":
    # Initializing supabase
    supabase: Client = create_client("https://xqoogfxwothtjpskdbdc.supabase.co", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhxb29nZnh3b3RodGpwc2tkYmRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcyMjc3MDQsImV4cCI6MjA1MjgwMzcwNH0.YQj8wT2rbTkesNJbSfv41zBK-AuUU64Ccs5CdKt-CQc")
    response = supabase.table("help").select("*").execute()

    # Making objects for each request with specific details
    requests = []
    for x in range(len(response.data)):
        danger_level = int(response.data[x]['dangerLevel'])
        number_of_people = int(response.data[x]['peopleCount'])
        people_with_injuries = int(response.data[x]['injuryCount'])
        location = response.data[x]['location']
        latitude = float(location['latitude'])
        longitude = float(location['longitude'])

        # algorithm for which call is important/urgent
        importance = calc_importance(number_of_people, people_with_injuries, danger_level)
        citizen_request = Request(number_of_people, danger_level, people_with_injuries, latitude, longitude, importance)

        #storing those objects in an array
        requests.append(citizen_request)

    # Stations for latitude/longitude
    coordinates = [
        (43.6426, -79.3871, 10),
        (43.6600, -79.4001, 20),
        #(43.6640, -79.3986, 10),
        #(43.6629, -79.3968, 20),
        #(43.6625, -79.3953, 10),
        #(43.6634, -79.3947, 20),
        #(43.6630, -79.4111, 10),
        #(43.6643, -79.3997, 20),
        #(43.6626, -79.3949, 10),
        #(43.6532, -79.3832, 30)
    ]

    responders = []

    # making objects of responders/rescuers
    for coordinate in coordinates:
        responder_latitude = coordinate[0]
        responder_longitude = coordinate[1]
        responder_capacity = coordinate[2]
        responder_details = Rescuer(responder_latitude,responder_longitude,responder_capacity)
        responders.append(responder_details)

    # Run assignment algorithm
    instructions = assign_rescues(requests, responders)

    # Convert instructions into geolocations
    loc_instructions = [[(requests[x].latitude, requests[x].longitude) for x in instruction]
                        for instruction in instructions]
    # Output instructions
    print(*loc_instructions, sep='\n')
