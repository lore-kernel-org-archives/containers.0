From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 0/2] CGroups: cgroup member list enhancement/fix
Date: Sun, 5 Jul 2009 12:08:50 +0530
Message-ID: <20090705063850.GX11273__4086.77935270152$1246776041$gmane$org@balbir.in.ibm.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090702231814.3969.44308.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
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
Cc: lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

* menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> [2009-07-02 16:26:15]:

> The following series (written by Ben Blum) adds a "cgroup.procs" file
> to each cgroup that reports unique tgids rather than pids, and fixes a
> pid namespace bug in the existing "tasks" file that could cause
> readers in different namespaces to interfere with one another.
> 
> The patches as a pair provide similar functionality to Li Zefan's
> patch posted yesterday, with the addition on the "cgroup.procs" file;
> if it's decided that Li's patch needs to be fast-tracked to 2.6.31,
> then these patches can be rebased as a small extension of Li's patch;
> if Li'z patch doesn't need to go to 2.6.31 then it makes more sense to
> take this pair since they provide more overall functionality.
>

Paul, I don't see an interface to migrate all procs or at-least I
can't read it in the changelog. As discussed in the containers
mini-summit in 2008, it would be a nice thing to have (I've not looked
at the implementation yet).
 
> ---
> 
> Ben Blum (2):
>       Adds a read-only "procs" file similar to "tasks" that shows only unique tgids
>       Ensures correct concurrent opening/reading of pidlists across pid namespaces
> 
> 
>  include/linux/cgroup.h |   46 +++++-
>  kernel/cgroup.c        |  355 +++++++++++++++++++++++++++++++++---------------
>  2 files changed, 285 insertions(+), 116 deletions(-)
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

-- 
	Balbir
