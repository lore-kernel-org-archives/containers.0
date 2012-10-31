From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 1/8] cgroup: kill
	cgroup_subsys->__DEPRECATED_clear_css_refs
Date: Wed, 31 Oct 2012 21:14:16 +0100
Message-ID: <20121031201415.GG1271@dhcp22.suse.cz>
References: <1351712650-23709-1-git-send-email-tj@kernel.org>
	<1351712650-23709-2-git-send-email-tj@kernel.org>
	<20121031200859.GE1271@dhcp22.suse.cz>
	<CAOS58YPbYoMJ1+3uRfK_ZERyZoaby=FPW7uTpp8dVOSgYC8Mrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAOS58YPbYoMJ1+3uRfK_ZERyZoaby=FPW7uTpp8dVOSgYC8Mrw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed 31-10-12 13:11:02, Tejun Heo wrote:
> Hello,
> 
> On Wed, Oct 31, 2012 at 1:08 PM, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org> wrote:
> > local_irq_disable doesn't guarantee atomicity, because other CPUs will
> 
> Maybe it should say atomicity on the local CPU.

That would be more clear but being more verbose doesn't hurt either :P

> > see the change in steps so this is a bit misleading. The real reason
> > AFAICS is that we do not want to hang in css_tryget from IRQ context
> > (does this really happen btw.?) which would interrupt cgroup_rmdir
> > between we add CSS_DEACT_BIAS and the group is marked CGRP_REMOVED.
> > Or am I still missing the point?
> 
> Yeah, that's the correct one. We don't want tryget happening between
> DEACT_BIAS and REMOVED as it can hang forever there.

-- 
Michal Hocko
SUSE Labs
