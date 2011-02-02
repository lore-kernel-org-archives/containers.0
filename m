From: jacob pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [RFC PATCH 2/2] cgroup/freezer: add per freezer duty ratio control
Date: Wed, 2 Feb 2011 11:32:53 -0800
Message-ID: <20110202113253.789a2a85__30617.2567456544$1296675391$gmane$org@putvin>
References: <1291230012-9536-1-git-send-email-jacob.jun.pan@linux.intel.com>
	<1291230012-9536-3-git-send-email-jacob.jun.pan@linux.intel.com>
	<20110201142301.GA23803@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110201142301.GA23803-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
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
Cc: container cgroup <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 1 Feb 2011 16:23:01 +0200
"Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:

Thanks for your review, I will fix the error handling. Please also see
my comments on create vs populate.
> On Wed, Dec 01, 2010 at 11:00:12AM -0800,
> jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org wrote:
> > From: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
>
> > +#define FREEZER_KH_PREFIX  "freezer_"
> >  static int freezer_populate(struct cgroup_subsys *ss, struct
> > cgroup *cgroup) {
> > +	int ret = 0;
> > +	char thread_name[32];
> > +	struct freezer *freezer;
> > +
> >  	if (!cgroup->parent)
> >  		return 0;
> > -	return cgroup_add_files(cgroup, ss, files,
> > ARRAY_SIZE(files)); +
> > +	freezer = cgroup_freezer(cgroup);
> > +	ret = cgroup_add_files(cgroup, ss, files,
> > ARRAY_SIZE(files)); +
> > +	snprintf(thread_name, 32, "%s%s", FREEZER_KH_PREFIX,
> > +		cgroup->dentry->d_name.name);
> > +	freezer->fkh = kthread_run(freezer_kh, (void *)cgroup,
> > thread_name);
> > +	if (!IS_ERR(freezer_task))
> > +		return 0;
> > +	return ret;
> 
> Why do you create on freezer_populate, not on freezer_create?
I want to use the cgroup directory name for the kernel thread. If I do
that in create() instead of populate, I would have to add more changes:
1. pass dentry to the create function since that is called before
  cgroup_create_dir()
2. skip the dummy root as part of the initialization.
So I chose to use populate, are there any issues with the functionality?
