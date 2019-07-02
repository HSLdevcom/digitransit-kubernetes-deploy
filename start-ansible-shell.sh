#!/bin/bash

docker run -it --rm -v $(pwd):/etc/ansible:ro -v $(pwd)/.cache:/cache:rw -e DEFAULT_SUBSCRIPTION=digitransit-prod hsldevcom/azure-ansible /bin/bash
