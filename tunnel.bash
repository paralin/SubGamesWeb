#!/bin/bash
ssh -R 4000:localhost:9000 -R 35729:localhost:35729 sg -N
