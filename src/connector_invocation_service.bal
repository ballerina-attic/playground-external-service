import ballerina/http;
import ballerina/io;

endpoint http:Listener listener {
    port: 9090
};

@http:ServiceConfig {
    basePath: "/time"
}
service<http:Service> timeInfo bind listener {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    getTime(endpoint caller, http:Request req) {

        // You can define an endpoint to an external service. This
        // endpoint instantiates an HTTP connector. 'timeServiceEP'
        // becomes a reusable variable elsewhere within our code.
        endpoint http:Client timeServiceEP {
            url: "http://localhost:9095"
        };

        // Invoke the 'get' resource against the 'timeServiceEP'
        // endpoint. '->' indicates request is over a network.
        // 'check' assigns return to response if the right data 
        // type is found. If not, then an error is propagated.
        http:Response response = check
                     timeServiceEP -> get("/localtime");

        // json and xml are primitive data types! The '.' syntax
        // is used for invoking local functions. 
        json time = check response.getJsonPayload();

        // json objects can be defined inline. json keys and
        // objects do not require escaping. json objects can use
        // other variables and functions.
        json payload = {
            source: "Ballerina",
            time: time
        };
        response.setJsonPayload(untaint payload);
        _ = caller->respond(response);
    }
}
