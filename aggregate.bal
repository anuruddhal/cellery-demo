import ballerina/config;
import ballerina/docker;
import ballerina/http;
import ballerina/io;
import ballerina/log;

@docker:Config {
    name: "anuruddhal/aggergator"
}
service suggest on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/restaurant"
    }
    resource function getRestaurants(http:Caller caller, http:Request req) {
        string ip = <string>req.getTextPayload();
        io:println(ip);
        json geoData = getSuggesstions(<@untainted >ip);
        log:printInfo(geoData.toString());
        io:println(caller.remoteAddress);
        var result = caller->respond(geoData);
        if (result is error) {
            log:printError("Error sending response", result);
        }
    }
}

function getSuggesstions(string ip) returns json {
    json geoData = getGeoData(ip);
    string lat = <string>geoData.lat.toString();
    string lon = <string>geoData.lon.toString();
    log:printInfo("Latitude:" + lat + " Longtitude:" + lon);
    json restaurantData = getRestaurantData(lat, lon);
    json[] nearBy = <json[]>restaurantData.nearby_restaurants;
    int l = nearBy.length();
    io:println("length of the array: ", l);
    json[] result = [];
    int i = 0;
    while (i < l) {
        json restaurentInfo = {
            "name": <json>nearBy[i].restaurant.name,
            "address": <json>nearBy[i].restaurant.location.address,
            "rating": <json>nearBy[i].restaurant.user_rating.rating_text,
            "average_cost_for_two": <json>(nearBy[i].restaurant.average_cost_for_two.toString()
            + nearBy[i].restaurant.currency.toString())
        };
        result[i] = restaurentInfo;
        i = i + 1;
    }
    json finalGeoData = {
        "location": <json>(geoData.city.toString() + " " + geoData.country.toString()),
        "restaurents": result
    };
    return finalGeoData;
}

function getGeoData(string ip) returns json {
    string geoURL = config:getAsString("GEO_URL");
    log:printInfo("GEO_URL: " + geoURL);
    http:Client ipAPIEndpoint = new (geoURL);
    var resp = ipAPIEndpoint->get("/geodata/cordinates/" + ip);
    if (resp is http:Response) {
        var payload = resp.getJsonPayload();
        if (payload is json) {
            return <@untainted><json>payload;
        } else {
            io:println(payload);
        }
    } else {
        log:printError("Error while getting geo data: ");
        io:println(resp.detail());
    }
}

function getRestaurantData(string lat, string lon) returns json {
    string detailsURL = config:getAsString("RESTAURANT_URL");
    log:printInfo("RESTAURANT_URL: " + detailsURL);
    http:Client ipAPIEndpoint = new (detailsURL);
    var resp = ipAPIEndpoint->get("/restaurant/details/" + lat + "/" + lon);
    if (resp is http:Response) {
        var payload = resp.getJsonPayload();
        if (payload is json) {
            return <@untainted><json>payload;
        } else {
            log:printError("Invalid restaurant data: ");
            io:println(payload);
        }
    } else {
        log:printError("Error while getting restaurant data: ");
        io:print(resp.detail());
    }
}
