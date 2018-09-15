# Graylog

Disclaimer

The documentation is build with the help of the [official Documeantion](http://docs.graylog.org/en/2.4/index.html) that can be found on 


This repo is covering the steps for planing and installing Graylog Log Monitoring System as docker and kubernetes


# Architecture
Every Graylog System is composed of at least one instance of Graylog Server, MongoDB and Elasticsearch. Each of these components are required and cannot be substituted with any other technology.

# Minimum
In a minimum Graylog deployment, all three components are installed on a single host. A minimum Graylog setup that can be used for smaller, non-critical, or test setups.

None of the components is redundant but it is easy and quick to set up.

![minimal architecture](architec_small_setup.png)

# Simple Multi-Node

In a Simple Multi-Node system, Graylog and Elasticsearch components each reside on their own hosts. Most customers install MongoDB on same host as the Graylog Server. Since it is used primarily for application configuration information, the load on MongoDB is low enough that it does not typically need it’s own host.

# Complex Multi-Node

For larger environments, or where High Availability is required, Graylog may be deployed in a Complex Multi-Node configuration. Both Graylog and Elasticsearch may be clustered to provide resilience in case of a node failure. Multi-node systems are often required in order support a high volume of events.

Complex Multi-Node designs will be required for larger production environments. It is comprised of two or more Graylog nodes behind a load balancer distributing the processing load.

The load balancer can ping the Graylog nodes via HTTP on the Graylog REST API to check if they are alive and take dead nodes out of the cluster.

![bigger architecture](architec_bigger_setup.png)

# Note
Some guides on the Graylog Marketplace also offer some ideas how you can use RabbitMQ (AMQP) or Apache Kafka to add some queueing to your setup.

# Architectural considerations
There are a few rules of thumb when scaling resources for Graylog:
- Graylog nodes should have a focus on CPU power. These also serve the user interface to the browser.
- Elasticsearch nodes should have as much RAM as possible and the fastest disks you can get. Everything depends on I/O speed here.
- MongoDB is storing meta information and configuration data and doesn’t need many resources.

Also keep in mind that ingested messages are only stored in Elasticsearch. If you have data loss in the Elasticsearch cluster, the messages are gone - unless you have created backups or archives of the indices.

# Getting Started
his guide is designed for first time users and is intended to give enough key information to get Graylog installed and configured initially. Each section links to additional details on the topic.

Graylog is a very flexible solution. It can be deployed in many different ways. For those who would like to do an initial lab evaluation of Graylog, we recommend starting with the virtual machine appliances.

Virtual Appliances are the fastest way to get started. However, since the Virtual Appliances are generally not suitable for use in production, they should be used strictly for proof of concept, evaluations or lab environments. Users should plan to pick one of the other, more flexible installation methods for a production deployment.

# Planning Your Log Collection
We know you are eager to get Graylog installed and working, but we ask that you take a few moments to review this section and plan your deployment appropriately. Proper planning will make the difference between a useful solution that meets a variety of stakeholder needs and a complicated mess that drains resources and provides little value. There are many factors you must consider when designing a log management solution.

# Strategies
Even in a small organization, modern environments produce a lot of log data. Not long ago, 500 MB per day was considered a normal volume of logs for a small shop. Today, 5GB per day is not unusual for a small environment. A large environment can produce a thousand times more than that.

Assuming an average event size of 500k, 5GB per day equates to 125 log events every second, some 10.8 million events per day. With that much information being generated, you will need a strategy to manage it effectively. There are two major approaches.

# Minimalist
“Doing the needful”

The Minimalist Strategy proceeds from a “Default No” position when deciding which events to collect. What that means is you don’t collect any log unless it is required for an identified business use case. This strategy has some advantages, it keeps licensing and storage costs down, by reducing the volume of collected events. It also minimizes the “noise” produced by extraneous events, allowing analysts to focus on events that have maximum value. Finally, it improves system and query efficiency, improving performance overall.

# Maximalist
“Collect it all, let Graylog sort it out.”

The Maximalist strategy is to collect all events that are produced by any source. The thinking goes, all log data is potentially valuable, especially for forensics. Collecting it all and keeping it forever guarantees you will have it if you need it. However, this strategy is often not practical, due to budgetary or other constraints. The cost of this strategy can be prohibitive, since many more technical and human resources must be devoted to collection, processing and storage of event data. There is a performance penalty associated with keeping extremely large data sets online that must be considered as well.

# Use Cases
“What do you want to do with event data?”

Use cases should inform most decisions during the planning phase. Some of these decisions include determining the event sources from which you must collect, how you will collect from these sources, how much of each event type to store, how events should be enriched and how long to retain the data.

Use case, broadly defined, means the technical steps necessary to achieve a technical and/or business outcome. An easier way to think about it is that a use case is a description of what you want to do with an event log once you’ve collected it. Use cases are often categorized to group like activities. Some common use case categories are Security, Operations, and DevOps. An example of a Security use case might be monitoring user logins to critical resources. An operations use case might monitor network or hardware performance, while DevOps use cases would focus on real-time application layer monitoring or troubleshooting.

# Event Log Sources
“What logs do you need to collect?”

In an environment where seemingly everything generates event logs, it can be difficult to know what to collect. In most cases, selection of event sources should be driven by the use cases you have identified. For example, if the use case is monitoring of user logins to critical resources, the event sources selected should be only those of the critical resources in question. Perhaps the LDAP directory server, Local servers, firewalls, network devices, and key applications.

Some other potential event sources by category.

Security

- Firewalls
- Endpoint Security (EDR, AV, etc.)
- Web Proxies/Gateways
- LDAP/Active Directory
- IDS
- DNS
- DHCP
- Servers
- Workstations
- Netflow

Ops

- Applications
- Network Devices
- Servers
- Packet Capture/Network Recorder
- DNS
- DHCP
- Email

DevOps

- Application Logs
- Load Balancer Logs
- Automation System Logs
- Business Logic

# Collection method
“How will you collect it?”

After a list of event sources has been determined, the next step is to decide the method of collection for each source. Although many hardware and software products support common methods such as sending log data via syslog, many do not. It is critical to understand what method each event source uses and what resources that may require. For example, if a log shipper will be required to read logs from a local file on all servers, a log shipper must be selected and tested prior to deployment. In other cases, proprietary API’s or software tools must be employed and integrated.

In some cases, changes to the event sources themselves (security devices, network hardware or applications) may be required. Additional planning is often required to deploy and maintain these collection methods over time.

Graylog supports many input types out of the box. More inputs are available in the Graylog Marketplace. At the time of writing, Graylog supports the following:

- Syslog (TCP, UDP, AMQP, Kafka)
- GELF (TCP, UDP, AMQP, Kafka, HTTP)
- AWS (AWS Logs, FlowLogs, CloudTrail)
- Beats/Logstash
- CEF (TCP, UDP, AMQP, Kafka)
- JSON Path from HTTP API
- Netflow (UDP)
- Plain/Raw Text (TCP, UDP, AMQP, Kafka)

The Graylog Marketplace (http://marketplace.graylog.org/    ) is the central directory of add-ons for Graylog. It contains plugins, content packs, GELF libraries and more content built by Graylog developers and community members.

# Users
“Who will use the solution?”

The most important user-related factor to consider is the number of users. If the number is large, or if many users will be querying the data simultaneously, you may want to take that into consideration when designing an architecture.

The users’ level of skill should be considered. Less technical users may require more pre-built content, such as dashboards. They may also require more training.

Consideration should also be paid as to what event sources each user group should have access. As in all questions of access control, the principle of least privilege should apply.

Some typical user groups include:

- Security Analysts
- Engineers
- Management
- Help Desk
- Developers

# Retention
“How long will you keep the data?”

A key question when planning your log management system is log retention. There are two ways event log data may be retained, online or archived. Online data is stored in Elasticsearch and is searchable through the Graylog GUI. Archived data is stored in a compressed format, either on the Graylog server or on a network file share. It is still searchable, via GREP for example, but must be reconstituted in Graylog in order to be searchable through the GUI again.

Some regulatory frameworks require retention of event log data for a proscribed period. In the absence of a clear requirement, the question becomes one of balancing the cost of retention (storage) versus the utility of having historical data. There is no single answer, as each situation is different.

Most Graylog customers retain 30-90 days online (searchable in Elasticsearch) and 6-13 months of archives.

- Calculating Storage Requirements
    Like most data stores, Elasticsearch reacts badly when it consumes all available storage. In order to prevent this from happening, proper planning and monitoring must be performed.

Many variables affect storage requirements, such as how much of each message is kept, whether the original message is retained once parsing is complete, and how much enrichment is done prior to storage.

   A simple rule of thumb for planning storage is to take your average daily ingestion rate, multiply it by the number of days you need to retain the data online, and then multiply that number by 1.3 to account for metadata overhead. 
   
```text
(GB/day x Ret. Days x 1.3 = storage req.)
```

Elasticsearch makes extensive use of slack storage space in the course of it’s operations. Users are strongly encouraged to exceed the minimum storage required for their calculated ingestion rate. When at maximum retention, Elasticsearch storage should not exceed 75% of total space.

# Download & Install Graylog

# Containers
Graylog supports Docker for deployment of Graylog, MongoDB and Elasticsearch. Installation and configuration instructions may be found on the [Docker installation page](docker).