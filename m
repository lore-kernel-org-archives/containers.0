From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Mon, 21 Jun 2010 07:26:15 -0700
Message-ID: <m1iq5c4g3c.fsf@fess.ebiederm.org>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com>
	<4C19F0A3.2050707@parallels.com> <m1631hdbdu.fsf@fess.ebiederm.org>
	<20100617213638.GB4182@redhat.com>
	<20100618082738.GE16877@hawkmoon.kerlabs.com>
	<20100618162734.GB7404@redhat.com>
	<20100621111127.GI16877@hawkmoon.kerlabs.com>
	<m1vd9c4k67.fsf@fess.ebiederm.org>
	<20100621141518.GA3773@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100621141518.GA3773@hawkmoon.kerlabs.com> (Louis Rilling's message of "Mon\, 21 Jun 2010 16\:15\:18 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Linux Containers <containers@lists.osdl.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

Louis Rilling <Louis.Rilling@kerlabs.com> writes:

> On 21/06/10  5:58 -0700, Eric W. Biederman wrote:
>> Louis Rilling <Louis.Rilling@kerlabs.com> writes:
>> 
>> > On 18/06/10 18:27 +0200, Oleg Nesterov wrote:
>> >> On 06/18, Louis Rilling wrote:
>> >> >
>> >> > On 17/06/10 23:36 +0200, Oleg Nesterov wrote:
>> >> > > On 06/17, Eric W. Biederman wrote:
>> >> > > >
>> >> > > > The task->children isn't changed until __unhash_process() which runs
>> >> > > > after flush_proc_task().
>> >> > >
>> >> > > Yes. But this is only the current implementation detail.
>> >> > > It would be nice to cleanup the code so that EXIT_DEAD tasks are
>> >> > > never sit in ->children list.
>> >> > >
>> >> > > > So we should be able to come up with
>> >> > > > a variant of do_wait() that zap_pid_ns_processes can use that does
>> >> > > > what we need.
>> >> > >
>> >> > > See above...
>> >> > >
>> >> > > Even if we modify do_wait() or add the new variant, how the caller
>> >> > > can wait for EXIT_DEAD tasks? I don't think we want to modify
>> >> > > release_task() to do __wake_up_parent() or something similar.
>> >> >
>> >> > Indeed, I was thinking about calling __wake_up_parent() from release_task()
>> >> > once parent->children becomes empty.
>> >> >
>> >> > Not sure about the performance impact though. Maybe some WAIT_NO_CHILDREN flag
>> >> > in parent->signal could limit it. But if EXIT_DEAD children are removed from
>> >> > ->children before release_task(), I'm afraid that this becomes impossible.
>> >> 
>> >> Thinking more, even the current do_wait() from zap_pid_ns_processes()
>> >> is not really good. Suppose that some none-init thread is ptraced, then
>> >> zap_pid_ns_processes() will hange until the tracer does do_wait() or
>> >> exits.
>> >
>> > Is this really a bad thing? If somebody ptraces a task in a pid namespace, that
>> > sounds reasonable to have this namespace (and it's init task) pinned.
>> 
>> Louis.  Have you seen this problem hit without my setns patch?
>
> Yes. I hit it with Kerrighed patches.  I also have an ugly reproducer on
> 2.6.35-rc3 (see attachments). Ugly because I introduced artifical delays
> in release_task(). I couldn't trigger the bug without it, probably because the
> scheduler is too kind :)
>
> I'm using memory poisoining (SLAB and DEBUG_SLAB) to make it easy to observe the
> bug.
>
> Example:
> # ./proc_flush_task-bug-reproducer 1
>
>> 
>> I'm pretty certain that this hits because there are processes do_wait
>> does not wait for, in particular processes in a disjoint process tree.
>
> Indeed do_wait() misses EXIT_DEAD children.
>
>> 
>> So at this point I am really favoring killing the do_wait and making
>> this all asynchronous.
>
> Any idea about how to do it?

Some variant of the patches Oleg just recently posted.  I'm still not
comfortable with the extending the kernel mount to the entire lifetime
of the pid_namespace.  But it certainly is better than a lot of the
alternatives.


Eric
