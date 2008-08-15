From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [linux-pm] [PATCH 0/5] Container Freezer v6: Reuse Suspend Freezer
Date: Fri, 15 Aug 2008 14:54:42 -0700
Message-ID: <1218837282.5237.112.camel__44488.5869663723$1218837511$gmane$org@localhost.localdomain>
References: <20080811235323.872291138@us.ibm.com>
	<20080812154429.c5377bd0.akpm@linux-foundation.org>
	<Pine.WNT.4.64.0808121927320.5336@IBM-8DE7FFDE2AB>
	<20080812210859.ff2fa2f4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080812210859.ff2fa2f4.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


On Tue, 2008-08-12 at 21:08 -0700, Andrew Morton wrote:
> On Tue, 12 Aug 2008 20:47:10 -0700 (Pacific Daylight Time) Vivek Kashyap <kashyapv-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > On Tue, 12 Aug 2008, Andrew Morton wrote:
> > 
> > > On Mon, 11 Aug 2008 16:53:23 -0700
> > > Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > >
> > >> This patch series introduces a cgroup subsystem that utilizes the swsusp
> > >> freezer to freeze a group of tasks. It's immediately useful for batch job
> > >> management scripts. It should also be useful in the future for implementing
> > >> container checkpoint/restart.
> > >
> > > I don't think that this provides anything like sufficient detail to justify
> > > merging a whole bunch of stuff into Linux.
> > >
> > > What does "It's immediately useful for batch job management scripts."
> > > mean?  How is it useful?  Examples?  Why would an operator want this
> > > feature, and how would it be used?  _much_ more information is needed!
> >
> > A batch-manager/job scheduler (such as loadleveler)
> 
> what's that?
>
> > must at times stop all 
> > tasks associated with a workload being run in a container.
> 
> why?
> 
> I'm being deliberately obtuse here, but I'm afraid you guys haven't
> come anywhere into the vague nearby neighbourhood of adequately describing
> this feature.
> 
> Please provide proper and full reasons for merging this code into
> Linux.  If they exist.  This shouldn't be too hard.
> 
> Please put yourself in my position:
> 
> me: [patch] <this stuff>
> Linus: why are you sending me this?
> me: I have not the faintest idea
> 
> trust me - many others will be in my position too.

Hi Andrew,

	Sorry for being so quiet. I've been carefully considering your email
and composing what I hope is a much better description of why the code
should eventually be merged:

	The cgroup freezer is useful to batch job management system which start
and stop sets of tasks in order to schedule the resources of a machine
according to the desires of a system administrator. This sort of program
is often used on HPC clusters to schedule access to the cluster as a
whole. The cgroup freezer uses cgroups to describe the set of tasks to
be started/stopped by the batch job management system. It also provides
a means to start and stop the tasks composing the job.

	The cgroup freezer will also be useful for checkpointing running groups
of tasks. The freezer allows the checkpoint code to obtain a consistent
image of the tasks by attempting to force the tasks in a cgroup into a
quiescent state. Once the tasks are quiescent another task can
walk /proc or invoke a kernel interface to gather information about the
quiesced tasks. Checkpointed tasks can be restarted later should a
recoverable error occur. This also allows the checkpointed tasks to be
migrated between nodes in a cluster by copying the gathered information
to another node and restarting the tasks there.

	Sequences of SIGSTOP and SIGCONT are not always sufficient for stopping
and resuming tasks in userspace. Both of these signals are observable
from within the tasks we wish to freeze. While SIGSTOP cannot be caught,
blocked, or ignored it can be seen by waiting or ptracing parent tasks.
SIGCONT is especially unsuitable since it can be caught by the task. Any
programs designed to watch for SIGSTOP and SIGCONT could be broken by
attempting to use SIGSTOP and SIGCONT to stop and resume tasks. We can
demonstrate this problem using nested bash shells:

	$ echo $$
	16644
	$ bash
	$ echo $$
	16690

	From a second, unrelated bash shell:
	$ kill -SIGSTOP 16690
	$ kill -SIGCONT 16990

	<at this point 16990 exits and causes 16644 to exit too>

	This happens because bash can observe both signals and choose how it
responds to them.

	Another example of a program which catches and responds to these
signals is gdb. In fact any program designed to use ptrace is likely to
have a problem with this method of stopping and resuming tasks.

	 In contrast, the cgroup freezer uses the kernel freezer code to
prevent the freeze/unfreeze cycle from becoming visible to the tasks
being frozen. This allows the bash example above and gdb to run as
expected.

> > The workload may 
> > constitute of multiple tasks - some of which are in different sessions. 
> > A signal (STOP/CONT) to the Containers 'init' wont be transmitted to all 
> > the tasks in the Container. The 'freezer' mechanism allows this control
> > to be implemented in a clean way.
> 
> So why not implement a send-signal-to-all-tasks-in-a-container
> controller?

	I have posted such a controller to the containers list in the past. For
the reasons cited above I don't think its suitable as a replacement for
the freezer controller.

Please let me know if the reasons for merging this code remain unclear.

Cheers,
	-Matt Helsley
