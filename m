From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Date: Thu, 12 Jun 2008 14:08:06 +0900
Message-ID: <20080612140806.dc161c77.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110017t5ebeda78id1914d179a018422@mail.gmail.com>
	<20080611164544.94047336.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110104n99cdc7h80063e91d16bf0a5@mail.gmail.com>
	<20080611172714.018aa68c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110148v65df67f8ge0ccdd56c21c89e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830806110148v65df67f8ge0ccdd56c21c89e0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, "nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org" <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 11 Jun 2008 01:48:20 -0700
"Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Wed, Jun 11, 2008 at 1:27 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > Sorry. try another sentense..
> >
> > I think cgroup itself is designed to be able to be used without middleware.
> 
> True, but it shouldn't be hostile to middleware, since I think that
> automated use will be much more common. (And certainly if you count
> the number of servers :-) )
> 
> > IOW, whether using middleware or not is the matter of users not of developpers.
> > There will be a system that system admin controlles all and move tasks by hand.
> > ex)...personal notebooks etc..
> >
> 
> You think so? I think that at the very least users will be using tools
> based around config scripts, rule engines and libcgroup, if not a
> persistent daemon.
> 
I believe some users will never use middlewares because of their special
usage of linux.



> >> If the common mode for middleware starting a new cgroup is fork() /
> >> move / exec() then after the fork(), the child will be sharing pages
> >> with the main daemon process. So the move will pull all the daemon's
> >> memory into the new cgroup
> >>
> > My patch (this patch) just moves Private Anon page to new cgroup. (of mapcount=1)
> 
> OK, well that makes it more reasonable regarding the above problem.
> But I can still see problems if, say, a single thread moves into a new
> cgroup, you move the entire memory. Perhaps you should only do so if
> the mm->owner changes task?
> 

Thank you for pointing out. I'll add mm->owner check.

BTW, should we have a cgroup for SYSVIPC resource controller and devide it
from memory resource controller ?  I think that per-task on-demand usage
accounting is not suitable for shmem (and hugepage).
per-creater (caller of shmget()) accounting seems to be better for me.

Just a question:
What happens when a thread (not thread-group-leader) changes its ns by
ns-cgroup ? not-allowed ?


Thanks,
-Kame
