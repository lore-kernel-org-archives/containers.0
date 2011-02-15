From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH, v6 3/3] cgroups: introduce timer slack controller
Date: Tue, 15 Feb 2011 02:10:04 +0200
Message-ID: <20110215001004.GA6644__28224.5438000702$1297871021$gmane$org@shutemov.name>
References: <1297688787-3592-1-git-send-email-kirill@shutemov.name>
	<1297688787-3592-4-git-send-email-kirill@shutemov.name>
	<20110214135926.GO16432@count0.beaverton.ibm.com>
	<20110214225940.GB6230@shutemov.name>
	<20110215000055.GR16432@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110215000055.GR16432-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 14, 2011 at 04:00:55PM -0800, Matt Helsley wrote:
> On Tue, Feb 15, 2011 at 12:59:40AM +0200, Kirill A. Shutemov wrote:
> > On Mon, Feb 14, 2011 at 05:59:26AM -0800, Matt Helsley wrote:
> > > On Mon, Feb 14, 2011 at 03:06:27PM +0200, Kirill A. Shutsemov wrote:
> > > > From: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> 
> <snip>
> 
> > > > +	list_for_each_entry(cur, &cgroup->children, sibling) {
> > > > +		child = cgroup_to_tslack_cgroup(cur);
> > > > +		if (type == TIMER_SLACK_MIN && val > child->min_slack_ns)
> > > > +			return -EBUSY;
> > > > +		if (type == TIMER_SLACK_MAX && val < child->max_slack_ns)
> > > > +			return -EBUSY;
> > > > +	}
> > > 
> > > This doesn't look right. Child cgroups should not constrain their
> > > parents. Instead you should allow the change and propagate the
> > > constraint to the children.
> > 
> > See discussion with Thomas.
> 
> <OK, shifting this topic to that thread>
> <snip>
> 
> > > > +static struct cftype files[] = {
> > > > +	{
> > > > +		.name = "set_slack_ns",
> > > > +		.write_u64 = tslack_write_set_slack_ns,
> > > > +	},
> > > > +	{
> > > > +		.name = "min_slack_ns",
> > > > +		.private = TIMER_SLACK_MIN,
> > > > +		.read_u64 = tslack_read_range,
> > > > +		.write_u64 = tslack_write_range,
> > > > +	},
> > > > +	{
> > > > +		.name = "max_slack_ns",
> > > > +		.private = TIMER_SLACK_MAX,
> > > > +		.read_u64 = tslack_read_range,
> > > > +		.write_u64 = tslack_write_range,
> > > > +	},
> > > 
> > > I didn't get a reply on how a max_slack_ns is useful. It seems
> > > prudent to add as little interface as possible and only when
> > > we clearly see the utility of it.
> > 
> > For example, you can create two groups (excluding root cgroup):
> > 
> > default - timer slack range 50000-50000
> > relaxed - timer slack range 500000-unlimited.
> > 
> > Now you can drag tasks between these group without need to reset value on
> > relaxed -> default transition.
> 
> Perhaps you misunderstood my point.
> 
> Yes, I can see that a maximum allows you to do counter-productive/pointless
> little tricks like "setting" the timer slack when you move the task. I
> just don't get the point of it. Why is setting a maximum timer slack useful?
> If anything it seems like it would be quite counterproductive or pointless
> *at best* because limiting the amount of timer slack would not improve
> the wakeup situation -- it could easily make it worse. Are there
> *any* negative consequences to allowing timer slacks as large as
> userspace requests -- perhaps even up to ULLONG_MAX? If there are none then
> why should we bother providing userspace a knob to set and enforce such a
> limit?

Could you describe the interface how you see it?

-- 
 Kirill A. Shutemov
