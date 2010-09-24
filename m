From: Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 00/10] taskstats: Enhancements for precise accounting
Date: Fri, 24 Sep 2010 11:10:15 +0200
Message-ID: <1285319415.2179.116.camel__34785.9679292471$1285319480$gmane$org@holzheu-laptop>
References: <1285249681.1837.28.camel@holzheu-laptop>
	<20100923131136.356075f4.akpm@linux-foundation.org>
Reply-To: holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100923131136.356075f4.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Shailabh Nagar <nagar1234-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Venkatesh Pallipadi <venki-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, John stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Suresh Siddha <suresh.b.siddha-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello Andrew,

On Thu, 2010-09-23 at 13:11 -0700, Andrew Morton wrote:
> > GOALS OF THIS PATCH SET
> > -----------------------
> > The intention of this patch set is to provide better support for tools like
> > top. The goal is to:
> > 
> > * provide a task snapshot mechanism where we can get a consistent view of
> >   all running tasks.
> > * provide a transport mechanism that does not require a lot of system calls
> >   and that allows implementing low CPU overhead task monitoring.
> > * provide microsecond CPU time granularity.
> 
> This is a big change!  If this is done right then we're heading in the
> direction of deprecating the longstanding way in which userspace
> observes the state of Linux processes and we're recommending that the
> whole world migrate to taskstats.  I think?

Or it can be used as alternative. Since procfs has its drawbacks (e.g.
performance) an alternative could be helpful. 

And the taskstats interface with the TASKSTATS_CMD_ATTR_PID command
already exists and can be used. So we already have a second mechanism to
query tasks accounting information besides of procfs.

> 
> If so, much chin-scratching will be needed, coordination with
> util-linux people, etc.

I agree.

> We'd need to think about the implications of taskstats versioning.  It
> _is_ a versioned interface, so people can't just go and toss random new
> stuff in there at will - it's not like adding a new procfs file, or
> adding a new line to an existing one.  I don't know if that's likely to
> be a significant problem.

I already thought about that problem. Another problem is that depending
on the kernel config options, some taskstats fields may be not
initialized. E.g. CONFIG_TASK_DELAY_ACCT or CONFIG_TASK_XACCT. Currently
there does not exist a good interface to userspace to query which fields
are valid.

Regarding the taskstats versions  I described a possible solution in the
userspace tarball in the README.libtaskstats file:

The "struct taskstats" structure contains accounting information for one
Linux task. This structure is defined in "/usr/include/linux/taskstats.h".
With new kernel versions new fields can be added to that structure.
In that case the kernel taskstats version number defined with the macro
TASKSTATS_VERSION will be increased.

The taskstats library distinguishes between two taskstats versions:
* Kernel taskstats version (KV)
* Program compile taskstats version (CV)

Depending on the taskstats version CV that is used for compiling the program,
this version numbers can be different:
* KV > CV:
  The libtaskstats library only copies the CV taskstats fields and the fields
  that belong to version > CV will be ignored.
* KV < CV:
  The libtaskstats library only copies the version KV fields and the fields
  that belong to version > KV remain uninitialized.

If a program wants to support multiple taskstats versions, this can be done
using the ts_version() function and process fields according to that version
number.

Example:

  if (ts_version() < 7) {
         fprintf(stderr, "Error: kernel taskstats version too low\n");
         exit(1);
  }
  if (ts_version() >= 7)
         print_attrs_v7();
  if (ts_version() >= 8)
         print_attrs_v8();

In this example the program has to be compiled with a taskstats.h header file
that has at least version 8.

> I worry that there's a dependency on CONFIG_NET?  If so then that's a
> big problem because in N years time, 99% of the world will be using
> taskstats, but a few embedded losers will be stuck using (and having to
> support) the old tools.

Sure, but if we could add the /proc/taskstats approach, this dependency
would not be there.

> 
> > FIRST RESULTS
> > -------------
> > Together with this kernel patch set also user space code for a new top
> > utility (ptop) is provided that exploits the new kernel infrastructure. See
> > patch 10 for more details.
> > 
> > TEST1: System with many sleeping tasks
> > 
> >   for ((i=0; i < 1000; i++))
> >   do
> >          sleep 1000000 &
> >   done
> > 
> >   # ptop_new_proc
> > 
> >              VVVV
> >   pid   user  sys  ste  total  Name
> >   (#)    (%)  (%)  (%)    (%)  (str)
> >   541   0.37 2.39 0.10   2.87  top
> >   3743  0.03 0.05 0.00   0.07  ptop_new_proc
> >              ^^^^
> > 
> > Compared to the old top command that has to scan more than 1000 proc
> > directories the new ptop consumes much less CPU time (0.05% system time
> > on my s390 system).
> 
> How many CPUs does that system have?

The system is a virtual machine and has three CPUs.

> What's the `top' update period?  One second?

The update period is two seconds.

> So we're saying that a `top -d 1' consumes 2.4% of this
> mystery-number-of-CPUs machine?  That's quite a lot.

When I run that testcase on my laptop, 2 CPUs (Intel Core 2 - 2.33GHz),
I get about 1-2% system time for top.

> > PATCHSET OVERVIEW
> > -----------------
> > The code is not final and still has a few TODOs. But it is good enough for a
> > first round of review. The following kernel patches are provided:
> > 
> > [01] Prepare-0: Use real microsecond granularity for taskstats CPU times.
> > [02] Prepare-1: Restructure taskstats.c in order to be able to add new commands
> >      more easily.
> > [03] Prepare-2: Separate the finding of a task_struct by PID or TGID from
> >      filling the taskstats.
> > [04] Add new command "TASKSTATS_CMD_ATTR_PIDS" to get a snapshot of multiple
> >      tasks.
> > [05] Add procfs interface for taskstats commands. This allows to get a complete
> >      and consistent snapshot with all tasks using two system calls (ioctl and
> >      read). Transferring a snapshot of all running tasks is not possible using
> >      the existing netlink interface, because there we have the socket buffer
> >      size as restricting factor.
> 
> So this is a binary interface which uses an ioctl.  People don't like
> ioctls.  Could we have triggered it with a write() instead?

The current idea is the following:

1. Open /proc/taskstats
2. Set the requested command (e.g. TASKSTATS_CMD_ATTR_PIDS) using
   an ioctl. For the TASKSTATS_CMD_ATTR_PIDS ioctl the following
   structure is sent:

   struct taskstats_cmd_pids {
        __u64   time_ns;
        __u32   pid;
        __u32   cnt;
   };

3. After the command is defined, with a read() the command is executed
   and the result is returned to the user's read buffer.

We could replace step 2 with a write, that transfers the command.

> Does this have the potential to save us from the CONFIG_NET=n problem?

Yes

> > [06] Add TGID to taskstats.
> > [07] Add steal time per task accounting.
> > [08] Add cumulative CPU time (user, system and steal) to taskstats.
> 
> These didn't update the taskstats version number.  Should they have?

Patch 04/10 updates the taskstats version number from 7 to 8.
I didn't want to update the version number with each patch.

> > [09] Fix exit CPU time accounting.
> > 
> > [10] Besides of the kernel patches also user space code is provided that
> >      exploits the new kernel infrastructure. The user space code provides the
> >      following:
> >      1. A proposal for a taskstats user space library:
> >         1.1 Based on netlink (requires libnl-devel-1.1-5)
> >         2.1 Based on the new /proc/taskstats interface (see [05])
> >      2. A proposal for a task snapshot library based on taskstats library (1.1)
> 
> ooh, excellent.  A standardised userspace access library.

Yes, at least a proposal for that.

> >      3. A new tool "ptop" (precise top) that uses the libraries
> 
> Talk to me about namespaces, please.  A lot of the new code involves
> PIDs, but PIDs are not system-wide unique.  A PID is relative to a PID
> namespace.  Does everything Just Work?  When userspace sends a PID to
> the kernel, that PID is assumed to be within the sending process's PID
> namespace?  If so, then please spell it all out in the changelogs.  If
> not then that is a problem!

To be honest, I have not tested that. I assumed that the current
taskstats code does this correctly. E.g. it uses find_task_by_vpid() for
TASKSTATS_CMD_ATTR_PID and this function uses
"current->nsproxy->pid_ns". So I would assume that we get only tasks
from the caller's namespace. The new TASKSTATS_CMD_ATTR_PIDS command
also uses also only functions with "current->nsproxy->pid_ns".

> If I can only observe processes in my PID namespace then is that a
> problem?  Should I be allowed to observe another PID namespace's
> processes?  I assume so, because I might be root.  If so, how is that
> to be done?

Good question. Probably I have to learn a bit more about the PID
namespace implementation. Are PIDs over all namespaces unique?

Michael
