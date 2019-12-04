import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {
    cellery:Component suggestionComp = {
        name: "sugesstion",
        src: {
            image: "anuruddhal/aggergator"

        },
        ingresses: {
            sugesstionAPI: <cellery:HttpApiIngress>{
                port: 9090,
                context: "suggest",
                expose: "global",
                definition: {
                    resources: [{
                        method: "POST",
                        path: "/"
                    }
                    ]
                }
            }
        },
        envVars: {
            GEO_URL: {value: ""},
            RESTAURANT_URL: {value: ""}
        },
        dependencies: {
            cells: {
                geoCell: {org: "myorg", name: "geo-cell", ver: "v1"},
                restaurantCell: {org: "myorg", name: "restaurant-cell", ver: "v1"}
            }
        }
    };
    suggestionComp["envVars"]["GEO_URL"].value= <string>cellery:getReference(suggestionComp,"geoCell").get("geo_geoapi_api_url");
    suggestionComp["envVars"]["RESTAURANT_URL"].value= 
    <string>cellery:getReference(suggestionComp,"restaurantCell").get("restaurant_restaurantapi_api_url");
    cellery:CellImage suggestionCell = {
        components: {
            sugesstion: suggestionComp
        }
    };
    return <@untainted>cellery:createImage(suggestionCell, iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies) returns (cellery:InstanceState[]|error?) {
    cellery:CellImage|cellery:Composite suggestionCell = check cellery:constructCellImage(iName);
    return <@untainted> cellery:createInstance(suggestionCell, iName,instances, startDependencies, shareDependencies);
}