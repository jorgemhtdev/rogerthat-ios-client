<html><head><meta charset="UTF-8" /><script language="javascript" type="text/javascript">

function validation(validationParams) {
    var result = validationParams.result;
    var rt = validationParams.rogerthat;
    var js_code = validationParams.javascriptcode;

    var serverActions = [];
    var returnValue = null;
    var locals = {
        context_result : cloneObj(result),
        rogerthat : cloneObj(rt),
        window : {},
        document : {}
    };

    // create our own this object for the user code
    var that = Object.create(null);

    var code = 'function alert(message) {};' + js_code
    + ' try{ return {result: run(context_result, rogerthat), error: null }; } catch(ex){ return {result: null, error: ex };}';
    try {
        var s = createSandbox(code, that, locals)(); // call the user code in the sandbox
        if (s.result === undefined || s.result === null || s.error === undefined || s.error !== null) {
            if (s.error) {
                addLogToServer(serverActions, s.error, code);
            }
        } else if (typeof(s.result) == "string") {
            returnValue = s.result;
        }

    } catch (ex) {
        addLogToServer(serverActions, ex, code);
    }

    function addLogToServer(serverActions, ex, code) {
        var message = "Type: " + ex.name;
        message += "\nMessage: " + ex.message;
        message += "\nCode:\n" + code;

        request = {
            mobicageVersion : "",
            platform : 7,
            platformVersion : "",
            errorMessage : message,
            description : "",
            timestamp : parseInt(new Date().getTime() / 1000)
        }
        serverActions.push(createIncomingJsonCall('com.mobicage.api.system.logError', request));
    }

    function createSandbox(code, that, locals) {
        var params = []; // the names of local variables
        var args = []; // the local variables

        for ( var param in locals) {
            if (locals.hasOwnProperty(param)) {
                args.push(locals[param]);
                params.push(param);
            }
        }

        // create the parameter list for the sandbox
        var context = Array.prototype.concat.call(that, params, code);
        // create the sandbox function
        var sandbox = new (Function.prototype.bind.apply(Function, context));
        // create the  argument list for the sandbox
        context = Array.prototype.concat.call(that, args);
        // bind the local variables to the sandbox
        return Function.prototype.bind.apply(sandbox, context);
    }

    return {
        return_value : returnValue,
        server_actions : serverActions
    };
}

function createIncomingJsonCall(funcName, request) {
    var r = {};
    r['av'] = 1;
    r['t'] = now();
    r['ci'] = '_js_callid_' + GUID();
    r['f'] = funcName;
    r['a'] = {
        "request" : request
    };
    return r;
}

function now() {
    return Math.round(new Date().getTime() / 1000);
}

function GUID() {
    var S4 = function() {
        return Math.floor(Math.random() * 0x10000 /* 65536 */
                          ).toString(16);
    };

    return (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4());
}

function cloneObj(obj) {
    /* Handle the 3 simple types, and null or undefined */
    if (null == obj || "object" != typeof obj)
        return obj;

    /* Handle Date */
    if (obj instanceof Date) {
        var copy = new Date();
        copy.setTime(obj.getTime());
        return copy;
    }

    /* Handle Array */
    if (obj instanceof Array) {
        var copy = [];
        for (var i = 0, len = obj.length; i < len; i++) {
            copy[i] = cloneObj(obj[i]);
        }
        return copy;
    }

    /* Handle Object */
    if (obj instanceof Object) {
        var copy = {};
        for ( var attr in obj) {
            if (obj.hasOwnProperty(attr))
                copy[attr] = cloneObj(obj[attr]);
        }
        return copy;
    }

    throw new Error("Unable to copy obj! Its type isn't supported.");
}

function getStackTrace(e) {
    return e.stack.replace(/\[native code\]\n/m, '').replace(/^(?=\w+Error\:).*$\n/m, '').replace(/^@/gm,
                                                                                                  '{anonymous}()@');
}

function mc_run(func, arg_list) {
    var r = {};
    try {
        /* "this" will be null in the called function */
        var the_result = func.apply(null, arg_list);
        r['success'] = true;
        r['result'] = the_result;
    } catch (err) {
        r['success'] = false;
        r['errname'] = err.name;
        r['errmessage'] = err.message;
        r['errstack'] = getStackTrace(err);
    }

    var s = JSON.stringify(r);
    return s;
}

function mc_run_ext(func) {
    var arg_list = [];
    for (var i = 1; i < arguments.length; i++)
        arg_list.push(arguments[i]);
    return mc_run(func, arg_list);
}

</script></head></html>