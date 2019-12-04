import ballerina/config;
import ballerina/docker;
import ballerina/http;
import ballerina/io;
import ballerina/log;

@docker:Config {
    name: "anuruddhal/restaurant"
}
service restaurant on new http:Listener(9090) {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/details/{lat}/{lon}"
    }
    resource function getRestaurantData(http:Caller caller, http:Request req, string lat, string lon) {
        json restaurantData = getLocationDetails(lat, lon);
        io:println(caller.remoteAddress);
        var result = caller->respond(restaurantData);
        if (result is error) {
            log:printError("Error sending response", result);
        }
    }
}

function getLocationDetails(string lat, string lon) returns json {
    string userKey = config:getAsString("USER_KEY");
    if (userKey.length() == 0) {
        json errRes = {"error": "USER_KEY is not found in the environment"};
        return errRes;
    }
    http:Request req = new;
    req.addHeader("user-key", userKey);
    req.addHeader("Accept", "application/json");
    io:println("Lat:" + lat + " " + "lon: " + lon);
    http:Client zomatoEp = new ("https://developers.zomato.com");
    var resp = zomatoEp->get("/api/v2.1/geocode?lat=" + lat + "&lon=" + lon, req);
    if (resp is http:Response) {
        var payload = resp.getJsonPayload();
        return <@untainted><json>payload;
    } else {
        io:println(resp.detail());
    }
}
