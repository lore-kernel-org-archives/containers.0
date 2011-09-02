From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH pm-freezer 1/4] cgroup_freezer: fix freezer->state
	setting bug in freezer_change_state()
Date: Fri, 2 Sep 2011 11:50:16 +0900
Message-ID: <20110902025016.GI2752__16182.3560986251$1314933621$gmane$org@htj.dyndns.org>
References: <20110831102100.GA2828@mtj.dyndns.org>
	<20110902004231.GF1919@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110902004231.GF1919-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Matt.

On Thu, Sep 01, 2011 at 05:42:31PM -0700, Matt Helsley wrote:
> >  	case CGROUP_FROZEN:
> > -		atomic_inc(&system_freezing_cnt);
> > -		retval = try_to_freeze_cgroup(cgroup, freezer);
> > +		if (freezer->state == CGROUP_THAWED) {
> > +			freezer->state = CGROUP_FREEZING;
> > +			atomic_inc(&system_freezing_cnt);
> > +			retval = try_to_freeze_cgroup(cgroup, freezer);
> 
> This still doesn't look quite right. If the cgroup is FREEZING it should
> also call try_to_freeze_cgroup(). I think this is what's needed:
> 
> 		if (freezer->state == CGROUP_THAWED)
> 			atomic_inc(&system_freezing_cnt);
> 		freezer->state = CGROUP_FREEZING;
> 		retval = try_to_freeze_cgroup(cgroup, freezer);

Does this make any difference?  Tasks can't migrate if the cgroups are
freezing and freezing state is inherited through forks.  But yeah
doing that for both THAWED and FROZEN might still be a good idea for
safety.

Thanks.

-- 
tejun
