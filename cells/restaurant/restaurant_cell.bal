import ballerina/config;
import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {
    cellery:Component restaurantComp = {
        name: "restaurant",
        src: {
            image: "anuruddhal/restaurant"
        },
        ingresses: {
            restaurantAPI: <cellery:HttpApiIngress>{
                context: "details",
                port: 9090,
                expose: "local"
            }
        },
        envVars: {
            USER_KEY: {value: ""}
        }
    };

    cellery:CellImage restaurantCell = {
        components: {
            restaurentComp: restaurantComp
        }
    };
    return <@untainted>cellery:createImage(restaurantCell, iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies) returns (cellery:InstanceState[] | error?) {
    cellery:CellImage restaurantCell = check cellery:constructCellImage(iName);
    string userKey = config:getAsString("USER_KEY");
    if (userKey.length() == 0) {
        panic error("USER_KEY is not set.");
    }
    restaurantCell.components["restaurentComp"]["envVars"]["USER_KEY"].value = config:getAsString("USER_KEY");
    return cellery:createInstance(restaurantCell, iName, instances, startDependencies, shareDependencies);
}
