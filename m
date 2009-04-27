From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/9] io-throttle documentation
Date: Mon, 27 Apr 2009 23:56:52 +0200
Message-ID: <20090427215650.GB3606@linux>
References: <20090417102539.GA16838@linux>
	<20090420.183815.226804723.ryov@valinux.co.jp>
	<20090420150052.GC13307@linux>
	<20090427.194533.183037823.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090427.194533.183037823.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 27, 2009 at 07:45:33PM +0900, Ryo Tsuruta wrote:
> Hi Andrea,
> 
> From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Subject: Re: [PATCH 1/9] io-throttle documentation
> Date: Mon, 20 Apr 2009 17:00:53 +0200
> 
> > On Mon, Apr 20, 2009 at 06:38:15PM +0900, Ryo Tsuruta wrote:
> > > Hi Andrea, 
> > > 
> > > > Implementing bio-cgroup functionality as pure infrastructure framework
> > > > instead of a cgroup subsystem would remove all this oddity and
> > > > complexity.
> > > > 
> > > > For example, the actual functionality that I need for the io-throttle
> > > > controller is just an interface to set and get the cgroup owner of a
> > > > page. I think it should be the same also for other potential users of
> > > > bio-cgroup.
> > > > 
> > > > So, what about implementing the bio-cgroup functionality as cgroup "page
> > > > tracking" infrastructure and provide the following interfaces:
> > > > 
> > > > /*
> > > >  * Encode the cgrp->css.id in page_group->flags
> > > >  */
> > > > void set_cgroup_page_owner(struct page *page, struct cgroup *cgrp);
> > > > 
> > > > /*
> > > >  * Returns the cgroup owner of a page, decoding the cgroup id from
> > > >  * page_cgroup->flags.
> > > >  */
> > > > struct cgroup *get_cgroup_page_owner(struct page *page);
> > > > 
> > > > This also wouldn't increase the size of page_cgroup because we can
> > > > encode the cgroup id in the unused bits of page_cgroup->flags, as
> > > > originally suggested by Kame.
> > > > 
> > > > And I think it could be used also by dm-ioband, even if it's not a
> > > > cgroup-based subsystem... but I may be wrong. Ryo what's your opinion?
> 
> I've come up with an idea to coexist blkio-cgroup and io-throttle.
> blkio-cgroup provides a function to get a cgroup with the specified ID.
> 
> /* Should be called under rcu_read_lock() */
> struct cgroup *blkio_cgroup_lookup(int id)
> {
> 	struct cgroup *cgrp;
> 	struct cgroup_subsys_state *css;
> 	
> 	if (blkio_cgroup_disabled())
> 		return NULL;
> 
> 	css = css_lookup(&blkio_cgroup_subsys, id);
> 	if (!css)
> 		return NULL;
> 	cgrp = css->cgroup;
> 	return cgrp;
> }
> 
> Then io-throttle can get a struct iothrottle which belongs to the
> cgroup by using the above function.
> 
> static struct iothrottle *iothrottle_lookup(int id)
> {
> 	struct cgroup *grp;
> 	struct iothrottle *iot;
> 
> 	...
> 	grp = blkio_cgroup_lookup(id);
> 	if (!grp)
> 		return NULL
> 	iot = cgroup_to_iothrottle(grp);
> 	...
> }
> 
> What do you think about this way?

Hi Ryo,

this should be ok for io-throttle. But I'd still prefer to see
blkio-cgroup implemented as an infrastructure, instead of a cgroup. This
would avoid (at least for io-throttle) the need to mount io-throttle
together with blkio-cgroup or provide complicate ways to associate
io-throttle groups with blkio-cgroup groups.

Thanks,
-Andrea
