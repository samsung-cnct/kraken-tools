#!/bin/env python

import gzip
import json
gcloud_tree = json.load(gzip.open("/google-cloud-sdk/gcloud_tree.json.gz"))
