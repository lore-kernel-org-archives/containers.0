From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/17] cgroup: create directory before linking while
	creating a new cgroup
Date: Fri, 16 Nov 2012 14:04:29 +0800
Message-ID: <50A5D76D.70805__8301.32816122404$1353045895$gmane$org@huawei.com>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
	<1352775704-9023-5-git-send-email-tj@kernel.org>
	<50A30E0F.7000408@huawei.com>
	<20121114190407.GI21185@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121114190407.GI21185-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2012/11/15 3:04, Tejun Heo wrote:
> Hello, Li.
> 
> On Wed, Nov 14, 2012 at 11:20:47AM +0800, Li Zefan wrote:
>>> It also removes the need to check whether cgroup->dentry is %NULL in
>>> cgroup_path.  If a cgroup is visible, its dentry is guaranteed to be
>>> visible too.
>>
>> I'm afraid this isn't safe.
>>
>> The cgroup is visible to a controller soon after ss->create(), and then
>> the controller might call cgroup_path() while cgrp->dentry is still NULL.
> 
> Hmmm... I can't find any case where ss->create() is calling
> cgroup_path().  Do you remember which one that was?
> 

I meant cgroup_create() may race with cgroup_path(). We used to have
this race:

(cpu0)                          (cpu1)
mkdir                           cat /proc/sched_debug

cgroup_create()
  cpu_cgroup_create()
    register_fair_sched_group()
      list_add_rcu(...)
				print_cfs_stats()
				  for_each_leaf_cfs_rq()
				    print_cfs_rq()
				      cgroup_path()
  css->cgroup = cgroup;
  cgroup->dentry = dentry;

In this case, cgroup_path() might access NULL cgroup or NULL dentry.

But I've looked the current scheduler code, no race anymore, because now the
cfs_rq won't be added to the gloal list until there's task in the cgroup.
(in the old time it was added to the list when creating a cgroup)
