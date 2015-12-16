#!/bin/bash -ex

EXIT=0

# If apache running?
if /etc/init.d/apache2 status | grep -v grep | grep -q 'Apache2 is running';
then
    echo "Apache2 is running"
else
    echo "ERROR: Apache2 isn't running!"
    EXIT=1
fi

# Is a request to localhost successful?
if curl -o /dev/null --head --silent --write-out '%{http_code}\n' http://localhost | grep -v grep | grep -q '200';
then
    echo "Request to localhost successful"
else
    echo "ERROR: Request to localhost unsuccessful!"
    EXIT=1
fi

if curl -o /dev/null --head --silent --write-out '%{http_code}\n' http://localhost:8983/solr/ | grep -v grep | grep -q '200';
then
    echo "Request to solr successful"
else
    echo "ERROR: Request to solr unsuccessful!"
    EXIT=1
fi

if curl -X GET --silent 'http://localhost/api/3/action/datastore_search?resource_id=_table_metadata' | grep -v grep | grep -q '"success": true';
then
    echo "Request to datastore successful"
else
    echo "ERROR: Request to datastore unsuccessful!"
    EXIT=1
fi

exit $EXIT
