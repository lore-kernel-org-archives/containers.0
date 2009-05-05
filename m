From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] IO Controller
Date: Tue, 05 May 2009 11:18:40 +0800
Message-ID: <49FFB010.9000309__46363.6703709655$1241493749$gmane$org@cn.fujitsu.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<49DF1256.7080403@cn.fujitsu.com>
	<20090413130958.GB18007@redhat.com>
	<49EE895A.1060101@cn.fujitsu.com>
	<20090422132307.GA23098@redhat.com> <49F9FE3C.3070000@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49F9FE3C.3070000-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Nauman Rafique wrote:
...
> Hi Gui,
> This patch should solve the problems reported by you. Please let me know if it does not work.
> @Vivek, this has a few more changes after the patch I sent you separately.
> 

  Hi Nauman,

  I'v tried your patch, seems the bug has been fixed. thanks!

> DESC
> Add ref counting for io_group.
> EDESC
>     
>         Reference counting for io_group solves many problems, most of which
>         occured when we tried to delete the cgroup. Earlier, ioqs were being
>         moved out of cgroup to root cgroup. That is problematic in many ways:
>         First, the pending requests in queues might get unfair service, and
>         will also cause unfairness for other cgroups at the root level. This
>         problem can become signficant if cgroups are created and destroyed
>         relatively frequently. Second, moving queues to root cgroups was
>         complicated and was causing many BUG_ON's to trigger. Third, there is
>         a single io queue in AS, Deadline and Noop within a cgroup; and it
>         does not make sense to move it to the root cgroup. The same is true of
>         async queues.
>     
>         Requests already keep a reference on ioq, so queues keep a reference on
>         cgroup. For async queues in CFQ, and single ioq in other schedulers,
>         io_group also keeps are reference on io_queue. This reference on ioq
>         is dropped when the queue is released (elv_release_ioq). So the queue
>         can be freed.
>     
>         When a queue is released, it puts the reference to io_group and the
>         io_group is released after all the queues are released. Child groups
>         also take reference on parent groups, and release it when they are
>         destroyed.
>     
>         Also we no longer need to maintain a seprate linked list of idle
>         entities, which was maintained only to help release the ioq references
>         during elevator switch. The code for releasing io_groups is reused for
>         elevator switch, resulting in simpler and tight code.
> 
 

-- 
Regards
Gui Jianfeng
