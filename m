From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 11/11] mnt: Honor MNT_LOCKED when detaching mounts
Date: Fri, 09 Jan 2015 23:32:47 -0600
Message-ID: <87h9vzryio.fsf@x220.int.ebiederm.org>
References: <87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<1420490787-14387-11-git-send-email-ebiederm@xmission.com>
	<20150107184334.GZ22149@ZenIV.linux.org.uk>
	<87h9w2gzht.fsf@x220.int.ebiederm.org>
	<20150107205239.GB22149@ZenIV.linux.org.uk>
	<87iogi8dka.fsf@x220.int.ebiederm.org>
	<20150108002227.GC22149@ZenIV.linux.org.uk>
	<20150108223212.GF22149@ZenIV.linux.org.uk>
	<20150109203126.GI22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150109203126.GI22149-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Fri, 9 Jan 2015 20:31:26 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

> On Thu, Jan 08, 2015 at 10:32:13PM +0000, Al Viro wrote:
>> 	a) easily expressed with that scheme (behaviour is almost identical
>> to what your series does, except that we'd empty mnt_child right in
>> mntput_no_expire(), rather than keeping it until cleanup_mnt()) and
>> 	b) easily generalized to MNT_DETACH with lazy dissolving; in fact,
>> the only difference would be to treat *all* submounts as "don't put on
>> global list, don't remove from child list", not just the MNT_LOCKED ones.
>> 
>> I'll play around with that today and tomorrow; hopefully, I'll have a postable
>> variant by the weekend...
>
> Hmm...  Linus, what do you think of the following?

You are just about defining a mutex here.  The one difference is the
single use property that makes this a good cleanup primitive.

WQ_FLAG_EXCLUSIVE appears wrong.  We want to remove all of the waiters
from the list and wake the all up.  Otherwise if you have 3 different
kernel threads all trying to clean up the same structure at the
same time (say remount, mntput and acct_off) one of them will be left
waiting forever.

I don't believe rcu anything in this function itself buys you anything,
but structuring this primitive so that it can be called from an rcu list
traversal seems interesting.  

It might be simpler to have a single fs_pin_mutex and that guards all of
the paths to a fs_pin so we don't have to be this clever.  But I expect
there are weird lock ordering issues that being this smart allows us to
avoid.  Certainly a primitive that allows us to clean things up without
any locks held is easier to maintain.

> struct foo {
> 	int done;
> 	wait_queue_head_t wait;
> 	...
> };
>
> void kill_foo(struct foo *p)
> {
>         wait_queue_t wait;
> 	wait.flags = WQ_FLAG_EXCLUSIVE;
> 	wait.private = current;
> 	wait.func = autoremove_wake_function;
> 	spin_lock_irq(&p->wait.lock);
> 	if (likely(!p->done)) {
> 		p->done = -1;
> 		spin_unlock_irq(&p->wait.lock);
> 		rcu_read_unlock();
> 		/* do cleanup */
> 		...
> 		/* remove references to *p */
> 		...
> 		spin_lock_irq(&p->wait.lock);
> 		p->done = 1;	
> 		wake_up_locked(&p->wait);
> 		spin_unlock_irq(&p->wait.lock);
> 		/* RCU-schedule freeing of p */
> 		...
> 		return;
> 	}
> 	if (p->done > 0) {
> 		spin_unlock_irq(&p->wait.lock);
> 		rcu_read_unlock();
> 		return;
> 	}
> 	__add_wait_queue_tail(&p->wait, &wait);
> 	while (1) {
> 		set_current_state(TASK_UNINITERRUPTIBLE);
> 		spin_unlock_irq(&p->wait.lock);
> 		rcu_read_unlock();
> 		schedule();
> 		rcu_read_lock();
> 		if (likely(list_empty(&wait.task_list)))
> 			break;
> 		/* OK, we know p couldn't have been freed yet */
> 		spin_lock_irq(&p->wait.lock);
> 		if (p->done > 0) {
> 			spin_unlock_irq(&p->wait.lock);
> 			break;
> 		}
> 	}
> 	rcu_read_unlock();
> }
>
> AFAICS, that ought to be safe - the first caller makes sure that everybody
> else will wait for it to finish, everybody else (ones who come via references
> before the first one has removed them) will be waiting for the first one
> to do wakeup *and* will take care not to touch the victim unless they knows
> it's still there.
>
> Do you see any problems with the above?  I wonder if I ended up open-coding
> something already existing in there...
