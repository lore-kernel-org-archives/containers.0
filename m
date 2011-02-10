From: jacob pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH 1/1, v6] cgroup/freezer: add per freezer duty ratio control
Date: Wed, 9 Feb 2011 20:51:33 -0800
Message-ID: <20110209205133.5146a9fb__46319.4045042202$1297313614$gmane$org@jacob-laptop>
References: <1297213541-18156-1-git-send-email-jacob.jun.pan@linux.intel.com>
	<4D52050F.3060907@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D52050F.3060907-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: container cgroup <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 09 Feb 2011 11:07:59 +0800
Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:


> >  
> > +#define FREEZER_KH_PREFIX  "freezer_"
> > +static int freezer_write_param(struct cgroup *cgroup, struct
> > cftype *cft,
> > +		u64 val)
> > +{
> > +	struct freezer *freezer;
> > +	char thread_name[32];
> > +	int ret = 0;
> > +
> > +	freezer = cgroup_freezer(cgroup);
> > +
> > +	if (!cgroup_lock_live_group(cgroup))
> > +		return -ENODEV;
> > +
> > +	switch (cft->private) {
> > +	case FREEZER_DUTY_RATIO:
> > +		if (val >= 100 || val < 0) {
> 
> val will never < 0.
good point, I will fix it.

> 
> > +			ret = -EINVAL;
> > +			goto exit;
> > +		}
> > +		freezer->duty.ratio = val;
> > +		break;
> > +	case FREEZER_PERIOD:
> > +		if (val)
> > +			do_div(val, 100);
> 
> Is 0 an invalid value for do_div()?
0 is valid. I was thinking about divide by 0 by mistake. will fix it.

> 
> > +			freezer->duty.period_pct_ms = val;
> > +		break;
> > +	default:
> > +		BUG();
> > +	}
> > +
> > +	/* start/stop management kthread as needed, the rule is
> > that
> > +	 * if both duty ratio and period values are zero, then no
> > management
> > +	 * kthread is created. when both are non-zero, we create a
> > kthread
> > +	 * for the cgroup. When user set zero to duty ratio and
> > period again
> > +	 * the kthread is stopped.
> > +	 */
> > +	if (freezer->duty.ratio && freezer->duty.period_pct_ms) {
> > +		if (!freezer->fkh) {
> > +			snprintf(thread_name, 32, "%s%s",
> > FREEZER_KH_PREFIX,
> > +				cgroup->dentry->d_name.name);
> > +			freezer->fkh = kthread_run(freezer_kh,
> > (void *)cgroup,
> > +						thread_name);
> > +			if (IS_ERR(freezer_task)) {
> 
> You mean IS_ERR(freezer->fkh)?
Right, same bug for PTR_ERR. will fix.

thanks.
