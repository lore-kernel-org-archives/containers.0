From: Davidlohr Bueso <dave-h16yJtLeMjHk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [RFC PATCH] namespaces: Avoid task_lock when setting tsk->nsproxy
Date: Fri, 26 Feb 2016 10:19:26 -0800
Message-ID: <20160226181926.GA4166@linux-uzut.site>
References: <1456481448-3925-1-git-send-email-dbueso@suse.de>
	<87wpprgyz7.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87wpprgyz7.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, Davidlohr Bueso <dbueso-l3A5Bk7waGM@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 26 Feb 2016, Eric W. Biederman wrote:

>I would really appreciate it, if you are going to come up with a new
>locking primitive that you implement that locking primitive separately.

Using some rmw insn to avoid a lock is hardly implementing a new locking
primitive. This was never the purpose, and we use similar techniques throughout
the kernel to force certain paths.

>A fresh locking primitive comingled with other code is a good way to get
>something wrong, and generally to get code that is not well maintained
>because there is not a separation of concerns.
>
>Furthermore there is a world of difference between a 1+jiffy delay
>waiting for rcu_synchronize and the short hold times of task_lock.

I am aware of that, this is an optimization only based on that task_lock
is mainly unconteded, and hoped I made it clear in the changelog.

>Looking at your locking it appears to be a complete hack.  Always taking
>task_lock on read (but now you have an extra atomic op where you call
>xchg on the pointer).  Just calling compare_xchg on write if there
>are no concurrent readers.

The task on read is considered a slowpath, the extra atomic op is what I
had mentioned in the overhead, but for the fastpath we save two ops, otoh.

>For raw performance you would do better to have a separate lock, or
>potentially a specialized locking primitive that just used the low
>pointer bits.
>
>I don't know what motivates this work are you actually seeing
>performance problems with setns?

Motivation is towards other alloc_lock users, more than nsproxy itself.
I had just come across your mentioned change from using rcu and given
that there is practically 0 concurrency, though we could do better.

>I am very uncomofortable with a novel, and very awkward new locking
>primitive that does not clearly show improvements in even it's target
>workloads.
>
>Hmm.  After thinking about this a little more your set_reader_nsproxy is
>completely unsafe.  Most readers of nsproxy are from the same task.
>Changing the low bits of the pointer of from another task will cause
>those readers to segfault, and if not segfault they are reading from the
>wrong memory locations.

Ok, this part I was not sure of and was the simplest way I could think of
atomically checking for readers with a single [Rmw]. fwiw, as an alternative
to the pointer tagging I had considered doing some sorf of spin_is_locked()
check on the alloc_lock for the writer, but that has its own can of worms on
SMP anyway.

Thanks,
Davidlohr
