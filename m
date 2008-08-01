From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Control groups and Resource Management notes (part I)
Date: Fri, 01 Aug 2008 19:24:58 +0530
Message-ID: <489315B2.2080506@linux.vnet.ibm.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, All,

This is the first part of the resource management and control groups discussion.
I might have made mistakes while taking notes or typing them out, please feel
free to correct them for me or send me corrections.

The notes are really large, so they'll come in installments. This is the first
part of the notes.

Control Groups
==============

1. Multiphase locking - Paul brought up his multi phase locking design and
suggested approaches to implementing them. The problem with control groups
currently is that transactions cannot be atomically committed. If some
transactions fail (can_attach() callback fails or returns error), then there is
no notification sent out to groups that already committed the transaction

The suggested design includes
	- Acquiring locks across callbacks - Balbir opposed this approach
          stating that this would make it easier for subsystems to deadlock.
          Balbir instead suggested that each callback hold it's own lock and
          add an undo operation that cannot fail (returns void), since
          uncharging usually succeeds. Dave suggested doing undo without holding
          any locks.

2. Procs - Balbir and others have asked for an API to move all threads of a
process in one go from one control group to another. The question about doing it
in user space was asked. Doing it in user space is easy, but it can be expensive
(moving all threads one by one - acquiring the cgroup lock and releasing it for
every thread). What happens if another move is requested while a partial move is
in progress? Dave suggested that we have an abstract aggregation so that we
don't need to keep adding interfaces for every aggregation. Balbir mentioned
that the aggregation of interest are process, process groups and sessions and
the kernel already knows about these (there are data structures to link all
elements together). Abstracting it is a good idea, but hard to implement.

Paul asked what the behaviour should be, if a process being moved has several
threads belong to different cgroups. The answer that came up was that they
should all be migrated to the destination cgroup

3. Cgroup lock - The cgroup lock is held at various places in the system. The
question is -- is cgroup_lock() becoming the next BKL? Several solutions were
discussed - making the lock per hierarchy or per cgroup or use subsystem locks.
Paul mentioned that cgroups already use RCU.

4. Binary statistics - The question about binary statistics was raised. Since
control groups don't enforce any particular kind of API, is there a way to
generically handle control files and their parameters in the library? Paul
suggested his binary API approach, where every control group and it's API is
documented in an api file. Eric suggested using an ASCII interface (since that
is very generic) and using one file per API. Balbir mentioned that this will
lead to too many dentries and issues related to having extensive number of dentries.

5. User space notifications - Kamezawa had requested for user space notification
(through inotify) when a control group reaches it's memory limit for example.
The questions that were asked were, what happens if no one is listening in on
notifications? Denis suggested using a FIFO mechanism. Balbir suggested using
netlinks and building stuff on top of cgroupstats. With netlink we can pass
type, value and length of arguments, making it more suitable for this kind of
information exchange. The only concern with netlink is that it can lose
messages. The general consensus was to add one FIFO per control group and use
that for all notifications related to the control group.

Resource management
===================
1. Memory controller - Balbir mentioned that this is best discussed at the
memory controller BoF
2. Device subsystem was discussed and it was decided that mount (filesystem)
namespace and device namespace are the best places to handle device subsystem
issues.
3. Memrlimit - Balbir discussed the memrlimit controller. Dave and Paul are
opposed to doing any limits based on virtual address space. Balbir mentioned
that it serves several purposes

a. It allows us to control swap usage
b. It allows us to build a generic rlimits infrastructure
c. It allows us to fail applications nicely

Paul mentioned that (c) was not useful since no applications handle it today.
Balbir disagreed with that argument as being sufficient to prevent future
applications to handle malloc()/mmap() failure. Balbir asked why overcommit
accounting was not useful?

There was general agreement that a mlock() controller would be useful.

4. CPU controller - There was a request for hard limit feature. Peter opposed
the approach stating that anyone wanting hard limits should use the real time
group scheduler and a new EDF scheduler is being implemented. Denis mentioned
that without hard limits it is not possible for a service provider to
decide/plan how much capacity a single CPU can provide. Balbir mentioned that
with hard limits and SLA's the service provider could on reaching the hard limit
can save power by hard limiting execution on a CPU that is meeting its SLA
requirements. Peter mentioned that hard limits would make the group scheduler,
non work conserving.

Peter also updated everyone about the new load balancing patches that will make
it into the next merge window.

5. Kernel memory controller - The kernel memory controller was discussed
briefly. Pavel has not been actively working on it. Denis mentioned that it
would be nice to have a network buffer controller as well. Questions were asked
if the kernel memory controller should be merged with the existing memory
controller?

6. Swap subsystem - Daisuke mentioned that the swap subsystem works well for
fundamental operations and that he posted a version of the patch three weeks
ago. The patch controls swap entries to control the swap usage of a control
group. Paul mentioned that google has a patch internally to link swap files to
cpusets. Balbir asked Serge about his swap namespace patches. The swap namespace
is a different issue all together (compared to the swap controller). Currently
the swap controller is a part of the memory controller. There has been some
discussion about it being an independent controller.



-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
