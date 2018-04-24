import ballerina/http;
import ballerina/io;

endpoint http:Listener listener {
    port:9090
};

@http:ServiceConfig {
    basePath:"/time"
}
service<http:Service> timeInfo bind listener {

    @http:ResourceConfig {
        methods:["GET"],
        path:"/"
    }
    getTime (endpoint caller, http:Request req) {

        // Client endpoints represent remote network location.
        // This endpoint is reachable within code.
        endpoint http:SimpleClient timeServiceEP {
            url:"http://localhost:9095"
        };

        // Invoke 'get' resource at timeServiceEP endpoint.
        // -> indicates request is sent over the network.
        // 'check' assigns response or if there is an error
        //  then generates a function error.
        http:Response response = check
                     timeServiceEP -> get("/localtime", new);

        // json and xml are primitive data types!.
        // The '.' syntax is used for invoking local functions.
        json time = check response.getJsonPayload();

        // json objects can be defined inline.
        // json keys and objects do not require escaping.
        // json objects can use variables and functions.
        json payload = {
                           source: "Ballerina",
                           time: time
                       };
        response.setJsonPayload(payload);
        _ = caller -> respond(response);
    }
}
