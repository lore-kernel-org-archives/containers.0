From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 08/12] cgroup, memcg: move cgroup->event_list[_lock] and
	event callbacks into memcg
Date: Wed, 4 Sep 2013 09:11:15 +0200
Message-ID: <20130904071115.GA7375@dhcp22.suse.cz>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
	<1376582550-12548-9-git-send-email-tj@kernel.org>
	<20130830110846.GB31605@dhcp22.suse.cz>
	<20130903215646.GA31091@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130903215646.GA31091-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue 03-09-13 17:56:46, Tejun Heo wrote:
> Hello, Michal.
> 
> On Fri, Aug 30, 2013 at 01:08:46PM +0200, Michal Hocko wrote:
> > On Thu 15-08-13 12:02:26, Tejun Heo wrote:
> > [...]
> > > @@ -6030,12 +6050,13 @@ static void cgroup_event_ptable_queue_proc(struct file *file,
> > >  static int cgroup_write_event_control(struct cgroup_subsys_state *css,
> > >  				      struct cftype *cft, const char *buffer)
> > >  {
> > > -	struct cgroup *cgrp = css->cgroup;
> > > +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> > >  	struct cgroup_event *event;
> > >  	struct cgroup_subsys_state *cfile_css;
> > >  	unsigned int efd, cfd;
> > >  	struct file *efile;
> > >  	struct file *cfile;
> > > +	const char *name;
> > >  	char *endp;
> > >  	int ret;
> > 
> > AFAICS nothing prevents from registering a new event after css_offline
> > is done already which would lead to a mem leak. The we would need to do
> > css_tryget somewhere in the beginning. Or is there anything that would
> > prevent from that?
> 
> An earlier patch titled "cgroup: make cgroup_event hold onto
> cgroup_subsys_state instead of cgroup" updates cgroup_event such that
> each cgroup_event acquires a css reference using css_tryget(), so if a
> css has already been offlined, no new event will be created.

Right you are. Sorry I have missed/forgot about the patch. The patch is
ok then and you can add my acked-by.

Thanks and sorry about the noise.
-- 
Michal Hocko
SUSE Labs
