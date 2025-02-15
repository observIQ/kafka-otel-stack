- sending queue consumer count must be tuned at high load
  - 40,000+ EPS / 1,000 batch size overwhelmed the default 10 consumer threads
    - 20 consumer threads seems to work fine, handling 63,000 EPS

- single partition kafka seems to be a bottleneck around 77,000 EPS
  - Partition lag increases
  - Sending queue is not filling up
  - Accepted log records is much lower than the publishes logs sent
  - This implies the receiver is simply not keeping up
  - Trying a second partition:
    - partitions 4 seems to help, now we have sending queue issues
    - 200,000 EPS
    - Trying 40 consumer threads:
      - Sending queue is fine now, but the partition lag is increasing
      - Trying 8 partitions
        - 8 is not enough, still have lag but it is less pronounced
        - no sending queue issues
        - Trying 12 partitions
          - Consumer group lag continues
          - No sending queue issues
          - Trying 16 partitions
            - still struggling, delta between produced and consumed is 35,000 logs
              - Trying 32 partitions
    - We can use up to 10 partitions, trying to tune fetch size
      - receiver fetch size 1mb --> 4mb
        - No joy
    - Trying 62 partitions
    


All tests done with in memory sending queue
- At some point persistent queue will bottleneck, I think this is a problem for another day

Consumer groups
- unclear if one collector is always assigned the total number of partitions

Ave log size: 270 bytes
Ave batch size should be roughly 0.27MB
16c / 32t ryzen 7950x3d

Tuning guidelines
- 0 - 20,000 EPS
  - 10 consumers
  - 1 partition
- 20,000 - 40,000 EPS
  - 20 consumers
  - 1 partition
- 40,000 - 70,000 EPS
  - 20 consumers
  - 4 partitions
- 70,000 - 120,000 EPS
  - 30 consumers
  - 8 partitions
- 200,000 EPS
  - Could never get this to work
    - 40 consumers
    - 64 partitions
    - increased fetch size from 1mb to 4mb
    - always had a delta of 35,000 logs produced vs consumed

Log Size
- 122 byte logs seem to work great
- huge windows event logs might require additional tuning
  - timeout issues
  - also unclear if I was experiencing issues with "duplicate" logs"
    - telemetry generator
    - secops is known to start timing you out if you are sending repeat logs


Processor impact.

Using the 120,000 EPS configuration as a baseline.
Processors are placed before the existing add field + batch processor

Json processor
- Sending queue goes to 0 right away, because the pipeline has slowed down
  - Partition lag increases right away, further proving this point
  - 95,000 EPS seems fine though

Adding filter and marshal to simulate filtering some logs
out and then going back to a string.
- More lag, had to reduce log volume further

- Seems okay at 75,000 EPS
