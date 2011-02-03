From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH, v3 2/2] cgroups: introduce timer slack subsystem
Date: Wed, 2 Feb 2011 21:48:26 -0800
Message-ID: <20110203054826.GU16432__35884.3286442154$1296712154$gmane$org@count0.beaverton.ibm.com>
References: <1296679656-31163-1-git-send-email-kirill@shutemov.name>
	<1296679656-31163-3-git-send-email-kirill@shutemov.name>
	<AANLkTikAbmFmQNGgYMYhTOS8L5nU39edcTjQXNpdxGy2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikAbmFmQNGgYMYhTOS8L5nU39edcTjQXNpdxGy2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 02, 2011 at 03:23:15PM -0800, Paul Menage wrote:
> On Wed, Feb 2, 2011 at 12:47 PM, Kirill A. Shutsemov
<kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:
> > +static int tslack_write_range(struct cgroup *cgroup, struct cftype *cf=
t,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 val)
> > +{
> > + =A0 =A0 =A0 struct timer_slack_cgroup *tslack_cgroup;
> > + =A0 =A0 =A0 struct cgroup_iter it;
> > + =A0 =A0 =A0 struct task_struct *task;
> > +
> > + =A0 =A0 =A0 if (!val)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> > +
> > + =A0 =A0 =A0 tslack_cgroup =3D cgroup_to_tslack_cgroup(cgroup);
> > + =A0 =A0 =A0 switch (cft->private) {
> > + =A0 =A0 =A0 case TIMER_SLACK_MIN:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (val > tslack_cgroup->max_slack_ns)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tslack_cgroup->min_slack_ns =3D val;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 case TIMER_SLACK_MAX:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (val < tslack_cgroup->min_slack_ns)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tslack_cgroup->max_slack_ns =3D val;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 default:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
> > + =A0 =A0 =A0 }
> > +
> =

> Don't we want to keep the min/max applied hierarchically as well? i.e.
> a child can't set its min/max outside the range of its parents?

That was my expectation as well.

Cheers,
	-Matt Helsley
