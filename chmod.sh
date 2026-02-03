#!/bin/bash

find . -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null
echo "Execute permissions added to all .sh files"
