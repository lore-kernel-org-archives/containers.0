From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 0/6] Unshare support for the pid namespace.
Date: Sun, 20 Jun 2010 23:48:28 +0200
Message-ID: <20100620214828.GA17517@redhat.com>
References: <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com> <m1pqzmqema.fsf_-_@fess.ebiederm.org> <20100620180335.GA17120@redhat.com> <m14ogxctd6.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m14ogxctd6.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>
List-Id: containers.vger.kernel.org

On 06/20, Eric W. Biederman wrote:
>
> Oleg Nesterov <oleg@redhat.com> writes:
>
> > Why?
> >
> > Once again, it is very possible I am wrong. I forgot this code if ever
> > knew. But could you please explain?
>
> There are two kinds of dead for a pid namespace. There are:
> - no processes left.
> - no more references to struct pid_namespace.
>
> I just looked and I don't see any references to proc_mnt except from
> living processes.
>
> So while it isn't necessary that we kill the proc_mnt earlier it does
> mean that we hold the resources longer then necessary.

Yes, it can delay destroy_pid_namespace(), sure. OK, I am not going
to argue. I never said this fix is perfect. I'll be wating for the
better fix.

> > Eric, why you can't do these changes on top of the cleanups I sent?
>
> Because there are conflicts,

I don't see any conflicts, but perhaps I missed something.

> > OK, personally I certainly dislike 1/6, but perhaps it is needed for
> > 6/6 which I didn't read yet. But, in any case, it is orthogonal to
> > pid_ns_prepare_proc() cleanups?
>
> 1/6 is.  If you unshare a pid namespace.  Your first child is pid one.
> Which means we can on longer count on CLONE_PID.

I understand, but I think it should be 5/6.

> > 	- remove the MS_KERNMOUNT check around ei->pid = find_pid(1).
> > 	  OK, I agree it was not strictly needed, but imho makes the
> > 	  code cleaner.
> >
> > 	  Or I missed something and this check was wrong?
>
> The MS_KERNMOUNT check was simply unnecessary, and it makes the code
> uglier to read and more brittle.

I disagree here. Sure, it is unnecessary, and I already said this.
I added it to simply document the fact that find_pid() can't work if
MS_KERNMOUNT is set, to me this certainly makes the code more
understandable to the reader.

Oleg.
