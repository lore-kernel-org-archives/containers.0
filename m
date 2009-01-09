From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] cgroups: consolidate cgroup documents
Date: Sat, 10 Jan 2009 04:04:42 +0530
Message-ID: <20090109223442.GO9737__47677.5887691931$1231540993$gmane$org@balbir.in.ibm.com>
References: <4966B383.3030106@cn.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4966B383.3030106-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

* Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> [2009-01-09 10:16:35]:

> Move Documentation/cpusets.txt and Documentation/controllers/* to
> Documentation/cgroups/
> 
> This inlined patch is generated with git-show -M (rename detected)
> and is for review, and the attached one is for apply.
> 
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  Documentation/cgroups/cgroups.txt            |    5 +++--
>  Documentation/cgroups/memcg_test.txt         |    2 +-
>  Documentation/scheduler/sched-design-CFS.txt |    2 +-
>  include/linux/res_counter.h                  |    2 +-
>  init/Kconfig                                 |    9 ++++-----
>  kernel/cpuset.c                              |    2 +-
>  11 files changed, 11 insertions(+), 11 deletions(-)
> 
>  rename Documentation/{controllers => cgroups}/cpuacct.txt (100%)
>  rename Documentation/{ => cgroups}/cpusets.txt (100%)
>  rename Documentation/{controllers => cgroups}/devices.txt (100%)
>  rename Documentation/{controllers => cgroups}/memcg_test.txt (99%)
>  rename Documentation/{controllers => cgroups}/memory.txt (100%)
>  rename Documentation/{controllers => cgroups}/resource_counter.txt (100%)
> 
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
> index e33ee74..d9e5d6f 100644

I think it is a good idea to consolidate it all in one place.

Acked-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

-- 
	Balbir
