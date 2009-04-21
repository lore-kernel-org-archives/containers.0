From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 3/9] bio-cgroup controller
Date: Tue, 21 Apr 2009 20:39:17 +0900 (JST)
Message-ID: <20090421.203917.189725396.ryov__43453.6818218932$1240314251$gmane$org@valinux.co.jp>
References: <20090417102214.GC3896@balbir.in.ibm.com>
	<20090420.203540.104031006.ryov@valinux.co.jp>
	<20090420145658.GB13307@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090420145658.GB13307@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Andrea,

> On Mon, Apr 20, 2009 at 08:35:40PM +0900, Ryo Tsuruta wrote:
> > > > +/*
> > > > + * Assign "page" the same owner as "opage."
> > > > + */
> > > > +void bio_cgroup_copy_owner(struct page *npage, struct page *opage)
> > > > +{
> > > > +	struct page_cgroup *npc, *opc;
> > > > +
> > > > +	if (bio_cgroup_disabled())
> > > > +		return;
> > > > +	npc = lookup_page_cgroup(npage);
> > > > +	if (unlikely(!npc))
> > > > +		return;
> > > > +	opc = lookup_page_cgroup(opage);
> > > > +	if (unlikely(!opc))
> > > > +		return;
> > > > +
> > > > +	/*
> > > > +	 * Do this without any locks. The reason is the same as
> > > > +	 * bio_cgroup_reset_owner().
> > > > +	 */
> > > > +	npc->bio_cgroup_id = opc->bio_cgroup_id;
> > > 
> > > What protects npc and opc?
> > 
> > As the same reason mentioned above, bio_cgroup_id can be updated
> > without any locks, and npc and opc always point to page_cgroups.
> > An integer variable can be set a new value at once on a system which
> > can use RCU lock.
> 
> mmmh... I'm not sure about this. Actually you read opc->bio_cgroup_id
> first and then write to npc->bio_cgroup_id, so it is not atomic at all.
> So, you can read or set a wrong ID, but at least it should be always
> consistent (the single read or write itself is atomic).

Even if opc->bio_cgroup_id is changed before copying to
npc->bio_cgroup_id, npc->bio_cgroup_id is correctly updated at some time.
The implementation is not completely accurate, but is faster and lighter.

Thanks,
Ryo Tsuruta
