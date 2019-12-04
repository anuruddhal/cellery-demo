import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {
    cellery:Component geoComponent = {
        name: "geo",
        src: {
            image: "anuruddhal/geo-data:v1"
        },
        ingresses: {
            geoAPI: <cellery:HttpApiIngress>{
                context: "geo",
                expose: "local",
                port: 9090
            }
        }
    };

    cellery:CellImage geoCell = {
        components: {
            geoComp: geoComponent
        }
    };

    return <@untainted>cellery:createImage(geoCell, iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies) returns (cellery:InstanceState[] | error?) {
    cellery:CellImage geoCell = check cellery:constructCellImage(iName);
    return <@untatinted>cellery:createInstance(geoCell, iName, instances, startDependencies, shareDependencies);

}

