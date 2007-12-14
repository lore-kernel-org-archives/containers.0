From: "Dmitry Adamushko" <dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Re: Hang with fair cgroup scheduler (reproducer is attached.)
Date: Fri, 14 Dec 2007 17:25:39 +0100
Message-ID: <b647ffbd0712140825h4f541be0xa7a7866e70b3af7a@mail.gmail.com>
References: <20071214141528.GA6161@linux.vnet.ibm.com>
	<20071214161834.034e6efe.kamezawa.hiroyu@jp.fujitsu.com>
	<20071214171759.59f7ba57.kamezawa.hiroyu@jp.fujitsu.com>
	<20071214094909.GG11266@elte.hu>
	<20071214195837.0d3511db.kamezawa.hiroyu@jp.fujitsu.com>
	<b647ffbd0712140447kfba5945ybde40f18653dd164@mail.gmail.com>
	<20442799.1197642268756.kamezawa.hiroyu@jp.fujitsu.com>
	<20071214153607.GB23670@linux.vnet.ibm.com>
	<20071214153823.GC23670@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071214153823.GC23670-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 14/12/2007, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> > >
> Actually no, its another bug. Thanks for the program!
>

Humm... this crash is very likely to be caused by the same bug. It
just reveals itself in a different place, but effectivelly the pattern
looks similar. Anyway, the rb-tree gets corrupted... and for both
cases, at the very least the 'current' must be within the tree.
I think, if you repeat your test a number of times, you'll likely get
the very same crash as was reported by Kame.

ia64 does define __ARCH_WANT_UNLOCKED_CTXSW (I checked against
2.6.23.1 that I have at hand)

x86 -- not (it's not reproducible there, right?)

so for ia64 task_running() makes use of 'p->oncpu' to determine
whether a given task is currently running
(as opposed to 'rq->curr == p' otherwise)...

But at first glance, it looks like there shouldn't be situations
leading to some sort of de-synchronization in determining the real
'current'.

Will look at it closer.


>
> --
> regards,
> Dhaval
>

-- 
Best regards,
Dmitry Adamushko
