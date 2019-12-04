import ballerina/docker;
import ballerina/http;
import ballerina/io;
import ballerina/log;

@docker:Config {
    name: "anuruddhal/geo-data",
    tag: "v1"
}
service geodata on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/cordinates/{ip}"
    }
    resource function geo(http:Caller caller, http:Request req, string ip) {
        json geoData = getGeoData(ip);
        log:printInfo(geoData.toString());
        io:println(caller.remoteAddress);
        var result = caller->respond(geoData);
        if (result is error) {
            log:printError("Error sending response", result);
        }
    }
}

function getGeoData(string ip) returns json {
    http:Client ipAPIEndpoint = new ("http://ip-api.com");
    var resp = ipAPIEndpoint->get("/json/" + ip);
    if (resp is http:Response) {
        var payload = resp.getJsonPayload();
        return <@untainted><json>payload;
    } else {
        io:println(resp.detail());
    }
}
