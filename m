From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH] linux-cr: nested pid namespaces (v3)
Date: Tue, 23 Mar 2010 09:46:31 -0500
Message-ID: <20100323144631.GA21337@hallyn.com>
References: <20100323051839.GA16123@us.ibm.com>
 <20100323071431.GC4242@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100323071431.GC4242@localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Louis Rilling <Louis.Rilling@kerlabs.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Quoting Louis Rilling (Louis.Rilling@kerlabs.com):
> On Tue, Mar 23, 2010 at 12:18:39AM -0500, Serge E. Hallyn wrote:
> > Support checkpoint and restart of tasks in nested pid namespaces.
> > We keep the original single pids_array to minimize memory
> > allocations.  The pids array entries are augmented with a pidns
> > depth (relative to the container init's pidns, and an "rpid" which
> > is the pid in the checkpointer's pidns (or 0 if no valid pid exists).
> > The rpid will be used by userspace to gather more information (like
> > /proc/$$/mountinfo) after the kernel sys_checkpoint.  If any tasks
> > are in nested pid namespace, another single array will hold all of
> > the vpids.  At restart those are used by userspace to determine how
> > to call eclone().  Kernel ignores them.
> > 
> > This patch also adds 'rpid' to struct ckpt_hdr_pids, which is not
> > needed for nested pid_ns support, but will be needed for the
> > userspace checkpointer to gather additional information (i.e.
> > /proc/pid/mountinfo) after sys_checkpoint() completes.
> > 
> > Changelog:
> >   Mar 22:
> > 	Use Louis Rilling's smarter ckpt_vpids algorithm
> > 	verbatim, to handle pid_ns depths > CKPT_HDR_PIDS_CHUNK,
> > 	as well as fix an apparent bug in my original code.
> > 
> > 	As Louis suggested, use task_active_pid_ns() rather than
> > 	task->nsproxy->pid_ns.  In fact it's a must, bc the
> > 	checkpointed task may be dead and have NULL
> > 	task->nsproxy->pid_ns.
> 
> Hm, if task can be dead, then there is a much bigger issue:
> task->nsproxy is NULL. Or did I miss something?

Well, it's a zombie - checkpoint/checkpoint.c:may_checkpoint_task()
explicitly ignores nsproxy tests for zombies (but returns -EBUSY
for exit_state == EXIT_DEAD).  So yeah, nsproxy is NULL, which is
why I have to use task_active_pid_ns()  :)

-serge
