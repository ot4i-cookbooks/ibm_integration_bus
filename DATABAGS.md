`iib_nodes` data bags
==========================
You can use `iib_nodes` data bags with the `ibm_integration_bus` recipes to configure a system that runs a collection of integration nodes, with a set of integration servers for each integration node.

Any number of integration nodes can be created. If you prefer to create and set up the integration nodes after the chef recipes are finished, you can choose to create no integration nodes.

You must create the IIB data bags in a directory called iib_nodes in the chef server data bag directory:
```
data_bags   
      | iib_nodes
             | dev_1.json
             | qa_1.json
             | prod_1.json
```

The data bag contents resemble the following:


```json
{
  "id": "dev_1",
  "qmgrListenerPort": "1441",
  "node": {
    "name": "DEV_NODE_1",
    "properties": {
    "basicProperties": [
        {
          "value": "inactive",
          "name": "AdminSecurity" 
        },
        {
          "value": "true",
          "name": "webAdminEnabled"
        },
        {
          "value": "4451",
          "name": "webAdminHTTPListenerPort"
        }
     ],
     "advancedProperties": [ 
        {
          "value": "advanced",
          "name": "operationMode"
        },
        {
          "value": "DEV_QMGR_1",
          "name": "queueManager"
        },
        {
          "value": "7051",
          "name": "httpListenerPort"
        }
      ],
      "deployedProperties": [        
      ]
    },
    "executionGroups": {
      "type": "executionGroups",
      "executionGroup": [
        {
          "name": "SERVER_1"
        },
        {
          "name": "SERVER_2"
        },
        {
          "name": "SERVER_3"
        },
        {
          "name": "SERVER_4"
        }
      ]
    }
  }
}
```
There are three main name key values:

* `id` - the ID for the data bag that is used by the chef recipes to locate the data bag
* `qmgrListenerPort` - the port to use for the queue manager listener port. If this value is not present in the data bag, then no listener is started.
* `node` - a JSON document representing the integration node that is to be created. The format of this document is based on the IIB REST API. It follows the same format as doing a REST get from the root context on an integration node (for example: HTTP get from `http://localhost:4414/apiv1?depth=2`) but only the fields shown in the example above are currently supported, and any other parts of the JSON document are ignored. The `properties` sections must also be inserted by doing a separate REST call to the propertiesUri and then the retrieved JSON must be added to the main document as a properties folder (For example: HTTP get from `http://localhost:4414/apiv1/properties`). 

The node section has the following properties that can be set:

* `name` - the name of the integeration node to be created.
* `queueManager` - the name of the queue manager to use when creating the integration node.
* `operationMode` - the operation mode to use for the integration node: express, standard or advance.
* `webAdminEnabled` - turn Web admin on: true or false.
* `webAdminHTTPListenerPort` - the port to use for Wed admin.
* `httpListenerPort` - the http listener port to use.
* `executionGroup` - a list of Integration servers to create.

Any missing property will cause the normal integration node default to be used.

An example of a default configuration data bag is available in the cookbook and is called [default_iibnode.json](./default_iibnode.json). Further examples can be found in the `test/integration/data_bags/iib_nodes` directory and are documented in the ibm\_integration\_bus\_test cookbook's [readme file](./test/cookbooks/ibm_integration_bus_test/README.md).