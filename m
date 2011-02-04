From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v7 1/3] cgroups: read-write lock CLONE_THREAD forking
	per threadgroup
Date: Fri, 4 Feb 2011 16:43:54 -0500
Message-ID: <20110204214354.GB5916@ghc17.ghc.andrew.cmu.edu>
References: <20101224082226.GA13872@ghc17.ghc.andrew.cmu.edu>
	<20101226120919.GA28529@ghc17.ghc.andrew.cmu.edu>
	<20101226120951.GB28529@ghc17.ghc.andrew.cmu.edu>
	<20110124130529.903d9832.akpm@linux-foundation.org>
	<20110204212515.GA5916@ghc17.ghc.andrew.cmu.edu>
	<20110204133657.78aeebe3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110204133657.78aeebe3.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Feb 04, 2011 at 01:36:57PM -0800, Andrew Morton wrote:
> On Fri, 4 Feb 2011 16:25:15 -0500
> Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> 
> > On Mon, Jan 24, 2011 at 01:05:29PM -0800, Andrew Morton wrote:
> > > On Sun, 26 Dec 2010 07:09:51 -0500
> > > Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> > > 
> > > > Adds functionality to read/write lock CLONE_THREAD fork()ing per-threadgroup
> > > > 
> > > > From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
> > > > 
> > > > This patch adds an rwsem that lives in a threadgroup's signal_struct that's
> > > > taken for reading in the fork path, under CONFIG_CGROUPS. If another part of
> > > > the kernel later wants to use such a locking mechanism, the CONFIG_CGROUPS
> > > > ifdefs should be changed to a higher-up flag that CGROUPS and the other system
> > > > would both depend on.
> > > > 
> > > > This is a pre-patch for cgroup-procs-write.patch.
> > > > 
> > > > ...
> > > >
> > > > +/* See the declaration of threadgroup_fork_lock in signal_struct. */
> > > > +#ifdef CONFIG_CGROUPS
> > > > +static inline void threadgroup_fork_read_lock(struct task_struct *tsk)
> > > > +{
> > > > +	down_read(&tsk->signal->threadgroup_fork_lock);
> > > > +}
> > > > +static inline void threadgroup_fork_read_unlock(struct task_struct *tsk)
> > > > +{
> > > > +	up_read(&tsk->signal->threadgroup_fork_lock);
> > > > +}
> > > > +static inline void threadgroup_fork_write_lock(struct task_struct *tsk)
> > > > +{
> > > > +	down_write(&tsk->signal->threadgroup_fork_lock);
> > > > +}
> > > > +static inline void threadgroup_fork_write_unlock(struct task_struct *tsk)
> > > > +{
> > > > +	up_write(&tsk->signal->threadgroup_fork_lock);
> > > > +}
> > > > +#else
> > > 
> > > Risky. sched.h doesn't include rwsem.h.
> > > 
> > > We could make it do so, but almost every compilation unit in the kernel
> > > includes sched.h.  It would be nicer to make the kernel build
> > > finer-grained, rather than blunter-grained.  Don't be afraid to add new
> > > header files if that is one way of doing this!
> > 
> > Hmm, good point. But there's also:
> > 
> > +#ifdef CONFIG_CGROUPS
> > +       struct rw_semaphore threadgroup_fork_lock;
> > +#endif
> > 
> > in the signal_struct, also in sched.h, which needs to be there. Or I
> > could change it to a struct pointer with a forward incomplete
> > declaration above, and kmalloc/kfree it? I don't like adding more
> > alloc/free calls but don't know if it's more or less important than
> > header granularity.
> 
> What about adding a new header file which includes rwsem.h and sched.h
> and then defines the new interfaces?

Er, I mean the definition of signal_struct needs rwsem.h as well, not
just the threadgroup_fork_* functions. (And I suspect moving
signal_struct somewhere else would give bigger problems...)
