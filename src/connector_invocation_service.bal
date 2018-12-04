import ballerina/http;
import ballerina/io;

listener http:Listener ep = new(9090);

@http:ServiceConfig {
    basePath: "/time"
}
service timeInfo on ep {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    resource function getTime(http:Caller caller, http:Request req) {

        // You can define an endpoint to an external service. This
        // endpoint instantiates an HTTP client endpoint.
        // 'timeServiceEP' becomes a reusable variable elsewhere
        // within our code.
        http:Client timeServiceEP = new("http://localhost:9095");

        // Invoke the 'get' resource against the 'timeServiceEP'
        // endpoint. '->' indicates request is over a network.
        // Returned result can either be an http response or an
        // error.
        var result = timeServiceEP->get("/localtime");
        if (result is http:Response) {
            // json and xml are primitive data types! The '.' syntax
            // is used for invoking local functions.
            var returnValue = result.getJsonPayload();
            if (returnValue is json) {
                // json objects can be defined inline. json keys and
                // objects do not require escaping. json objects can use
                // other variables and functions.
                json payload = {
                    source: "Ballerina",
                    time: returnValue
                };
                _ = caller->respond(untaint payload);
            } else if (returnValue is error) {
                //Panicking inside a resource sends a 500 status
                //response to the caller with the error details.
                panic returnValue;
            }
        } else if (result is error) {
            //Panicking inside a resource sends a 500 status
            //response to the caller with the error details.
            panic result;
        }
    }
}
