\chapter{Cassandra}
\chapterauthor{David Marchi, Daniel Schäfer, Erik Zeiske}

# Properties of Cassandra (David)
> Cassandra is a distributed storage system for managing very
> large  amounts  of  structured  data  spread  out  across  many
> commodity servers, while providing highly available service
> with no single point of failure. \autocite{lakshman2010cassandra}

https://www.youtube.com/watch?v=B_HTdrTgGNs
- writes to a single node.
- sequential I/O vs random I/O?

Cassandra - Writes in the cluster:
- fully distributed, no Single Point of Failure
- partitioning:
  - `primary_key` MD5 hash
  - token ring
  - 128Bit nbr into 4 chunks
  - Hash of `primary_key` fits into one of the chunks
    - good distribution
  - each node has a replication factor
    - e.g. replication factor 3 -> data gets replicated on up to 3 nodes
  - change to virtual nodes, MD5 ranges are smaller
    -

Cassandra - Reads
  - Request Hits first Node:
    - Doesn't have the data
    - coordinates data request and asks other nodes

- Wide Column Store
- Distributed Data Store

- Distributed and Decentralized
- Elastic Scalability
  -> Just add another machine, Cassandra will adapt it.
- High Availability and Fault Tolerance
  -> Replace failed nodes in the cluster with not downtime, replicate data to multiple data centers
- Tuneable Consistency (Cassandra often called "eventually consistent")
  -> Strict consistency -> any read will always return the most recently written value
  -> Causual consistency -> causal writes must be read in sequence
  -> Weak (eventual) consistency -> all updates will propagate through all of the replicas, eventually all will be consistent

"That is, a distributed database designer must choose to make the system either always readable or always writable."
Cassandra choose to be alyways writable.

=> Replicatino factor determines how much one wants to pay in performance to goin more consistency.
#### Row-Oriented versus Column Oriented
  "Cassandra has frequently been referred to as a “column-oriented” database, which has proved to be the source of some confusion. A column-oriented database is one in which the data is actually stored by columns, as opposed to relational databases, which store data in rows. Part of the confusion that occurs in classifying databases is that there can be a difference between the API exposed by the database and the underlying storage on disk. So Cassandra is not really column-oriented, in that its data store is not organized primarily around columns."

"Cassandra stores data in a multidimensional, sorted hash table."

Cassandra was developed by Facebook to solve its inbox search problem.


## Terminology
% https://docs.datastax.com/en/glossary/doc/glossary/glossaryTOC.html
- Bloom Filter
- Column
- Columnfamily <-> Table (Since Cassandra 3.0 you can use the `TABLE` keyword)
- Compaction: Process of compacting SSTables
- Coordinator: The node that the client talks to
- Keyspace <-> Database
- Node
- Partition
- Partition Key
- Partitioner
- Primary Key
- Repair
- Ring
- SSTable: File format on disk
- Seed-Node
- Static Column: A special column that is shared by all rows of a partition.
- Table
- Token
- Tombstone: Marker of a not-present (e.g. deleted) value
- Virtual node
- Zombie

# Goals of Cassandra (David)
- Distri
# Use cases of Cassandra (David)
- Large Deployments
  - ingenuety, architecture and feature set is limited when used as single-node
  - several nodes -> might be a fit
  - dozens of nodes -> cassandra great fit
- Lots of Writes, Statistics and Analysis
  - consider in respect to read / write ratio
  - cassandra optimized for write throughput
  - "high performance at high write volumes with many concurrent client threads" primary features of cassandra
- Geographical Desitribution
  - configure to replicate across multiple data centers
  - globally deployed application
  - putting data near user
- Evolving Applications
  - support for flexible schema suitable to evolve database with application
-

# How to model data to take advantage of Cassandra (David & Daniel)

1. Determine what queries you want to support
2. Create table according to your queries

https://www.guru99.com/cassandra-data-model-rules.html

> Writes are cheap. Write everything the way you want to read it. % https://medium.com/@alexbmeng/cassandra-query-language-cql-vs-sql-7f6ed7706b4c

% https://www.scnsoft.com/blog/cassandra-performance

Base assumptions:

- Disk space is cheap.
- Writes are cheap.
- Network communication is expensive

#### Design Differences Between RDBMS and Cassandra
- no joins
  - Cassandra has no ability to execute joins
  - Bad solution; perform join client side
  - Cassandra typical solution; create a denormalized second table that represents the join result

- no referential integrity
  - no concept of referential integrity across tables
  - IDs related to other entities can be stored, but operations are not available

- denormalization
  - performes best when data model is denormalized

- query-first  design
  - start with query model instead of data model
  - writing down most common query paths of an application will use and then create tables to support those

- designing for optimal storage
  - since tables are stored in spereate files on disk it is recommended to keep related columns defined together in the same table
  - minimize the number of partitions that must be searched in order to fulfill a given query.

- sorting a design decision
  - sort order available on queries is fixed (determined by the selection of clustering columns supplied in the CREATE TABLE command)
  -

## Non-Goals (Things to avoid doing)
- Minimize the number of writes
- Minimize data duplication

## Goals

- Spread data evenly around the cluster
- Minimize the number of partitions read
- **DENORMALIZE**

## Examples

Many-to-many:
create tables for both direction

# How data is saved on disk (Erik)
% https://docs.datastax.com/en/cassandra/3.0/cassandra/dml/dmlHowDataWritten.html

Commit Log: https://stackoverflow.com/a/34594958/5932056
Commit log stores updates in the order which they were processed by Cassandra

## SSTable
- Immutable
  - never appended, only new ones created
  - only deleted when a compaction occurs
- Stores rows in sorted order

**NOT** column oriented!
Rows are stored one by one like a regular database

```
[
  {
    "partition" : {
      "key" : [ "john" ],
      "position" : 49
    },
    "rows" : [
      {
        "type" : "row",
        "position" : 101,
        "liveness_info" : { "tstamp" : "2019-03-29T17:56:23.935411Z" },
        "cells" : [
          { "name" : "email", "value" : "john@gmail.com" },
          { "name" : "lastname", "value" : "Smith" },
          { "name" : "name", "value" : "John" }
        ]
      }
    ]
  },
  {
    "rows" : [
      {
        "type" : "row",
        "position" : 45,
        "liveness_info" : { "tstamp" : "2019-04-06T18:16:33.544670Z" },
        "cells" : [
          { "name" : "age", "value" : 25 },
          { "name" : "email", "deletion_info" : { "local_delete_time" : "2019-04-06T18:16:33Z" }
          },
          { "name" : "lastname", "value" : "Austen" },
          { "name" : "name", "value" : "Kate" }
        ]
      }
    ]
  },
  {
    "partition" : {
      "key" : [ "jack" ],
      "position" : 102
    },
    "rows" : [
      {
        "type" : "row",
        "position" : 150,
        "liveness_info" : { "tstamp" : "2019-03-29T18:02:19.733455Z" },
        "cells" : [
          { "name" : "age", "value" : "33" },
          { "name" : "lastname", "value" : "Sparrow" },
          { "name" : "name", "value" : "Jack" }
        ]
      }
    ]
  }
```

## Compaction
Compaction strategies:

- SizeTieredCompactionStrategy
- LeveledCompactionStrategy
- TimeWindowCompactionStrategy
- DateTieredCompactionStrategy (deprecated in 3.0)

# Distributedness (Erik & Daniel)
## How it works
Ring
https://engineeringblog.yelp.com/2016/06/monitoring-cassandra-at-scale.html

### Balancing

Adding/Removing nodes and then rebalancing:

https://www.datastax.com/dev/blog/balancing-your-cassandra-cluster

## Scalability
> Adding nodes increases the disk and memory available to the cluster, and decreases the load per node.

> Consistent hashing also minimises the key movements when nodes join or leave the cluster. On average only $k/n$ keys need to be remapped where k is the number of keys and n is the number of slots (nodes).
https://dzone.com/articles/introduction-apache-cassandras

> Cassandra uses a gossip protocol to discover node state for all nodes in a
> cluster.  Nodes discover information about other nodes by exchanging state
> information about themselves and other nodes they know about. This is done with
> a maximum of 3 other nodes. Nodes do not exchange information with every other
> node in the cluster in order to reduce network load. They just exchange
> information with a few nodes and over a period of time state information about
> every node propagates throughout the cluster. The gossip protocol facilitates
> failure detection.
https://dzone.com/articles/introduction-apache-cassandras


## CAP (Consistency, Availability, Partition Tolerance)

> The consistency level determines the number of replicas that need to
> acknowledge the read or write operation success to the client application. For
> read operations, the read consistency level specifies how many replicas must
> respond to a read request before returning data to the client application. If a
> read operation reveals inconsistency among replicas, Cassandra initiates a read
> repair to update the inconsistent data.
https://docs.datastax.com/en/cassandra/3.0/cassandra/dml/dmlConfigConsistency.html

Default is AP with eventual consistency.

Custom priority can be chosen.
% https://blog.imaginea.com/consistency-tuning-in-cassandra/

CP: https://stackoverflow.com/a/25043599/5932056

https://docs.datastax.com/en/cassandra/3.0/cassandra/dml/dmlAboutDataConsistency.html
https://docs.datastax.com/en/cassandra/3.0/cassandra/dml/dmlConfigConsistency.html

Consistency: **Hinted Handoff**

Consistency Levels

$$$
quorum = (sum_of_replication_factors / 2) + 1
$$$

Default is `ONE` (High AP, little C)

| Level | Description |
| `ALL` | On all replicas |
| `EACH_QUORUM` | Quorum of replicas in each datacenter |
| `QUORUM` | Quorum in the entire cluster |
| `LOCAL_QUORUM` | Quorum in the datacenter of the coordinator |
| `ONE` | At least one replica |
| `TWO` | At least two replicas |
| `THREE` | At least three replicas |
| `LOCAL_ONE` | At least one in the datacenter of the coordinator |

## Replication and Replica Placement Strategies
- SimpleStrategy (For evaluating Cassandra)
  - "The Simple Strategy orders the nodes by their initial token and places the replicas clockwise around the ring of nodes"
- NetworkTopologyStrategy (For production use or for use with mixed workloads)

## Partitioners
% https://docs.datastax.com/en/cassandra/3.0/cassandra/architecture/archPartitionerAbout.html

- Murmur3Partitioner
- Random Partitioner
- Byte Order Partitioner

## Consistency Level
> The Consistency Level (CL) supplied by the client specifies how many nodes must agree for an operation to be successful.
> For Reads this is number is known as CL.R.For Writes it is known as CL.W.
> The common Consistency Levels are One, Quorum and All.Quorum is (N/2) +1.
>
> No matter what the Consistency Level, the cluster will work to Eventually make the on disk data for all replicas Consistent.
> To get consistent behaviour for all operations ensure thatR + W > N
% http://thelastpickle.com/files/2011-02-07-introduction-to-cassandra/introduction-to-cassandra.pdf

https://docs.datastax.com/en/cassandra/3.0/cassandra/dml/dmlClientRequestsRead.html
https://docs.datastax.com/en/cassandra/3.0/cassandra/dml/dmlClientRequestsReadExp.html

# Similarities and Differences to Other Databases(Daniel)
The authors of Cassandra call it a "distributed storage system" that "resembles a database"\autocite{lakshman2010cassandra}.
In many ways it does look like a classical database and can be used as such but there are some key differences that the user must be aware. This chapter lays out the similaries and differences in kind and usage of Cassandra as well as outlining benefits and drawback of those.
Some of the points mentioned here aredescribed in more detail in their respective chapters.

## Advantages and disadvantages summary
- Advantages
  - Elastic Scalability - easily add or remove nodes
  - Peer to peer instead of master slave $\rightarrow$ No single point of failure & Write to any node
  - Great analytics capabilities (e.g. with Hadoop, Spark, ...)
  - Flexible data model (no strict schemas)
  - Fast writing (`INSERT`, `UPDATE`) because they are like appends (+ lots of caching layers)
  - CQL is very similar to SQL and therefore easy to learn
- Disadvantages
  - CQL doesn't have a lot of reatures that people have come to expect from SQL
  - Doesn't do data validation like `NULL`-constraint, uniqueness violations, ...
  - Needs repairs sometimes
  - Not ACID (No transactions)
  - Updates and deletes make future reads slow (tombstones)
  - Is more complex to set up because of its distributed nature

## Keep in mind
**Not relational!** Cassandra can be used much like a traditional table based database except that it does not support relations.
To query related data it has to be in the same table. This means that normalization is not just unnecessary but it actively hinders the effective and efficient usage of Cassandra. By implication this means that the data should be denormalized.
The reason for this is that a partition is guaranteed to be located on a single node - because of Cassandra's distributed nature however other tables might be located physically across the globe. A join across multiple datacenter locations could not be efficient.
% - Denormalize data => Super fast reads (no joins) but more data duplication

**Seed Nodes** The architecture of Cassandra works without having a master node. All of them are equally privileged. When a new node wants to join the cluster it has to know where the others are and get in sync with them. For that purpose the new node can be give a list of *seed nodes* that it can request the information necessary to be a member of the cluster.

**CAP** Cassandra is by an available, partition-tolerant system that supports eventual consistency.
CAP can be seen as not a hard choice between three absolutes but as a continuum between all of them. Cassandra offers parameters to tune where exactly it lies on that continuum. See XXX

## CQL
> Typically, a cluster has one keyspace per application. \autocite{datastax6cqldoc}

Keyspace == Database
Column Family == Table (Is called that in CQL 3)

Be aware that CQL can also stand for "Confluence Query Language" when searching for the internet. It looks very similar to Cassandra's query language but does not share the same grammar.

Bad Request: PRIMARY KEY column `schedule_id` cannot be restricted (preceding column `user_id` is either not restricted or by a non-EQ relation)
% https://stackoverflow.com/questions/28565470/cassandra-primary-key-column-cannot-be-restricted

### Comparison to SQL
- No
  - Transactions
  - Subqueries
  - `JOIN`
  - `GROUP BY`
  - `FOREIGN KEY`
  - `AUTO INCREMENT`
  - Logical `OR` and `NOT`, only `AND`
- Restrictions
  - Primary key is mandatory!
  - `UPDATE` needs `WHERE` with primary key
  - `WHERE` **only** works on primary key and other indexed columns

When an SQL programmer comes to Cassandra and tries to write CQL they will find it familiar. Very soon they will want to use keywords that seem fundamental to SQL but are not supported by Cassandra. The majority of these omissions are due to the fact that Cassandara does not support relations between tables.
Without relations there is no `JOIN`, `GROUP BY` or `FOREIGN KEY`s. Sub queries are not supported becaues they would also encourage users to access multiple tables in a single query.
Since Cassandra does not aim to guarantee constant consistency it also cannot provide transactions.

Because data can be inserted into any node it does not make sense to have a automatically increasing column. Without consistency multiple nodes could assign the same index to different columns.
To have a unique ID for a column Cassandra provides the `UUID` column type instead that is long enough so that it can be randomly assigned and be practically guaranteed to be different for new inserts at each node.

- Creating Keyspace(Database) requires replication strategy
- `UPDATE` inserts if row is not yet there
- `INSERT` replaces if row is already there
- No unique constraint
- `INSERT INTO xxx JSON`
- `SELECT JSON`
- `USING TTL` - set expiry date of row
- `ALLOW FILTERING`

When inserting or updating data Cassandra does not perform a read. This leads to the unability to check for a uniqueness constraint. Updating without reading means that the datastore is appended by a row with the new values and the old row is left as is. Because of these similarities between inserting and updating they are bosth collectively called *upserting*.
Lots of updates to a row lead to a decrease in read performance because the database engine will have to combine the original entry together with all (partial) updates to it.
% https://docs.datastax.com/en/cassandra/3.0/cassandra/dml/dmlWriteUpdate.html

A delete doesn't delete the data either. The datastore is appended TODO

### Column types
- Common DB Types
  - Blob
  - Boolean
  - Numbers
  - Strings
  - Time/Date values
- Collections
  - List
  - Map
  - Set
- Tuple
- Counter
- IP-Address
- Java Types
- UUID

Cassandra supports the different kinds of regular data types like booleans, string-, number- and date-types.

**Collections** Foo
Frozen blabla.

**Counter** Cannot be set, only incremented or decremented. All columns in the table have to be counters. Cannot be primary or partition key. Cannot be used with index or TTL.

**Java Types** Because Cassandra is implemented in Java and commonly used in conjunction with other Apache projects written in Java the column types can also be chosen from some Java types. XXX

### Materialized Views
No non materialized views!

> Materialized views are suited for high cardinality data. The data in a
> materialized view is arranged serially based on the view's primary key.
> Materialized views cause hotspots when low cardinality data is inserted.

Properties:
- Read only!
- Always materialized! (Data partitioned and duplicated)
- > automated server-side denormalization % https://www.datastax.com/dev/blog/new-in-cassandra-3-0-materialized-views

Restrictions:
- Include all of the source table's primary keys in the materialized view's primary key.
- Only one new column can be added to the materialized view's primary key. Static columns are not allowed.
- Exclude rows with null values in the materialized view primary key column.

TODO: Don't seem to be stable or advantageous in practice. Are recommended against by most people.

# Secondary Index
% https://docs.datastax.com/en/archived/cql/3.0/cql/ddl/ddl_when_use_index_c.html
% https://www.datastax.com/dev/blog/cassandra-native-secondary-index-deep-dive
> Secondary indexes are suited for low cardinality data. Queries of high
> cardinality columns on secondary indexes require Cassandra to access all
> nodes in a cluster, causing high read latency. \autocite{cassandra3cqldoc}

>  A primary index is global, whereas a secondary index is local.
https://pantheon.io/blog/cassandra-scale-problem-secondary-indexes

Don't use when:
- Table with counter column
- On high-cardinality column
- On extremely low cardinality column
- On a frequently updated or deleted column (because tombstones)

# Setting it up (Daniel)
## Machine/topological requirements and recommendations
> Cassandra can be made to run on small servers for testing or development
> environments (including Raspberry Pis), a minimal production server requires
> at least 2 cores, and at least 8GB of RAM. Typical production servers have 8
> or more cores and at least 32GB of RAM. \autocite{cassandracode}

## Configuration
All config files are located in `/etc/cassandra`.
Data is stored under `/var/lib/cassandra{cdc_raw,commitlog,data,saved_caches}`
Memory Consumption:

- `cassandra.yml`: Config for Cassandra itself
  - `cluster_name`
  - `listen_address`: The IP address or hostname that Cassandra binds to for connecting this node to other nodes.
  - `seed_provider`: A joining node contacts one of the nodes in the seed list to learn the topology of the ring.
  - `disk_optimization_strategy`: `ssd` or `spinning`
  - `num_tokens`: Set this property for virtual node token architecture. Determines the number of token ranges to assign to this (vnode).
- `cassandra-env.sh`
  - `MAX_HEAP_SIZE`: total amount of memory dedicated to the Java heap
  - `HEAP_NEWSIZE`

| Port | Description    |
| ---- | -------------- |
| 7000 | Inter-Node     |
| 7001 | SSL Inter-Node |
| 7199 | JMX Monitoring |
| ---- | -------------- |
| 9042 | (SSL) Client   |
| 9160 | Thrift Client  |
| 9142 | SSL Client     |

### Virtual Nodes
> Generally when all nodes have equal hardware capability, they should have the
> same number of virtual nodes (vnodes). If the hardware capabilities vary
> among the nodes in your cluster, assign a proportional number of vnodes to
> the larger machines. For example, you could designate your older machines to
> use 128 vnodes and your new machines (that are twice as powerful) with 256
> vnodes. % https://docs.datastax.com/en/cassandra/3.0/cassandra/configuration/configVnodesEnable.html

### Security
Security should always be kept in mind when running a program that multiple parties have access to and may be reachable over the internet. A database would be the prime target for attacks because it literally holds the data. An attacker could want to break in and change values or extract secret information.
Cassandra can expose up to six different port, as described in XXX. If these ports don't absolutely have to be accessible from the outside, they should be blocked by the firewall, preventing potential attackers from even trying to attack Cassandra directly.
Cassandra makes it possible for nodes to be physically distant apart, only communicate over the public internet and still belong to the same logical database cluster. In this case or in any other where the inter-node communication goes over an untrusted network, the traffic must be encrypted and authenticated with TLS. The same can and should be done for client to server communication.
Like many other Java applications Cassandra can me controlled using the Java Management Extensions (JMX). By default they are only available on *localhost* - make sure that is the case with your installation. For convenience it is available without authentication. It is recommended to force authentication and set up a user with a password. % https://docs.datastax.com/en/cassandra/3.0/cassandra/configuration/secureJmxAuthentication.html
The database itself also doesn't come with authentication configured. Again turn on forced password authentication and create a user. What's remaining is the default superuser `cassandra`. Since it cannot be deleted, it is recommended to create your own superuser with a different name, set the password of `cassandra` to something that's hard to brute-force and remove its `superuser` status. % https://docs.datastax.com/en/cassandra/3.0/cassandra/configuration/secureConfigNativeAuth.html
With version 2.2 Cassandra the access control was greatly improved. It's now possible to use Role Based Access Control (RBAC) to limit what groups of users can run which commands on specific keyspaces or tables. These roles can even be hierarchical: A role can be granted all permissions of another one.

In short, those items, but not limited to those, are what a Cassandra admin should tick off to make sure they did their due-diligence regarding security:

- Use a firewall to not expose it to the public internet
- Internode communication with TLS
- Client to Node communicaiton with TLS
- JMX management only on localhost and auth
- Authentication with password
- Disable default user
- Use Roles

# Comparison to similar databases
- HBase
- DynamoDB
- ScyllaDB
- Google Bigtable
- Microsoft Azure CosmosDB
- Other NoSQL

# Tools

- [Cassandra Reaper](http://cassandra-reaper.io/)
- [cstar](https://labs.spotify.com/2018/09/04/introducing-cstar-the-spotify-cassandra-orchestration-tool-now-open-source/)
- [DataStax](https://www.datastax.com/)

# Conclusion
The End
