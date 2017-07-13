#!/bin/env python

# The original gcloud_tree is generated with the following command:
#     gcloud meta list-gcloud --format=json | python -c "import json;import sys;data = json.load(sys.stdin);print 'gcloud_tree =', data" >> gcloud_tree.py
# This leads to creating a very inefficient 19MB data file. By downloading 
# and storing the same json data, this method keeps it under 25K.

import gzip
import json
gcloud_tree = json.load(gzip.open("/google-cloud-sdk/gcloud_tree.json.gz"))
