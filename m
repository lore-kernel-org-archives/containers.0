From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 0/6] Unshare support for the pid namespace.
Date: Sun, 20 Jun 2010 20:03:35 +0200
Message-ID: <20100620180335.GA17120@redhat.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <20100617212003.GA4182@redhat.com> <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com> <m1pqzmqema.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1pqzmqema.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>
List-Id: containers.vger.kernel.org

On 06/20, Eric W. Biederman wrote:
>
> Oleg Nesterov <oleg@redhat.com> writes:
>
> > On 06/18, Oleg Nesterov wrote:
> >>
> >> I only try to discuss the idea to break the circular reference.
> >
> > I don't know what I have missed, but this looks really right to me.
> > Besides, we have yet another problem: proc_flush_task()->mntput()
> > is just wrong. Consider the multithreaded execing init.
> >
> > I am going to simplify, test, and send the fix which moves mntput()
> > into free_pid_ns() paths.
>
> free_pid_ns is comparatively late, to release the kern_mount.

Why?

Once again, it is very possible I am wrong. I forgot this code if ever
knew. But could you please explain?

> > But first of all I think we should cleanup the pid_ns_prepare_proc()
> > logic. Imho, this code is really ugly. Please see the patches.
>
> Since I have a patchset that makes it possible to unshare the pid
> namespace about ready to send I figure we should combine the two
> efforts.
>
> This patchset is a prerequisite to my patches for giving namespaces
> file descriptors and allowing you to join and existing namespace.

I do not understand.

Eric, why you can't do these changes on top of the cleanups I sent?

OK, personally I certainly dislike 1/6, but perhaps it is needed for
6/6 which I didn't read yet. But, in any case, it is orthogonal to
pid_ns_prepare_proc() cleanups?

Now. You joined the first 2 patches I sent into 2/6. It is not that
I care about the "From:" tag, but why? And (unless I missed something)
you added the following changes compared to my patches:

	- remove the MS_KERNMOUNT check around ei->pid = find_pid(1).
	  OK, I agree it was not strictly needed, but imho makes the
	  code cleaner.

	  Or I missed something and this check was wrong?

	- introduce the bug in create_pid_namespace(). If
	  pid_ns_prepare_proc() fails, we return the wrong error
	  code and leak parent_pid_ns().

So. Afaics - nack to 2/6 at least. Could you please do this on top of
the cleanups I sent? Of course, unless you think they are wrong.

And. I do not think these series can fix the discussed problems. ns->dead
definitely can't, no?

I think we should fix the bugs first.

Oleg.
