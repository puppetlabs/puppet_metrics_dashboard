# Default Dashboards

- [Real Time Metrics](#real-time-metrics)
  - [Telegraf](#telegraf)
    - [Telegraf Puppetserver Performance](#telegraf-puppetserver-performance)
    - [Telegraf Puppetserver Workload](#telegraf-puppetserver-workload)
    - [Telegraf File Sync Metrics](#telegraf-file-sync-metrics)
    - [Telegraf PuppetDB Performance](#telegraf-puppetdb-performance)
    - [Telegraf PuppetDB Workload](#telegraf-puppetdb-workload)
    - [Telegraf Postgres Metrics](#telegraf-postgres-metrics)
  - [Graphite](#graphite)
    - [Graphite Puppetserver Performance](#graphite-puppetserver-performance)
- [Archive Metrics](#archive-metrics)
## Real Time Metrics
### Telegraf
#### Telegraf Puppetserver Performance
This dashboard is to inspect `Puppetserver` service performance and troubleshoot `Puppetserver` service issues. Available Graphs:
- Puppetserver Performance Graph: This graph is to monitor JRuby instances performance collectivelly
  - Average free JRubies
  - Average requested JRubies
  - Average JRuby borrow time
  - Average JRuby wait time 
- Heap Memory and Uptime Graph: This graph is to monitor JRuby Heap usage
  - Heap Committed
  - Heap Used
  - Uptime
- Average Requested JRubies Graph
- Average Borrow Time Graph
- Avergae Free JRubies Graph
- Average Wait Time Graph

**User Case**
- Puppetserver service performance downgraded
- ERROR 503 
- Agent unable to get catalog
#### Telegraf Puppetserver Workload
This dashboard is to inspect `Puppetserver` service workloads and performance in each category - Catalogs, Environment Classes, Environment Modules, Environments, File metadata, Nodes. Available Graphs: 
- JRuby Borrow Timers (Ave) Graph
- JRuby Borrow Timers (Rate) Graph

**User Case**
- Inspect performance for a particular type of request
- Inspect which type of request could be a performance bottleneck
#### Telegraf File Sync Metrics
This dashboard is to inspect File-sync related performance. Available Graphs:
- Number of Fetch / Commits vs Lock wait / held
  - Average Lock Held Time
  - Avergee Lock Wait Time
  - Number of Commits
  - Number of Fetches
- File-Sync timing - Client Services
  - Average Clone Time
  - Average Fetch Time
  - Average Sync Time
  - Average Sync Clean Time
- File-Sync timing - Storage Services
  - Average Commit add / rm Time
  - Average Commit time
  - Average Clean Check time
  - Average Pre-commit Hook Time

**User Case**
- Code Manager takes a significant long time or fail to deploy codes
- Puppetserver frequently locked due to file sync
- Compilers are not able to pick up latest codes
#### Telegraf PuppetDB Performance
This dashboard is to inspect PuppetDB service performance. Available Graphs:
- Commands Per Second
- Command Processing Time
- Heap
- Queue Depth
- Replace Catalog Time
- Replace Facts Time
- Store Report Time

**User Case**
- Any PuppetDB performance issues
#### Telegraf PuppetDB Workload
This dashboard is to inspect PuppetDB Read/Write Pool performance. Available Graphs:
- Average Command Persistence Time
- Average Read Duration
- Peak Read Pool Wait
- Read Pool Pending Connections
- Average Write Duration
- Peak Write Pool Wait
- Write Pool Pending Connections

**User Case**
- Troubleshooting Read/Write Pool Errors
- General PuppetDB performance issues
#### Telegraf Postgres Metrics
This dashboard is to inspect PostgreSQL database performance. Available Graphs:
- Temp Files
- Table Sizes
- Autovacuum Activity
- Vacuum Activity - (not auto, not full)
- I/O - heap toast and index - hits / reads
- Live / Dead Tuples
- Deadlocks

**User Cases**
- Monitor table sizes
- Monitor Deadlocks and Slow Queries
- Any PostgreSQL performance issues
### Graphite
#### Graphite Puppetserver Performance
This dashboard is to inspect Puppetserver service performance in Graphite. Available Graphs:
- JRuby Usage
- JRuby Pool Timers
- JVM metrics
- Requested Duration
- Compilation
- External HTTP Communications
- Request Ratios
- Active Requests
- File Sync

**User Cases**
- Monitor Puppetserver performance in Graphite

## Archive Metrics
These are Dashboards for troubleshooting purposes. Data can be imported per [Import Acrhive Metrics into InfluxDB](https://github.com/puppetlabs/puppet_metrics_dashboard#import-archive-metrics-into-influxdb). The user cases are the same with the same type of Telgraf real-time dashboards. 
### General
#### Archive Puppetserver Performance
#### Archive PuppetDB Performance
#### Archive PuppetDB Workload
#### Archive Orchestrator Services
This dashboard is to inspect Orchestrator Services performance. Available Graphs:
- Thread Pool
- Orchestrator Heap Memory
- Process RSS Memory

**User Cases**
- Troubleshoot Orchestrator Heap Usage outages
- Troubleshoot Orchestrator Performance issues 
#### Archive Postgres Performance
#### Archive Process-System stats
This is to inspect the overall system CPU and Momory usage. Available Graphs:
- Process Memory
- Process CPU
- System memory
- System CPU

**User Cases**
- Inspect system resource utilization
- Potential Hardware issues

### Deeper Dives
#### Archive Puppetserver JVM Performance
This is to inspect Puppetserver JVM Performace. Available Graphs:
- Heap Memory
- Non-Heap Memory
- Process RSS memory
- Process CPU usage
- GC CPU Usage
- GC-stats

**User Cases**
- Troubleshoot PuppetServer JRuby performance and issues
#### Archive PuppetDB JVM Performance
This is to inspect PuppetDB JVM Performance. Available Graphs:
- Heap Memory
- Non-Heap Memory
- Process RSS memory
- Process CPU usage
- GC CPU Usage
- GC-stats

**User Cases**
- Troubleshoot PuppetDB JRuby performance and issues
#### Archive Orchestrator JVM Performance
This dashboard is to inspect Orchestrator JVM performance in a deeper level. Available Graphs:
- Heap Memory
- Non-Heap Memory
- Process RSS memory
- Process CPU usage
- GC CPU Usage
- GC-stats

**User Cases**
- Troubleshoot Orchestrator Heap Usage outages
- Troubleshoot Orchestrator Performance issues
- Troubleshoot Orchestrator GC related issues
#### Archive File Sync Metrics
#### Archive Ace Puma Performance
This dabhboard is to inspect ACE service performance. Available Graphs:
- Thread Pool
- Process CPU
- Process RSS Memory

#### Archive Bolt Puma Performance
This dashboard is to inspect Bolt service performance. Available Graphs:
- Thread Pool
- Process CPU
- Process RSS Memory
