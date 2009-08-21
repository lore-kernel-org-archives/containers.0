From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][v4][PATCH 0/7] clone_with_pids() system call
Date: Fri, 21 Aug 2009 11:11:20 -0500
Message-ID: <20090821161120.GA21094__18593.1646884002$1250871141$gmane$org@us.ibm.com>
References: <20090807061103.GA19343@us.ibm.com>
	<m1vdks5qc8.fsf@fess.ebiederm.org>
	<20090813080049.GA16639@us.ibm.com>
	<m1vdks2iea.fsf@fess.ebiederm.org>
	<20090813194616.GA10493@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090813194616.GA10493-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> > Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
> > 
> > > Eric W. Biederman [ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org] wrote:
> > > | Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
> > > | 
> > > | > === NEW CLONE() SYSTEM CALL:
> > > | >
> > > | > To support application checkpoint/restart, a task must have the same pid it
> > > | > had when it was checkpointed.  When containers are nested, the tasks within
> > > | > the containers exist in multiple pid namespaces and hence have multiple pids
> > > | > to specify during restart.
> > > | >
> > > | > This patchset implements a new system call, clone_with_pids() that lets a
> > > | > process specify the pids of the child process.
> > > | >
> > > | > Patches 1 through 5 are helpers and we believe they are needed for application
> > > | > restart, regardless of the kernel implementation of application restart.
> > > | 
> > > | I'm not very impressed.
> > > | 
> > > | - static int alloc_pidmap(struct pid_namespace *pid_ns)
> > > | + static int alloc_pidmap(struct pid_namespace *pid_ns, int pid_max, int last_pid)
> > > | 
> > > | Do that.
> > > | 
> > > | That is pass in pid_max and last_pid, and you don't have to do weird
> > > | things in alloc_pidmap, and no set_pidmap is needed.
> > >
> > > But last_pid is from the pid_ns. Do you mean to have alloc_pidmap()
> > > take a pid_min and pid_max and when choosing a specific pid, have
> > > pid_min == pid_max == target_pid ?
> > 
> > Yes. It already takes a pid_min and a pid_max from the environment.
> > I guess the pid_min is RESERVED_PIDS by default.
> > 
> > > | No changes to copy_process are needed it already takes a struct pid
> > > | argument.
> > >
> > >
> > > I see your point about passing in both 'struct pid*' and target_pids[].
> > > But in the common case the struct pid passed into copy_process() is
> > > NULL - allocating pid in do_fork() would significantly alter the
> > > existing control flow - no ? alloc_pid() assumes any new pid namespace
> > > has been created - in copy_namespaces(). Moving the alloc_pid() to
> > > do_fork() would require parsing clone_flags in do_fork() and pulling
> > > pid namespace code out of copy_namespaces().
> > 
> > Why change do_fork?
> > 
> > > | I haven't been following closely what is gained by having a clone_with_pids
> > > | syscall?  
> > >
> > > When restarting an application from a checkpoint, the application must get
> > > the same pid it had at the time of checkpoint. clone_with_pids() would be
> > > used during restart so the child can be created with a specific set of pids.
> > 
> > That part I understand.  What I don't understand is why have that one part be
> > special and have user space do the work?
> 
> How would this be used then?  Let's say I'm recreating a process tree
> with two nested pid namespaces.  so just using clone(CLONE_NEWPID) we'd
> have P{500} creates P{1501,1} which creates P{1502,1,2} which creates
> P{1502,2,3} (1502 in top namespace, 2 in child ns, 3 in lowest pid ns).
> But now we want to create P{X, 27, 953} (i.e. X can be anything).  How
> do we specify that for pidns 2 we want pid_min=pid_max=27, and for
> pidns 3 pid_min=pid_max=953?

Eric, if you have an idea for how to do this, please let me know,
and I'll set about trying a new patchset to do it.  But as it stands
I don't see how to make your suggestion useful from userspace.

thanks,
-serge
