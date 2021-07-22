Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4DF78173
	for <containers@lists.linux.dev>; Thu, 22 Jul 2021 08:04:48 +0000 (UTC)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.43/8.16.0.43) with SMTP id 16M7Ybfg148306;
	Thu, 22 Jul 2021 03:53:44 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ibm.com; h=to : cc : from : subject
 : message-id : date : content-type : content-transfer-encoding :
 mime-version; s=pp1; bh=Caa7KHT646SLX5TNhCX7Cf9dqEUSWEuShbv7ao6ul6g=;
 b=I0sxX/JhCEh2JRzzblXk4a6Nk3mAD+k4lmr9fGA6L+W7jOsSIYOCNkDZuAEUpZeeFKgS
 w5XcxQE98UHDsmX/xHhmyWXjd0SilDC6ShQ0gks4tIKTGuftJrODXgc9al5JzdDoi/NT
 78PGhoc9hCJl4U0xLcefsMrTtj2YHilp/VOIIZV9qzkEswKj6I5jDEZ0gcW8L/IIzdt6
 TaLEYxF0pyL4/RjPM/8hK6H4WwQXj16V5DfgCZlkQ8NGVXGU+wzY/u8O1qPfXtYqkMeL
 05FB1zskm0SKRRvG/C6JHM6g2XM59vm7tT0o9kVJKjbAA8JqaC3TFIr9L/A54hfPkqNJ xQ== 
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0b-001b2d01.pphosted.com with ESMTP id 39y3ycs4xp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 22 Jul 2021 03:53:43 -0400
Received: from m0098413.ppops.net (m0098413.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.43/8.16.0.43) with SMTP id 16M7YdW5148600;
	Thu, 22 Jul 2021 03:53:43 -0400
Received: from ppma04ams.nl.ibm.com (63.31.33a9.ip4.static.sl-reverse.com [169.51.49.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 39y3ycs4x7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 22 Jul 2021 03:53:43 -0400
Received: from pps.filterd (ppma04ams.nl.ibm.com [127.0.0.1])
	by ppma04ams.nl.ibm.com (8.16.1.2/8.16.1.2) with SMTP id 16M7r7N5025553;
	Thu, 22 Jul 2021 07:53:41 GMT
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by ppma04ams.nl.ibm.com with ESMTP id 39xhx48g4k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 22 Jul 2021 07:53:41 +0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id 16M7rdHn27132250
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 22 Jul 2021 07:53:39 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2EAE0A4060;
	Thu, 22 Jul 2021 07:53:39 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CD7DBA405B;
	Thu, 22 Jul 2021 07:53:34 +0000 (GMT)
Received: from [9.102.1.144] (unknown [9.102.1.144])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 22 Jul 2021 07:53:34 +0000 (GMT)
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        containers@lists.linux.dev, containers@lists.linux-foundation.org
Cc: legion@kernel.org, akpm@linux-foundation.org, christian.brauner@ubuntu.com,
        ebiederm@xmission.com, hannes@cmpxchg.org, mhocko@kernel.org,
        Alexey Makhalov <amakhalov@vmware.com>, llong@redhat.com,
        Pratik Sampat <psampat@linux.ibm.com>, pratik.r.sampat@gmail.com
From: Pratik Sampat <psampat@linux.ibm.com>
Subject: [RFD] Provide virtualized CPU system information for containers
Message-ID: <ac76aada-f94d-d596-9b3c-1dca5a9914d0@linux.ibm.com>
Date: Thu, 22 Jul 2021 13:23:33 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.11.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-TM-AS-GCONF: 00
X-Proofpoint-GUID: v5ZXRYAqtNhegTzdwUGvJBMLlQkc-pwk
X-Proofpoint-ORIG-GUID: V4RZQX6zRBA66QHW0D3Ovkknj18Mi9sj
Content-Transfer-Encoding: 7bit
X-Proofpoint-UnRewURL: 0 URL was un-rewritten
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.391,18.0.790
 definitions=2021-07-22_03:2021-07-22,2021-07-22 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 bulkscore=0
 priorityscore=1501 malwarescore=0 suspectscore=0 adultscore=0
 clxscore=1011 impostorscore=0 mlxscore=0 phishscore=0 spamscore=0
 mlxlogscore=999 lowpriorityscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.12.0-2104190000 definitions=main-2107220043

Abstract
========

Today, applications that run on containers enforce their CPU and memory
limits, requirements with the help of cgroups. However, many applications
legacy or otherwise get the view of the system through sysfs/procfs and
allocate resources like number of threads/processes, memory allocation based
on that information. This can lead to unexpected running behaviors as well as
have a high impact on performance.

The problem is not only limited to the coherency of information. Cloud runtime
environments requests for CPU runtime in millicores[1], which translate to
using CFS period and quota to limit CPU runtime in cgroups. However, generally,
applications operate in terms of threads with little to no cognizance of the
millicore limit or its connotation.

The scope of the RFD, along with the experimental results is anchored
towards CPU system information, rather than the challenges posed by Memory
limits information or its likes in this proposal.

Problem Statement
=================
Provide Virtualized CPU system information to applications running within
the container semantics.

Experiments
===========
Picked a relatively common container application nginx[2] configured with
"worker_processes: auto"[3] (which ensures that the number of processes to spawn
will be derived from resources viewed on the system) and a benchmark/driver
application wrk[4]

Nginx: Nginx is a web server that can also be used as a reverse proxy, load
balancer, mail proxy and HTTP cache
Wrk: wrk is a modern HTTP benchmarking tool capable of generating significant
load when run on a single multi-core CPU

Docker is used as the containerization platform of choice.

For the scope of experimentation a fake sysfs (/sys/devices/system/cpu) is
mounted which encapsulates information in coherence with the limits set to
the container.

The aim of the experiment is to quantify the effects of incoherent information
on resources allocated as well as performance

System configuration1 -- Intel
1. Intel(R) Xeon(R) CPU E5-2470
2. CPUs: 32
3. Memory: 94Gi

System configuration2 -- IBM POWER
1. IBM POWER 9
2. CPUs: 176
3. Memory: 127GB

Exp1: Effects of incorrect CPU information with cpuset
------------------------------------------------------
See [12] for detailed stats -- POWER
See [13] for detailed stats -- Intel

Case1: The container has access to all the CPUs
Case2: cpuset limits set on nginx container to only "0-3". However, the default
        sys/ and proc/ file systems display system CPUs
Case3: cpuset limits set to "0-3" and sysfs faked to give coherent information
        pertaining to only 0-3

No significant improvement or degradation in terms of performance is observed.

Summary stats -- IBM POWER
+----------------+--------+--------+--------+
| Metric         | Case 1 | Case 2 | Case 3 |
+----------------+--------+--------+--------+
| PIDs           | 177    | 177    | 5      |
| mem usg (init) | 411.1  | 290.8  | 26.69  |
| mem usg (peak) | 662.8  | 295.3  | 30.69  |
+----------------+--------+--------+--------+

Summary stats -- Intel
+----------------+--------+--------+--------+
| Metric         | Case 1 | Case 2 | Case 3 |
+----------------+--------+--------+--------+
| PIDs           | 33     | 33     | 5      |
| mem usg (init) | 28.63  | 25.37  | 5.914  |
| mem usg (peak) | 40.14  | 30.7   | 9.914  |
+----------------+--------+--------+--------+

Observations -- Both platforms show the same trend in statistics:
1. The number of PIDs in case 3 are in coherence with the cpu limit provided.
    4 worker threads + 1 Master thread, compared for the former cases where the
    number of threads spawned were based on the CPUs on the system
2. The memory footprint dropped significantly from case1 to case3 just because
    the application received a coherent view of the system

Exp2: Effects of Period and quota information
---------------------------------------------
See [14] for detailed stats -- POWER
See [15] for detailed stats -- Intel

Case1: 4 CPUs worth of runtime (period: 100000us quota: 400000 us) ,
        worker_processes: auto - No limits
Case2: 4 CPUs worth of runtime (period: 100000us quota: 400000 us) ,
        worker_processes: auto, fake sysfs to export 4 cpus - Exact CPUs
Case3: 4 CPUs worth of runtime (period: 100000us quota: 400000 us) ,
        worker_processes: auto, fake sysfs to export 8 cpus - Overcommit of CPUs
Case4: 4 CPUs worth of runtime (period: 100000us quota: 400000 us) ,
        worker_processes: auto, fake sysfs to export 8 cpus - Undercommit of CPUs

Summary statistics of the experiment -- IBM POWER:
+----------------+----------+----------+----------+----------+
| Metric         | case1    | case2    | case3    | case4    |
+----------------+----------+----------+----------+----------+
| PIDs           | 177      | 5        | 9        | 3        |
| mem usg (init) | 422.2    | 67.5     | 87.12    | 62.5     |
| mem usg (peak) | 571.4    | 130.6    | 131.6    | 85.38    |
| Throttle %     | 96.8     | 20.12    | 97.08    | 0        |
| Requests/sec   | 18849.97 | 66356.02 | 61121.65 | 35265.99 |
| Transfer/sec   | 15.28    | 53.79    | 49.54    | 28.59    |
+----------------+----------+----------+----------+----------+

Summary statistics of the experiment -- Intel:
+----------------+----------+----------+----------+----------+
| Metric         | case1    | case2    | case3    | case4    |
+----------------+----------+----------+----------+----------+
| PIDs           | 33       | 5        | 9        | 3        |
| mem usg (init) | 29.12    | 7.574    | 10.83    | 6.07     |
| mem usg (peak) | 37.78    | 16.34    | 18.59    | 12.69    |
| Throttle %     | 97.4     | 19.80    | 97.4     | 0        |
| Requests/sec   | 32778.57 | 44754.85 | 42296.64 | 22500.00 |
| Transfer/sec   | 26.57    | 36.28    | 34.28    | 18.24    |
+----------------+----------+----------+----------+----------+

Obervations -- Both platforms show the same trend in statistics:
When the CPU quota limit is set to run for the duration of 4 CPUs and,
Case1: Nginx spawns processes based on the view of the system then there is a
        high amount of throttling, high memory footprint as well as low
        performance
Case2: A fake sysfs is mounted to display 4 cpus, when period and quota
        reflects 4 cpus worth of runtime then the throttling is the lowest as
        well as the performance is the highest.
        Also, memory footprint is seen to improve.
Case3: A fake sysfs is mounted to display 8 cpus i.e overcommit, then
        throttling is seen to increase, while the throttle time is lesser
        than case1, the throttle % is the same. Performance also drops as well
        as higher memory footprint can be seen when compared to case 2 but
        less than case 1
Case4: A fake sysfs is mounted to display 2 cpus i.e undercommit, There is
        virtually no throttling to be observed as there is no contention.
        The memory footprint is also the lowest, however the performance takes
        a dip too and is the worst of all the cases

The above experiments show us that there is merit for applications observing
coherent information in terms of tasks spawned, memory footprint and
performance.

Existing solutions
==================

1. Why don't current applications look at the cgroupfs interface instead of the
    old sys and procfs if they need coherent information?

Most of the information that applications seek from the traditional
filesystems is correctly populated in the cgroupfs and that applications
should modify their libraries to receive coherent information from there. This
is a strong argument and cannot be discounted, however it does present two
problems along with it.
a. There are a lot of applications that currently use the traditional
    interface which can be range from legacy applications as well relatively
    modern applications like nginx as we have seen. Therefore, the sheer volume
    of applications and their libraries may make it difficult to implement this
    currently.
b. Applications which previously didn't know the concept of millicores would
    now have to incorporate that into their business logic for their thread
    requirements as well by deriving and interpreting this information from CFS
    period and quota

2. Userspace tools like LXCFS[5]
In the experiment above, to give a coherent view of the system we mounted
fake sysfs directories, which is precisely the modus operandi of LXFCS.
LXCFS is a userspace tools which uses FUSE filesystem to provide coherency of
information and mount cgroupfs based information in sys, procfs like:

/proc/cpuinfo
/proc/diskstats
/proc/meminfo
/proc/stat
/proc/swaps
/proc/uptime
/proc/slabinfo
/sys/devices/system/cpu/*
/sys/devices/system/cpu/online

It is also capable to virtualize period and quota information with --enable-cfs
option[6]. It divides period by quota and the resulting number of CPUs "N" is
presented in /sys/devices/system/cpu/online as "0-N".

The benefit of LXCFS is that it is a light, relatively easy to setup userspace
tool which can be used by applications to get coherent information presented
from cgroupfs to sysfs. It does seem to be currently in use with
Kubenetes as described by Google Anthos[7] and the Alibab Cloud tutorial[8]

However, it does pose a couple of concerns too:
a. From a CPU point of view, when it comes to virtualizing of CPUs based on
    periods and quotas will always lead to list of CPUs starting from 0 to N,
    where N is the translation of number of CPUs it should get a runtime of.
    The question aries if this can become an issue where the applications
    depend of the CPU list itself, that it is task-setting or setting affinity
    to those CPUs?
    If that is possible, then in that case where there are multiple
    container applications running with the same taskset CPUset; can experience
    unwarranted throttling.
b. LXCFS is an external solution that needs to be explicitly setup for
    applications that experience problems from incorrect information
    in sys/procfs

Hence, I believe an argument can be made to have an in-kernel interface that
can virtualize CPU information and namespace each logical container into its
own view of the CPU topology.

3. Introduce a new interface to present information in-kernel
A patchset was suggested[9] which added /proc/self/meminfo which contained a
subset of /proc/meminfo respecting cgroup restrictions for the memory
incoherence problem.

This design can also be ported for the CPU view of the system too.
The advantage of this approach is that a new interface is setup
without overriding the current interfaces which enables us to not break any
assumptions already established on those sys and procfs interface.

However, this could turn out to be a potential disadvantage too.
As there can be two kinds of applications that the solution is currently
designed for:
a. Legacy applications
b. Newer applications that still look at traditional interfaces
For both a.) and b.) if they do not currently look at the cgroupfs interfaces;
then introduction of yet another interface may not be motivating enough to
modify their codebase to receive this information.
This argument was also presented by Christian Brauner in the same patchset[10],
while also highlighting overlapping points presented from this proposal.

Honorable mention: Kubenetes CPU manager[11]. The CPU manager is a feature for
QoS in container orchestration, here the CPU manager manages the cpuset given
exclusively to pods based on the requests of CPUs in its configuration.
While it is a nifty feature to manage cpuset information, it still does not
reflect this information in traditional sys/procfs interfaces and a LXCFS hook
is needed along with it for the same.

Proposed Solution -> CPU namespace
==================================

This RFD proposes the inclusion of a new namespace feature - CPU namespace.
A CPU namespace can present coherent system CPU information to the contain
applications that reside within it in accordance with the cgroups limits set
onto it. The namespace also virtualizes CPU information and can maintain an
internal translation from the namespace CPU to the logical CPU in the kernel.

Designing a namespace this way presents a coherent interface as well as is able
to cleanly abstract details about the system and it's configuration from the
higher level applications.
The advantage of this approach is also that this can be acheived without the
introduction of a new interface and by just reimagining the interpretation of
the existing sys and proc interfaces.

On the lines of namespaces, an alternative namespace that could also be
proposed is a sys/proc namespace that can virtualize information presented from
cgroupfs. It could be CPUs, memory, even other system topology. This would
resolve memory limits inconsistency issues as reported in [9]. However,
presenting CPU information this way does pose a challenge. There are metrics
like period and quota as discussed earlier which need to be derived to present
as CPUs as well as needs to be abstracted out. If a coherent interpretation of
these derived metrics can be agreed upon then the following could also be a
viable alternative.

The aim of the above proposal is to:
a. Garner perspective from the community around the problem, its implications
    in the real world and the cementing a consensus if there is a need to
    solving it
b. Spark a discussion around a potential solution

If a consensus can be reached, first towards acceptance of the problem and then
towards a coherent CPU namespace mechanism; I would gladly volunteer to help
in building it out.

Thanks,
Pratik Sampat
IBM, Linux Technology Center

[1]: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
[2]: https://docs.nginx.com/nginx/
[3]: http://nginx.org/en/docs/ngx_core_module.html#worker_processes
[4]: https://github.com/wg/wrk
[5]: https://linuxcontainers.org/lxcfs/
[6]: https://www.mankier.com/1/lxcfs#--enable-cfs
[7]: https://cloud.google.com/blog/products/containers-kubernetes/migrate-for-anthos-streamlines-legacy-java-app-modernization
[8]: https://www.alibabacloud.com/blog/kubernetes-demystified-using-lxcfs-to-improve-container-resource-visibility_594109
[9]: https://lore.kernel.org/lkml/ac070cd90c0d45b7a554366f235262fa5c566435.1622716926.git.legion@kernel.org/
[10]: https://lore.kernel.org/lkml/20210615113222.edzkaqfvrris4nth@wittgenstein/
[11]: https://kubernetes.io/blog/2018/07/24/feature-highlight-cpu-manager/
[12]: POWER - EXP1: Effects of incorrect CPU information with cpuset
     Case1: The container has access to all the CPUs (0-175)

     IDLE container stat
     NAME   CPU %      MEM USAGE / LIMIT   MEM %  NET I/O      BLOCK I/O    PIDS
     pnginx 0.00%      411.1MiB / 127.5GiB 0.31%  2.29kB / 0B  0B / 8.19kB  177
     PEAK WORKLOAD
     pnginx 14383.42%  662.8MiB / 127.5GiB 0.51% 389MB / 2.11GB 0B / 8.19kB  177


     Case2: cpuset limits set on nginx container to only "0-3". However the
            default sys/ and proc/ file systems display 176 CPUs.

     IDLE container stat
     NAME    CPU %    MEM USAGE / LIMIT    MEM %  NET I/O       BLOCK I/O    PIDS
     pnginx  0.00%    290.8MiB / 127.5GiB  0.22%  2.29kB / 0B   0B / 8.19kB  177
     PEAK WORKLOAD
     pnginx  399.21%  295.3MiB / 127.5GiB  0.23%  197MB / 1.1GB 0B / 8.19kB  177


     Case3: cpuset limits set to "0-3" and sysfs faked to give coherent
            information pertaining to only 0-3

     IDLE container stat
     NAME    CPU %    MEM USAGE / LIMIT    MEM %  NET I/O         BLOCK I/O    PIDS
     pnginx  0.00%    26.69MiB / 127.5GiB  0.02%  2.22kB / 0B     0B / 8.19kB  5
     PEAK WORKLOAD
     pnginx  399.24%  30.69MiB / 127.5GiB  0.02%  183MB / 1.03GB  0B / 8.19kB  5

[13]: Intel - EXP1: Effects of incorrect CPU information with cpuset
     Case1: The container has access to all the CPUs (0-31)

     IDLE container stat
     NAME  CPU %  MEM USAGE / LIMIT   MEM %   NET I/O       BLOCK I/O     PIDS
     pnginx 0.00% 28.63MiB / 94.38GiB 0.03%   1.54kB / 0B   69.6kB / 8.19kB   33
     PEAK WORKLOAD
     pnginx 1562.51% 40.14MiB / 94.38GiB   0.04% 765MB / 4.08GB  0B / 8.19kB  33


     Case2: cpuset limits set on nginx container to only "0-3". However the
            default sys/ and proc/ file systems display 32 CPUs.

     IDLE container stat
     NAME   CPU %  MEM USAGE / LIMIT   MEM %   NET I/O       BLOCK I/O     PIDS
     pnginx 0.00%  25.37MiB / 94.38GiB   0.03%  2.01kB / 0B   0B / 8.19kB   33
     PEAK WORKLOAD
     pnginx 406.82% 30.7MiB / 94.38GiB   0.03%  243MB / 1.36GB  0B / 8.19kB  33

     Case3: cpuset limits set to "0-3" and sysfs faked to give coherent
            information pertaining to only 0-3

     IDLE container stat
     NAME   CPU %  MEM USAGE / LIMIT   MEM %   NET I/O       BLOCK I/O     PIDS
     pnginx 0.00%  5.914MiB / 94.38GiB 0.01%   2.08kB / 0B   0B / 8.19kB   5
     PEAK WORKLOAD
     pnginx 406.04% 9.914MiB / 94.38GiB  0.01%  251MB / 1.41GB  0B / 8.19kB  5

[14]: POWER - Exp2: Effects of Period and quota information
     Case1: 4 CPUs worth of runtime (period: 100000us quota: 400000 us) ,
            worker_processes: auto - No limits
     Inital nginx stats
     --docker stats--
     NAME    CPU %  MEM USAGE / LIMIT    MEM %  NET I/O      BLOCK I/O    PIDS
     pnginx  0.00%  422.2MiB / 127.5GiB  0.32%  2.36kB / 0B  0B / 8.19kB  177
     --throttle stats--
     nr_periods 7
     nr_throttled 0
     throttled_time 0

     Peak workload nginx stats
     --docker stats--
     NAME    CPU %    MEM USAGE / LIMIT    MEM %  NET I/O        BLOCK I/O    PIDS
     pnginx  391.18%  571.4MiB / 127.5GiB  0.44%  101MB / 561MB  0B / 8.19kB  177
     --throttle stats--
     nr_periods 313
     nr_throttled 303
     throttled_time 2168846281268

     Benchmark stats
     # ./wrk -t4 -c500 --latency -d30s http://172.17.0.2:80/index.html
     Running 30s test @ http://172.17.0.2:80/index.html
     4 threads and 500 connections
     Thread Stats   Avg      Stdev     Max   +/- Stdev
     Latency    59.17ms   89.55ms   1.19s    88.62%
     Req/Sec     4.75k     4.03k   27.79k    74.00%
     567045 requests in 30.08s, 459.63MB read
     Requests/sec:  18849.97
     Transfer/sec:     15.28MB

     Case2: 4 CPUs worth of runtime (period: 100000us quota: 400000 us) ,
            worker_processes: auto, fake sysfs to export 4 cpus - Exact CPUs

     Inital nginx stats
     --docker stats--
     NAME    CPU %  MEM USAGE / LIMIT   MEM %  NET I/O      BLOCK I/O    PIDS
     pnginx  0.00%  67.5MiB / 127.5GiB  0.05%  2.29kB / 0B  0B / 8.19kB  5
     --throttle stats--
     nr_periods 5
     nr_throttled 0
     throttled_time 0

     Peak workload nginx stats
     --docker stats--
     NAME    CPU %    MEM USAGE / LIMIT    MEM %  NET I/O        BLOCK I/O    PIDS
     pnginx  398.36%  130.6MiB / 127.5GiB  0.10%  337MB / 1.9GB  0B / 8.19kB  5
     --throttle stats--
     nr_periods 308
     nr_throttled 62
     throttled_time 375890674

     Benchmark stats
     # ./wrk -t4 -c500 --latency -d30s http://172.17.0.2:80/index.html
     Running 30s test @ http://172.17.0.2:80/index.html
       4 threads and 500 connections
       Thread Stats   Avg      Stdev     Max   +/- Stdev
         Latency    17.57ms   32.08ms 341.08ms   89.20%
         Req/Sec    16.71k     1.26k   24.71k    78.17%
       1996404 requests in 30.09s, 1.58GB read
     Requests/sec:  66356.02
     Transfer/sec:     53.79MB

     Case3: 4 CPUs worth of runtime (period: 100000us quota: 400000 us) ,
            worker_processes: auto, fake sysfs to export 8 cpus - Overcommit of CPUs
     Inital nginx stats
     --docker stats--
     NAME    CPU %  MEM USAGE / LIMIT    MEM %  NET I/O      BLOCK I/O    PIDS
     pnginx  0.00%  87.12MiB / 127.5GiB  0.07%  2.36kB / 0B  0B / 8.19kB  9
     --throttle stats--
     nr_periods 5
     nr_throttled 0
     throttled_time 0

     Peak workload nginx stats
     --docker stats--
     NAME    CPU %    MEM USAGE / LIMIT    MEM %  NET I/O        BLOCK I/O    PIDS
     pnginx  401.48%  131.6MiB / 127.5GiB  0.10%  300MB / 1.7GB  0B / 8.19kB  9
     --throttle stats--
     nr_periods 309
     nr_throttled 300
     throttled_time 119159115734

     Benchmark stats
     # ./wrk -t4 -c500 --latency -d30s http://172.17.0.2:80/index.html
     Running 30s test @ http://172.17.0.2:80/index.html
       4 threads and 500 connections
       Thread Stats   Avg      Stdev     Max   +/- Stdev
         Latency    14.39ms   16.52ms 151.55ms   81.31%
         Req/Sec    15.39k     0.91k   30.95k    90.08%
       1838179 requests in 30.07s, 1.46GB read
     Requests/sec:  61121.65
     Transfer/sec:     49.54MB

     Case4: 4 CPUs worth of runtime (period: 100000us quota: 400000 us) ,
            worker_processes: auto, fake sysfs to export 2 cpus - Undercommit of CPUs

     Inital nginx stats
     --docker stats--
     NAME    CPU %  MEM USAGE / LIMIT   MEM %  NET I/O      BLOCK I/O    PIDS
     pnginx  0.00%  62.5MiB / 127.5GiB  0.05%  2.29kB / 0B  0B / 8.19kB  3
     --throttle stats--
     nr_periods 5
     nr_throttled 0
     throttled_time 0

     Peak workload nginx stats
     --docker stats--
     NAME    CPU %    MEM USAGE / LIMIT    MEM %  NET I/O        BLOCK I/O    PIDS
     pnginx  199.47%  85.38MiB / 127.5GiB  0.07%  170MB / 963MB  0B / 8.19kB  3
     --throttle stats--
     nr_periods 308
     nr_throttled 0
     throttled_time 0

     Benchmark stats
     # ./wrk -t4 -c500 --latency -d30s http://172.17.0.2:80/index.html
     Running 30s test @ http://172.17.0.2:80/index.html
       4 threads and 500 connections
       Thread Stats   Avg      Stdev     Max   +/- Stdev
         Latency   159.81ms  251.64ms   1.05s    81.16%
         Req/Sec     8.88k     1.89k   15.59k    71.00%
       1060592 requests in 30.07s, 859.69MB read
     Requests/sec:  35265.99
     Transfer/sec:     28.59MB

[15]: Intel - Exp2: Effects of Period and quota information
     Case1: 4 CPUs worth of runtime (period: 100000us quota: 400000 us) ,
            worker_processes: auto - No limits

     Inital nginx stats
     --docker stats--
     NAME   CPU %  MEM USAGE / LIMIT    MEM %  NET I/O      BLOCK I/O        PIDS
     pnginx 0.00%  29.12MiB / 94.38GiB  0.03%  1.74kB / 0B  2.26MB / 8.19kB  33
     --throttle stats--
     nr_periods 5
     nr_throttled 0
     throttled_time 0

     Peak workload nginx stats
     --docker stats--
     NAME    CPU %    MEM USAGE / LIMIT     MEM %     NET I/O         BLOCK I/O         PIDS
     pnginx  403.43%  37.78MiB / 94.38GiB   0.04%     184MB / 912MB   2.26MB / 8.19kB   33
     --throttle stats--
     nr_periods 309
     nr_throttled 301
     throttled_time 506059002784

     Benchmark stats
     # ./wrk -t4 -c500 --latency -d30s http://172.17.0.4:80/index.html
     Running 30s test @ http://172.17.0.4:80/index.html
     4 threads and 500 connections
     Thread Stats   Avg      Stdev     Max   +/- Stdev
         Latency    26.10ms   31.45ms 189.88ms   79.53%
         Req/Sec     8.25k     1.67k   22.62k    79.92%
     985441 requests in 30.06s, 798.78MB read
     Requests/sec:  32778.57
     Transfer/sec:     26.57MB

     Case2: 4 CPUs worth of runtime (period: 100000us quota: 400000 us) ,
            worker_processes: auto, fake sysfs to export 4 cpus - Exact CPUs

     Inital nginx stats
     --docker stats--
     NAME    CPU %    MEM USAGE / LIMIT     MEM %     NET I/O       BLOCK I/O         PIDS
     pnginx  0.00%    7.574MiB / 94.38GiB   0.01%     2.01kB / 0B   90.1kB / 8.19kB   5
     --throttle stats--
     nr_periods 5
     nr_throttled 0
     throttled_time 0

     Peak workload nginx stats
     --docker stats--
     NAME    CPU %    MEM USAGE / LIMIT     MEM %     NET I/O          BLOCK I/O         PIDS
     pnginx  408.06%  16.34MiB / 94.38GiB   0.02%     227MB / 1.28GB   90.1kB / 8.19kB   5
     --throttle stats--
     nr_periods 308
     nr_throttled 61
     throttled_time 100989735

     Benchmark stats
     # ./wrk -t4 -c500 --latency -d30s http://172.17.0.4:80/index.html
     Running 30s test @ http://172.17.0.4:80/index.html
     4 threads and 500 connections
     Thread Stats   Avg      Stdev     Max   +/- Stdev
         Latency    26.47ms   48.54ms 448.54ms   89.32%
         Req/Sec    11.26k   844.04    14.61k    68.67%
     1344115 requests in 30.03s, 1.06GB read
     Requests/sec:  44754.85
     Transfer/sec:     36.28MB

     Case3: 4 CPUs worth of runtime (period: 100000us quota: 400000 us) ,
            worker_processes: auto, fake sysfs to export 8 cpus - Overcommit of CPUs
     Inital nginx stats
     --docker stats--
     NAME    CPU %    MEM USAGE / LIMIT     MEM %     NET I/O       BLOCK I/O     PIDS
     pnginx  0.00%    10.83MiB / 94.38GiB   0.01%     2.01kB / 0B   0B / 8.19kB   9
     --throttle stats--
     nr_periods 6
     nr_throttled 0
     throttled_time 0

     Peak workload nginx stats
     --docker stats--
     NAME    CPU %    MEM USAGE / LIMIT     MEM %     NET I/O          BLOCK I/O     PIDS
     pnginx  403.62%  18.59MiB / 94.38GiB   0.02%     236MB / 1.23GB   0B / 8.19kB   9
     --throttle stats--
     nr_periods 308
     nr_throttled 300
     throttled_time 11847978641

     Benchmark stats
     # ./wrk -t4 -c500 --latency -d30s http://172.17.0.4:80/index.html
     Running 30s test @ http://172.17.0.4:80/index.html
     4 threads and 500 connections
     Thread Stats   Avg      Stdev     Max   +/- Stdev
         Latency    17.52ms   18.08ms 176.48ms   81.30%
         Req/Sec    10.64k   692.48    19.12k    80.50%
     1270019 requests in 30.03s, 1.01GB read
     Requests/sec:  42296.64
     Transfer/sec:     34.28MB

     Case4: 4 CPUs worth of runtime (period: 100000us quota: 400000 us) ,
            worker_processes: auto, fake sysfs to export 2 cpus - Undercommit of CPUs

     Inital nginx stats
     --docker stats--
     NAME    CPU %    MEM USAGE / LIMIT    MEM %     NET I/O       BLOCK I/O     PIDS
     pnginx  0.00%    6.07MiB / 94.38GiB   0.01%     2.15kB / 0B   0B / 8.19kB   3
     --throttle stats--
     nr_periods 6
     nr_throttled 0
     throttled_time 0

     Peak workload nginx stats
     --docker stats--
     NAME    CPU %    MEM USAGE / LIMIT     MEM %     NET I/O         BLOCK I/O     PIDS
     pnginx  202.32%  12.69MiB / 94.38GiB   0.01%     126MB / 681MB   0B / 8.19kB   3
     --throttle stats--
     nr_periods 308
     nr_throttled 0
     throttled_time 0

     Benchmark stats
     # ./wrk -t4 -c500 --latency -d30s http://172.17.0.4:80/index.html
     Running 30s test @ http://172.17.0.4:80/index.html
     4 threads and 500 connections
     Thread Stats   Avg      Stdev     Max   +/- Stdev
         Latency   237.39ms  385.12ms   1.49s    81.66%
         Req/Sec     5.66k     1.24k    8.34k    63.42%
     676025 requests in 30.05s, 547.97MB read
     Requests/sec:  22500.00
     Transfer/sec:     18.24MB

