#!/bin/bash
echo "===== Disk & Memory Check ====="

echo "current disk usage: $(df -h)"
echo "current memory usage: $(free -h)"
echo "Check Complete!"
