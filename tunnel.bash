#!/bin/bash
ssh -R 9000:localhost:9000 -R 35729:localhost:35729 sg -N
