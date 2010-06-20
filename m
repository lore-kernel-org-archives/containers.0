From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 6/6] pidns: Support unsharing the pid namespace.
Date: Sun, 20 Jun 2010 22:42:57 +0200
Message-ID: <20100620204257.GA9156@redhat.com>
References: <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com> <m1pqzmqema.fsf_-_@fess.ebiederm.org> <m1wrtuozq6.fsf_-_@fess.ebiederm.org> <20100620201454.GA6902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100620201454.GA6902@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>, Roland McGrath <roland@redhat.com>
List-Id: containers.vger.kernel.org

On 06/20, Oleg Nesterov wrote:
>
> On 06/20, Eric W. Biederman wrote:
> >
> > Unsharing of the pid namespace unlike unsharing of other namespaces
> > does not take affect immediately.  Instead it affects the children
> > created with fork and clone.
>
> Cough. It is too late to me to even try to understand the changelog.
>
> Instead I tried to quickly read the patch. Most probably I missed
> somthing, but still I'd like to ask the quiestion.
>
> So. If I understand correctly, the patch is simple:
>
> 	- unshare(CLONE_NEWPID) changes current->proxy->pid_ns,
> 	  but do not change current->pids[] and thus it doesn't
> 	  change task_active_pid_ns().
>
> 	- since copy_process() uses ->proxy->pid_ns for alloc_pid()
> 	  the new children will fall into the new ns.
>
> IOW, the caller becomes the "swapper" for the new namespace.
>
> Correct?
>
> If yes, I'm afraid nobody except you will understand this magic ;)
>
> But what if the task T does unshare(CLONE_NEWPID) and then, say,
> pthread_create() ? Unless I missed something, the new thread won't
> be able to see T ?

and, in this case the exiting sub-namespace init also kills its
parent?

> OK, suppose it does fork() after unshare(), then another fork().
> In this case the second child lives in the same namespace with
> init created by the 1st fork, but it is not descendant ? This means
> in particular that if the new init exits, zap_pid_ns_processes()->
> do_wait() can't work.
>
> I hope I missed something, this all is too subtle for me. And I
> still do not understand 4/6 which adds ns->dead.

And, forgot to mention. With this change proc_flush_task()->mntput()
becomes even more wrong.

Oleg.
