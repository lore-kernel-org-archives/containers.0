From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Fri, 25 Jul 2008 10:06:16 -0400
Message-ID: <6599ad830807250706t23e483b5j18d683c0470d1d22@mail.gmail.com>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
	<Pine.LNX.4.64.0807251004570.31120@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0807251004570.31120-popGQ1T0qN76K7/ahGyk6A@public.gmane.org>
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
To: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jul 25, 2008 at 5:06 AM, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org> wrote:
>
> (Different topic, but one day I ought to get around to saying again
> how absurd I think a swap controller; whereas a mem+swap controller
> makes plenty of sense.  I think Rik and others said the same.)

Agreed that a swap controller without a memory controller doesn't make
much sense, but a memory controller without a swap controller can make
sense on machines that don't intend to use swap.

So if they were separate controllers, we'd use the proposed cgroup
dependency features to make the swap controller depend on the memory
controller - in which case you'd only be able to mount the swap
controller on a hierarchy that also had the memory controller, and the
swap controller would be able to make use of the page ownership
information.

It's more of a modularity issue than a functionality issue, I think -
the swap controller and memory controller are tracking fundamentally
different things (space on disk versus pages in memory), and the only
dependency between them is the "memory controller" tracking the
ownership of a page and providing it to the "swap controller".

>
> By the way, here's a BUG I got from CONFIG_CGROUP_MEMRLIMIT_CTLR=y
> but no use of it, when doing swapoff a week ago.  Not investigated
> at all, I'm afraid, but at a guess it might come from memrlimit work
> placing too much faith in the mm_users count - swapoff is only one
> of several places which have to inc/dec mm_users for some reason.
>
> BUG: unable to handle kernel paging request at 6b6b6b8b

Possibly the mm->owner tracking breaks in that case, if the last user
exits while swapoff is occurring without relinquishing ownership?

That looks as though mm->owner points to a task that had been poisoned
after being freed. That could be awkward to fix :-(

Paul
