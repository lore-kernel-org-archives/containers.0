From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 06/10] cgroup: convert memcg controller to the new cftype
	interface
Date: Wed, 21 Mar 2012 13:42:39 +0900
Message-ID: <4F695C3F.3000406@jp.fujitsu.com>
References: <1331940963-15756-1-git-send-email-tj@kernel.org>
	<1331940963-15756-7-git-send-email-tj@kernel.org>
	<4F66B55A.8020307@jp.fujitsu.com>
	<20120319161052.GC11069@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120319161052.GC11069-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/03/20 1:10), Tejun Heo wrote:

> Hello,
> 
> On Mon, Mar 19, 2012 at 01:26:02PM +0900, KAMEZAWA Hiroyuki wrote:
>>> +CGROUP_SUBSYS_CFTYPES_COND(mem_cgroup_subsys, memsw_cgroup_files,
>>> +			   really_do_swap_account);
>>
>>
>> I'm sorry but why you use really_do_swap_account instead of do_swap_account ?
> 
> Because do_swap_account is initialized too late.
> CGROUP_SUBSYS_CFTYPES() are processed via fs_initcall().  AFAICS,
> do_swap_account may not have been initialized by then.  Also, if memcg
> as whole is disabled, it doesn't matter whether those files are
> registered or not, right?  We probably need some comment there tho.
> 


I think creating file based on really_do_swap_account is wrong.
(I'm sorry for this complication.)

How about creating this file unconditionally ? Returning -ENOTSUP in memcg's
handler will work well...anyway it's configured, no reason to show them is bad.

Thanks,
-Kame
