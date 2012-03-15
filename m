From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC REPOST] cgroup: removing css reference drain wait during
	cgroup removal
Date: Thu, 15 Mar 2012 09:16:33 +0900
Message-ID: <4F6134E1.5090601__45791.8515465737$1331770719$gmane$org@jp.fujitsu.com>
References: <20120312213155.GE23255@google.com>
	<20120312213343.GF23255@google.com>
	<20120313151148.f8004a00.kamezawa.hiroyu@jp.fujitsu.com>
	<20120313163914.GD7349@google.com>
	<20120314092828.3321731c.kamezawa.hiroyu@jp.fujitsu.com>
	<4F6068F4.4090909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4F6068F4.4090909-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

(2012/03/14 18:46), Glauber Costa wrote:

> On 03/14/2012 04:28 AM, KAMEZAWA Hiroyuki wrote:
>> IIUC, in general, even in the processes are in a tree, in major case
>> of servers, their workloads are independent.
>> I think FLAT mode is the dafault. 'heararchical' is a crazy thing which
>> cannot be managed.
> 
> Better pay attention to the current overall cgroups discussions being 
> held by Tejun then. ([RFD] cgroup: about multiple hierarchies)
> 
> The topic of whether of adapting all cgroups to be hierarchical by 
> deafult is a recurring one.
> 
> I personally think that it is not unachievable to make res_counters 
> cheaper, therefore making this less of a problem.
> 


I thought of this a little yesterday. Current my idea is applying following
rule for res_counter.

1. All res_counter is hierarchical. But behavior should be optimized.

2. If parent res_counter has UNLIMITED limit, 'usage' will not be propagated
   to its parent at _charge_.

3. If a res_counter has UNLIMITED limit, at reading usage, it must visit
   all children and returns a sum of them.

Then,
	/cgroup/
		memory/                       (unlimited)
			libivirt/             (unlimited)
				 qeumu/       (unlimited)
				        guest/(limited)

All dir can show hierarchical usage and the guest will not have
any lock contention at runtime.


By this
 1. no runtime overhead if the parent has unlimited limit.
 2. All res_counter can show aggregate resource usage of children.

To do this
 1. res_coutner should have children list by itself.

Implementation problem
 - What should happens when a user set new limit to a res_counter which have
   childrens ? Shouldn't we allow it ? Or take all locks of children and
   update in atomic ?
 - memory.use_hierarchy should be obsolete ?

Other problem I'm not sure at all
 - blkcg doesn't support hierarchy at all.

Hmm. 

Thanks,
-Kame
