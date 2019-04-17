import ballerina/http;
import ballerina/io;
import ballerina/time;


// ***** This service acts as a backend and is not exposed via playground samples ******

listener http:Listener backend = new(9095);

@http:ServiceConfig { basePath: "/localtime" }
service timeService on backend {
    @http:ResourceConfig {
        path: "/", methods: ["GET"]
    }
    resource function sayHello(http:Caller caller, http:Request request) returns error? {
        http:Response response = new;
        time:Time currentTime = time:currentTime();
        string customTimeString = check time:format(currentTime, "yyyy-MM-dd'T'HH:mm:ss");

        json timeJ = { currentTime: customTimeString };
        response.setPayload(timeJ);
        _ = check caller->respond(response);
    }
}
