From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 7/9] cgroup_freezer: introduce
	CGROUP_FREEZING_[SELF|PARENT]
Date: Thu, 08 Nov 2012 13:56:52 +0900
Message-ID: <509B3B94.1070407__13338.1251282573$1352350645$gmane$org@jp.fujitsu.com>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-8-git-send-email-tj@kernel.org>
	<509B382E.4030707@jp.fujitsu.com>
	<20121108044521.GH2660@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121108044521.GH2660-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/11/08 13:45), Tejun Heo wrote:
> Hello,
>
> On Thu, Nov 08, 2012 at 01:42:22PM +0900, Kamezawa Hiroyuki wrote:
>> (2012/11/03 17:38), Tejun Heo wrote:
>>> Introduce FREEZING_SELF and FREEZING_PARENT and make FREEZING OR of
>>> the two flags.  This is to prepare for full hierarchy support.
>>>
>>> freezer_apply_date() is updated such that it can handle setting and
>>> clearing of both flags.  The two flags are also exposed to userland
>>> via read-only files self_freezing and parent_freezing.
>>>
>>> Other than the added cgroupfs files, this patch doesn't introduce any
>>> behavior change.
>>>
>>> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>>
>> What is the purpose of FREEZING_SELG/PARENT, having 2 flags and
>> make it visible to users ?
>
> SELF is the configuration of the current cgroup, PARENT is freezing
> state inherited from an ancestor.  If either is set, the cgroup is
> freezing.  Without the two conditions visible to userland, it can get
> a bit confusing as echoing "THAWED" to state may not do anything to
> the cgroup.
>
Got it, thank you. I'm glad if you add some more explanation in comments
and considered use-case in changelog.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

Thanks,
-Kame
