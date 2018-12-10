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
    resource function getTime(http:Caller caller, http:Request req)
                                                returns error? {

        // You can define an endpoint to an external service. This
        // endpoint instantiates an HTTP client endpoint.
        // 'timeServiceEP' becomes a reusable variable elsewhere
        // within our code.
        http:Client timeServiceEP = new("http://localhost:9095");

        // Invoke the 'get' resource against the 'timeServiceEP'
        // endpoint. '->' indicates request is over a network.
        // If an error is returned, resource function gets returned
        // with that error which eventually is sent to the caller.
        http:Response response = check timeServiceEP->
                                                get("/localtime");

        // json and xml are primitive data types. The '.' syntax
        // is used for invoking local functions.
        json returnValue = check response.getJsonPayload();

        // json objects can be defined inline. json keys and
        // objects do not require escaping. json objects can use
        // other variables and functions.
        json payload = {
            source: "Ballerina",
            time: returnValue
        };
        _ = caller->respond(untaint payload);
        return;
    }
}
