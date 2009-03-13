From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Date: Fri, 13 Mar 2009 11:35:31 -0500
Message-ID: <20090313163531.GA10685__26686.675908468$1236962354$gmane$org@us.ibm.com>
References: <1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz>
	<20090212141014.2cd3d54d.akpm@linux-foundation.org>
	<1234479845.30155.220.camel@nimitz>
	<20090226155755.GA1456@x200.localdomain>
	<20090310215305.GA2078@x200.localdomain>
	<49B775B4.1040800@free.fr> <20090312145311.GC12390@us.ibm.com>
	<49BA8013.3030103@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49BA8013.3030103-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (legoater-GANU6spQydw@public.gmane.org):
> 
> > No, what you're suggesting does not suffice.
> 
> probably. I'm still trying to understand what you mean below :)
> 
> Man, I hate these hierarchicals pid_ns. one level would have been enough, 
> just one vpid attribute in 'struct pid*'

Well I don't mind - temporarily - saying that nested pid namespaces
are not checkpointable.  It's just that if we're going to need a new
syscall anyway, then why not go ahead and address the whole problem?
It's not hugely more complicated, and seems worth it.

> > Call
> > (5591,3,1) the task knows as 5591 in the init_pid_ns, 3 in a child pid
> > ns, and 1 in grandchild pid_ns created from there.  Now assume we are
> > checkpointing tasks T1=(5592,1), and T2=(5594,3,1).
> > 
> > We don't care about the first number in the tuples, so they will be
> > random numbers after the recreate. 
> 
> yes.
> 
> > But we do care about the second numbers.  
> 
> yes very much and we need a way set these numbers in alloc_pid()
> 
> > But specifying CLONE_NEWPID while recreating the process tree
> > in userspace does not allow you to specify the 3 in (5594,3,1).
> 
> I haven't looked closely at hierarchical pid namespaces but as we're
> using a an array of pid indexed but the pidns level, i don't see why 
> it shouldn't be possible. you might be right.
> 
> anyway, I think that some CLONE_NEW* should be forbidden. Daniel should
> send soon a little patch for the ns_cgroup restricting the clone flags
> being used in a container.

Uh, that feels a bit over the top.  We want to make this
uncheckpointable (if it remains so), not prevent the whole action.
After all I may be running a container which I don't plan on ever
checkpointing, and inside that container running a job which i do
want to migrate.

So depending on if we're doing the Dave or the rest-of-the-world
way :), we either clear_bit(pidns->may_checkpoint) on the parent
pid_ns when a child is created, or we walk every task being
checkpointed and make sure they each are in the same pid_ns.  Doesn't
that suffice?

-serge
