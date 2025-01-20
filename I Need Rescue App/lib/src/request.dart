import "package:supabase_flutter/supabase_flutter.dart";

Future<bool> sendRequest(id, peopleCount, injuryCount, dangerLevel, location, update) async {
  try {
    if(update) {
      await Supabase.instance.client.from("help").update(
          {
            "id": id,
            "peopleCount": peopleCount,
            "injuryCount": injuryCount,
            "dangerLevel": dangerLevel,
            "location": location,
          }
      ).eq("id", id);
    } else {
      await Supabase.instance.client.from("help").insert(
          {
            "id": id,
            "peopleCount": peopleCount,
            "injuryCount": injuryCount,
            "dangerLevel": dangerLevel,
            "location": location,
          }
      );
    }

    return true;
  } catch(identifier, st) {
    print(identifier);
    print(st);
    return Future.error("Could not access Internet", st);
  }
}