From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Fri, 18 Jun 2010 19:55:41 +0200
Message-ID: <20100618175541.GA13680@redhat.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <20100617212003.GA4182@redhat.com> <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100618173320.GG16877@hawkmoon.kerlabs.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Louis Rilling <louis.rillin>
List-Id: containers.vger.kernel.org

On 06/18, Louis Rilling wrote:
>
> On 18/06/10 18:08 +0200, Oleg Nesterov wrote:
> >
> > Not sure I ever understood this code. Certainly I can't say I understand
> > it now. Still, do we really need this circle? I am almost sure the patch
> > below is not right (and it wasn't tested at all), but could you take a
> > look?
>
> I won't pretend understanding better than you do. Still I can try to give my 2
> cents.
>
> Overall, I don't feel comfortable at being able to have a living proc_mnt
> with a dead pid_ns.

Yes, this should be fixed, I already realized this. work->func(ns) is
called when ns is already fixed.

Otherwise, nobody should use ns->proc_mount when ns is already dead/freed.

> > Note: afaics we have another problem. What if copy_process(CLONE_NEWPID)
> > fails after pid_ns_prepare_proc() ? Who will do mntput() ? This patch
> > should fix this too (again, ___if___ it correct).
>
> Sounds true.

Good.

> > @@ -74,7 +74,7 @@ static int proc_get_sb(struct file_syste
> >  		ei = PROC_I(sb->s_root->d_inode);
> >  		if (!ei->pid) {
> >  			rcu_read_lock();
> > -			ei->pid = get_pid(find_pid_ns(1, ns));
> > +			ei->pid = find_pid_ns(1, ns);
>
> I don't think that this is correct. IIUC, proc_delete_inode() calls put_pid() on
> ei->pid.

Yes,

> So either a special case is added in proc_delete_inode(), or we try to
> live with get_pid() here. I'm actually not sure that we can pretend that this
> pid remains valid if we don't get_pid() here.

But please see another change below,

> > +static void proc_mntput(struct work_struct *work)
> >  {
> > +	struct pid_namespace *ns = container_of(work, struct pid_namespace, proc_put);
> > +
> > +	PROC_I(ns->proc_mnt->mnt_sb->s_root->d_inode)->pid = NULL;
> >  	mntput(ns->proc_mnt);
> >  }

it clears ei->pid.

We are called from free_pid_ns() path, this ->pid must not have any reference.
Any get_pid() implies get_pid_ns().

What do you think?

Oleg.
