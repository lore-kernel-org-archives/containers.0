From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroups: fix lockdep subclasses overflow
Date: Wed, 04 Feb 2009 17:15:25 +0800
Message-ID: <49895CAD.1020008__3270.88628332621$1233739312$gmane$org@cn.fujitsu.com>
References: <49895BD7.8090405@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49895BD7.8090405-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> I enabled all cgroup subsystems when compiling kernel, and then:
>  # mount -t cgroup -o net_cls xxx /mnt
>  # mkdir /mnt/0
> 
> This showed up immediately:
>  BUG: MAX_LOCKDEP_SUBCLASSES too low!
>  turning off the locking correctness validator.
> 
> It's caused by the cgroup hierarchy lock:
> 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> 		struct cgroup_subsys *ss = subsys[i];
> 		if (ss->root == root)
> 			mutex_lock_nested(&ss->hierarchy_mutex, i);
> 	}
> 
> Now we have 9 cgroup subsystems, and the above 'i' for net_cls is 9, but

sorry, a typo here: the above 'i' for net_cls is 8.

> MAX_LOCKDEP_SUBCLASSES is 8.
> 
> This patch uses different lockdep keys for different subsystems.
> 
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
