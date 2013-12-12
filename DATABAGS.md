`iib_nodes` data bags
==========================
`iib_nodes` data bags can be used with the `ibm_integration_bus` recipes to configure a system to have a collection of integration nodes running, with a set of integration servers for each integration node.

Any number of IIB nodes can be created, including creating no nodes, if you prefer to create and setup the nodes after the chef recipes are finished.

The IIB data bags must be created in a folder called iib_nodes in the chef server data bag directory:
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
* `qmgrListenerPort` - the port to use for the queue manager listener port. If this value is not present in the data bag then no listener is started.
* `node` - a json document representing the node to be created. The format of this document is based on the IIB REST api. It follows the same format as doing a REST get from the root context on a node (for example: HTTP get from `http://localhost:4414/apiv1?depth=2`) but only the fields shown in the example above are currently supported and any other parts of the json doc are ignored. The `properties` sections must also be inserted by doing a separate REST call to the propertiesUri and then the retrieved json must be added to the main document as a properties folder (For example: HTTP get from `http://localhost:4414/apiv1/properties`). 

The node section has the following properties that can be set:

* `name` - the name of the integeration node to be created.
* `queueManager` - the name of the queue manager to use when creating the node.
* `operationMode` - the operation mode to use for the node: express, standard or advance.
* `webAdminEnabled` - turn Web admin on: true or false.
* `webAdminHTTPListenerPort` - the port to use for Wed admin.
* `httpListenerPort` - the http listener port to use.
* `executionGroup` - a list of Integration servers to create.

Any missing property will cause the normal integration node default to be used.

An example of a default configuration data bag is available in the cookbook and is called [default_iibnode.json](./default_iibnode.json).