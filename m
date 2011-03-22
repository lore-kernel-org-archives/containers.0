From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v8 3/3] cgroups: make procs file writable
Date: Tue, 22 Mar 2011 01:08:21 -0400
Message-ID: <20110322050821.GA11447__35472.6401078098$1300770554$gmane$org@ghc17.ghc.andrew.cmu.edu>
References: <20110208013542.GC31569@ghc17.ghc.andrew.cmu.edu>
	<20110208013950.GF31569@ghc17.ghc.andrew.cmu.edu>
	<AANLkTinEnNsu8=PEktXL_EECzGYqsgdf+uogGxe7k4W+@mail.gmail.com>
	<20110310061831.GA23736@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110310061831.GA23736-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Mar 10, 2011 at 01:18:31AM -0500, Ben Blum wrote:
> > > + ? ? ? ? ? ? ? ? ? ? ? /* optimization for the single-task-only case */
> > > + ? ? ? ? ? ? ? ? ? ? ? rcu_read_unlock();
> > > + ? ? ? ? ? ? ? ? ? ? ? cgroup_unlock();
> > > ? ? ? ? ? ? ? ? ? ? ? ?return -ESRCH;
> > > ? ? ? ? ? ? ? ?}
> > >
> > > + ? ? ? ? ? ? ? /*
> > > + ? ? ? ? ? ? ? ?* even if we're attaching all tasks in the thread group, we
> > > + ? ? ? ? ? ? ? ?* only need to check permissions on one of them.
> > > + ? ? ? ? ? ? ? ?*/
> > > ? ? ? ? ? ? ? ?tcred = __task_cred(tsk);
> > > ? ? ? ? ? ? ? ?if (cred->euid &&
> > > ? ? ? ? ? ? ? ? ? ?cred->euid != tcred->uid &&
> > > ? ? ? ? ? ? ? ? ? ?cred->euid != tcred->suid) {
> > > ? ? ? ? ? ? ? ? ? ? ? ?rcu_read_unlock();
> > > + ? ? ? ? ? ? ? ? ? ? ? cgroup_unlock();
> > > ? ? ? ? ? ? ? ? ? ? ? ?return -EACCES;
> > 
> > Maybe turn these returns into "goto out;" statements and put the
> > unlock after the out: label?
> > 
> 
> Maybe; I didn't look too hard at that function. If I revise the patch I
> can do this, though.

Looking back, I think I like it the way it is. Coalescing those unlock
paths would make it less clear... rcu_read is unlocked in the middle of
the function (on the success path), so having a bailout path moves the
failure path far removed from where it's relevant.

-- Ben
