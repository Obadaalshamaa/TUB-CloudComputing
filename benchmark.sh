

# Check and install sysbench if missing
if ! command -v sysbench >/dev/null 2>&1; then
  echo "Sysbench not found. Installing..."
  sudo apt-get update -y >/dev/null 2>&1
  sudo apt-get install -y sysbench >/dev/null 2>&1
else
  echo "Sysbench already installed."
fi

# Record timestamp
TIMESTAMP=$(date +%s)

# CPU benchmark (events per second)
CPU_RESULT=$(sysbench cpu --time=60 run | grep 'events per second:' | awk '{print $NF}')

# Memory benchmark (MiB/s, 4KB block size, 100TB total)
MEM_RESULT=$(sysbench memory --time=60 --memory-block-size=4K --memory-total-size=100T run | grep 'MiB/sec' | awk '{print $NF}')

# Random disk read benchmark
sysbench fileio --file-total-size=1G --file-num=1 prepare >/dev/null 2>&1
DISK_RAND=$(sysbench fileio --file-total-size=1G --file-num=1 --file-test-mode=rndrd --file-extra-flags=direct --time=60 run | grep 'read, MiB/s:' | awk '{print $NF}')
sysbench fileio cleanup >/dev/null 2>&1

# Sequential disk read benchmark
sysbench fileio --file-total-size=1G --file-num=1 prepare >/dev/null 2>&1
DISK_SEQ=$(sysbench fileio --file-total-size=1G --file-num=1 --file-test-mode=seqrd --file-extra-flags=direct --time=60 run | grep 'read, MiB/s:' | awk '{print $NF}')
sysbench fileio cleanup >/dev/null 2>&1

# Output
echo "${TIMESTAMP},${CPU_RESULT},${MEM_RESULT},${DISK_RAND},${DISK_SEQ}"
