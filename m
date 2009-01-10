From: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] cgroups: consolidate cgroup documents
Date: Fri, 9 Jan 2009 16:19:47 -0800
Message-ID: <20090109161947.70f6d73d.rdunlap__19785.9938875355$1231546989$gmane$org@xenotime.net>
References: <4966B383.3030106@cn.fujitsu.com>
	<20090109223442.GO9737@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090109223442.GO9737-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, KAMEZAWA-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, 10 Jan 2009 04:04:42 +0530 Balbir Singh wrote:

> * Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> [2009-01-09 10:16:35]:
> 
> > Move Documentation/cpusets.txt and Documentation/controllers/* to
> > Documentation/cgroups/
> > 
> > This inlined patch is generated with git-show -M (rename detected)
> > and is for review, and the attached one is for apply.
> > 
> > Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> > ---
> >  Documentation/cgroups/cgroups.txt            |    5 +++--
> >  Documentation/cgroups/memcg_test.txt         |    2 +-
> >  Documentation/scheduler/sched-design-CFS.txt |    2 +-
> >  include/linux/res_counter.h                  |    2 +-
> >  init/Kconfig                                 |    9 ++++-----
> >  kernel/cpuset.c                              |    2 +-
> >  11 files changed, 11 insertions(+), 11 deletions(-)
> > 
> >  rename Documentation/{controllers => cgroups}/cpuacct.txt (100%)
> >  rename Documentation/{ => cgroups}/cpusets.txt (100%)
> >  rename Documentation/{controllers => cgroups}/devices.txt (100%)
> >  rename Documentation/{controllers => cgroups}/memcg_test.txt (99%)
> >  rename Documentation/{controllers => cgroups}/memory.txt (100%)
> >  rename Documentation/{controllers => cgroups}/resource_counter.txt (100%)
> > 
> > diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
> > index e33ee74..d9e5d6f 100644
> 
> I think it is a good idea to consolidate it all in one place.

I'm for that also, but I thought that cpusets existed regardless of
cgroups/controllers.  Maybe I'm wrong?


> Acked-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>


---
~Randy
