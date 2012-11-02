From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/8] cgroup: kill
	cgroup_subsys->__DEPRECATED_clear_css_refs
Date: Fri, 02 Nov 2012 19:01:45 +0900
Message-ID: <50939A09.9070507@jp.fujitsu.com>
References: <1351712650-23709-1-git-send-email-tj@kernel.org>
	<1351712650-23709-2-git-send-email-tj@kernel.org>
	<20121031200859.GE1271@dhcp22.suse.cz>
	<CAOS58YPbYoMJ1+3uRfK_ZERyZoaby=FPW7uTpp8dVOSgYC8Mrw@mail.gmail.com>
	<20121031201415.GG1271@dhcp22.suse.cz>
	<20121031202400.GT2945@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121031202400.GT2945-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/11/01 5:24), Tejun Heo wrote:
> On Wed, Oct 31, 2012 at 09:14:16PM +0100, Michal Hocko wrote:
>> On Wed 31-10-12 13:11:02, Tejun Heo wrote:
>>> Hello,
>>>
>>> On Wed, Oct 31, 2012 at 1:08 PM, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org> wrote:
>>>> local_irq_disable doesn't guarantee atomicity, because other CPUs will
>>>
>>> Maybe it should say atomicity on the local CPU.
>>
>> That would be more clear but being more verbose doesn't hurt either :P
>>
>>>> see the change in steps so this is a bit misleading. The real reason
>>>> AFAICS is that we do not want to hang in css_tryget from IRQ context
>>>> (does this really happen btw.?) which would interrupt cgroup_rmdir
>>>> between we add CSS_DEACT_BIAS and the group is marked CGRP_REMOVED.
>>>> Or am I still missing the point?
>>>
>>> Yeah, that's the correct one. We don't want tryget happening between
>>> DEACT_BIAS and REMOVED as it can hang forever there.
>
> Here's the updated description.  git branch updated accordingly.
>
> Thanks.
>
> From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Subject: cgroup: kill cgroup_subsys->__DEPRECATED_clear_css_refs
>
> 2ef37d3fe4 ("memcg: Simplify mem_cgroup_force_empty_list error
> handling") removed the last user of __DEPRECATED_clear_css_refs.  This
> patch removes __DEPRECATED_clear_css_refs and mechanisms to support
> it.
>
> * Conditionals dependent on __DEPRECATED_clear_css_refs removed.
>
> * cgroup_clear_css_refs() can no longer fail.  All that needs to be
>    done are deactivating refcnts, setting CSS_REMOVED and putting the
>    base reference on each css.  Remove cgroup_clear_css_refs() and the
>    failure path, and open-code the loops into cgroup_rmdir().
>
> This patch keeps the two for_each_subsys() loops separate while open
> coding them.  They can be merged now but there are scheduled changes
> which need them to be separate, so keep them separate to reduce the
> amount of churn.
>
> local_irq_save/restore() from cgroup_clear_css_refs() are replaced
> with local_irq_disable/enable() for simplicity.  This is safe as
> cgroup_rmdir() is always called with IRQ enabled.  Note that this IRQ
> switching is necessary to ensure that css_tryget() isn't called from
> IRQ context on the same CPU while lower context is between CSS
> deactivation and setting CSS_REMOVED as css_tryget() would hang
> forever in such cases waiting for CSS to be re-activated or
> CSS_REMOVED set.  This will go away soon.
>
> v2: cgroup_call_pre_destroy() removal dropped per Michal.  Commit
>      message updated to explain local_irq_disable/enable() conversion.
>
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

I should see this v2 thread 1st...

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
