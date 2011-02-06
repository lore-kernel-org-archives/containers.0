From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH, v3 2/2] cgroups: introduce timer slack subsystem
Date: Sat, 5 Feb 2011 18:49:51 -0800
Message-ID: <20110206024951.GB16432__10124.3108547807$1296960659$gmane$org@count0.beaverton.ibm.com>
References: <1296679656-31163-1-git-send-email-kirill@shutemov.name>
	<1296679656-31163-3-git-send-email-kirill@shutemov.name>
	<20110203054616.GT16432@count0.beaverton.ibm.com>
	<20110203094138.GD1083@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110203094138.GD1083-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Feb 03, 2011 at 11:41:38AM +0200, Kirill A. Shutemov wrote:
> On Wed, Feb 02, 2011 at 09:46:16PM -0800, Matt Helsley wrote:
> > On Wed, Feb 02, 2011 at 10:47:36PM +0200, Kirill A. Shutsemov wrote:
> > > From: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>

<snip>

> > > diff --git a/kernel/cgroup_timer_slack.c b/kernel/cgroup_timer_slack.c
> > > new file mode 100644
> > > index 0000000..a343a50
> > > --- /dev/null
> > > +++ b/kernel/cgroup_timer_slack.c

<snip>

> > > +static int tslack_write_set_slack_ns(struct cgroup *cgroup, struct cftype *cft,
> > > +		u64 val)
> > > +{
> > > +	struct timer_slack_cgroup *tslack_cgroup;
> > > +	struct cgroup_iter it;
> > > +	struct task_struct *task;
> > > +
> > > +	tslack_cgroup = cgroup_to_tslack_cgroup(cgroup);
> > > +	if (!val || val < tslack_cgroup->min_slack_ns ||
> > 
> > Why is a val of 0 disallowed? I know having slack is good, but for
> > an administrator or tool that doesn't care about number of wakeups
> > and cares more about wringing out performance a slack of
> > 0 seems acceptable. Is this just here to be consistent with the
> > values passed in via prctl?
> 
> Yes, it's to consistent with the prctl(). I don't think that it's good
> idea to allow to set timer_slack outside of range prctl() allows. It may
> lead to interface abuse.

Hmm, I was just thinking that 0 timer slack might be useful. But I
suppose you could just as easily set it to 1 and nobody would notice.

> > > +			val > tslack_cgroup->max_slack_ns )
> > > +		return -EINVAL;
> > 
> > Shouldn't it be EPERM and not EINVAL?
> > 
> > The write(2) man page says: "Other errors may occur, depending on the
> > object connected to fd." So I think EPERM is fine and more descriptive.
> 
> What do you think about -EINVAL for (val == 0) and -EPERM for rest?

OK, that makes sense to me given both of our points above.

Cheers,
	-Matt Helsley
