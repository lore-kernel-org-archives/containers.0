From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [RFC] [PATCH v3 1/2] cgroups: read-write lock CLONE_THREAD
	forking per threadgroup
Date: Wed, 28 Jul 2010 04:29:53 -0400
Message-ID: <20100728082953.GA15455__46944.1113681116$1280305869$gmane$org@ghc01.ghc.andrew.cmu.edu>
References: <20100625054541.GA20610@ghc01.ghc.andrew.cmu.edu>
	<20100625054654.GB20610@ghc01.ghc.andrew.cmu.edu>
	<20100628161031.a8c71fce.kamezawa.hiroyu@jp.fujitsu.com>
	<20100628154359.GA24629@ghc01.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100628154359.GA24629-kwnxxEB+oiWqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jun 28, 2010 at 11:43:59AM -0400, Ben Blum wrote:
> On Mon, Jun 28, 2010 at 04:10:31PM +0900, KAMEZAWA Hiroyuki wrote:
> > By the way, IMHO, hiding lock in cgroup_fork() and cgroup_post_fork() doesn't
> > seem good idea. How about a code like this ?
> > 
> >   read_lock_thread_clone(current);
> >   cgroup_fork();
> >  .....
> >   cgroup_post_fork();
> >   read_unlock_thrad_clone(current);
> > 
> > We may have chances to move these lock to better position if cgroup is
> > an only user.
> 
> I didn't do that out of a desire to change fork.c as little as possible,
> but that does look better than what I've got. Those two functions should
> be in fork.c under #ifdef CONFIG_CGROUPS.

I'm looking at this now and am not sure where the best place to put
these is:

1) Don't make new functions, just put:

    #ifdef CONFIG_CGROUPS
        if (clone_flags & CLONE_THREAD)
            down/up_read(...);
    #endif

directly in copy_process() in fork.c. Simplest, but uglifies the code.

2) Make static helper functions in fork.c. Good, but not consistent with
directly using the lock in write-side (attach_proc).

3) Define inline functions under #ifdef CONFIG_CGROUPS in sched.h, just
under the declaration of the lock. Most robust, but I'm hesitant to add
unneeded stuff to such a popular header file.

Any opinions?

-- Ben

> 
> > 
> > Thanks,
> > -Kame
> 
> Thanks,
> -- Ben
> 
