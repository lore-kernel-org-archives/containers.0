From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH v8 0/3] cgroups: implement moving a threadgroup's
	threads atomically with cgroup.procs
Date: Wed, 9 Feb 2011 15:10:46 -0800
Message-ID: <20110209151046.89e03dcd.akpm__40361.1357477077$1297293181$gmane$org@linux-foundation.org>
References: <20101226120919.GA28529@ghc17.ghc.andrew.cmu.edu>
	<20110208013542.GC31569@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110208013542.GC31569-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 7 Feb 2011 20:35:42 -0500
Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:

> On Sun, Dec 26, 2010 at 07:09:19AM -0500, Ben Blum wrote:
> > On Fri, Dec 24, 2010 at 03:22:26AM -0500, Ben Blum wrote:
> > > On Wed, Aug 11, 2010 at 01:46:04AM -0400, Ben Blum wrote:
> > > > On Fri, Jul 30, 2010 at 07:56:49PM -0400, Ben Blum wrote:
> > > > > This patch series is a revision of http://lkml.org/lkml/2010/6/25/11 .
> > > > > 
> > > > > This patch series implements a write function for the 'cgroup.procs'
> > > > > per-cgroup file, which enables atomic movement of multithreaded
> > > > > applications between cgroups. Writing the thread-ID of any thread in a
> > > > > threadgroup to a cgroup's procs file causes all threads in the group to
> > > > > be moved to that cgroup safely with respect to threads forking/exiting.
> > > > > (Possible usage scenario: If running a multithreaded build system that
> > > > > sucks up system resources, this lets you restrict it all at once into a
> > > > > new cgroup to keep it under control.)
> > > > > 
> > > > > Example: Suppose pid 31337 clones new threads 31338 and 31339.
> > > > > 
> > > > > # cat /dev/cgroup/tasks
> > > > > ...
> > > > > 31337
> > > > > 31338
> > > > > 31339
> > > > > # mkdir /dev/cgroup/foo
> > > > > # echo 31337 > /dev/cgroup/foo/cgroup.procs
> > > > > # cat /dev/cgroup/foo/tasks
> > > > > 31337
> > > > > 31338
> > > > > 31339
> > > > > 
> > > > > A new lock, called threadgroup_fork_lock and living in signal_struct, is
> > > > > introduced to ensure atomicity when moving threads between cgroups. It's
> > > > > taken for writing during the operation, and taking for reading in fork()
> > > > > around the calls to cgroup_fork() and cgroup_post_fork().

The above six month old text is the best (and almost the only)
explanation of the rationale for the entire patch series.  Is
it still correct and complete?


Assuming "yes", then...  how do we determine whether the feature is
sufficiently useful to justify merging and maintaining it?  Will people
actually use it?

Was there some particular operational situation which led you to think
that the kernel should have this capability?  If so, please help us out here
and lavishly describe it.
