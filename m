From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 3/9] bio-cgroup controller
Date: Thu, 16 Apr 2009 21:00:02 +0900 (JST)
Message-ID: <20090416.210002.193701676.ryov__4945.94730339504$1239883378$gmane$org@valinux.co.jp>
References: <20090415132356.GA19270@linux>
	<20090416085814.8b6d077f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416104234.GA6656@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090416104234.GA6656@linux>
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
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Andrea and Kamezawa-san,

> > > +#ifdef CONFIG_CGROUP_BIO
> > > +/*
> > > + * use lower 16 bits for flags and reserve the rest for the bio-cgroup id
> > > + */
> > > +#define BIO_CGROUP_ID_SHIFT	(16)
> > > +#define BIO_CGROUP_ID_BITS (8 * sizeof(unsigned long) - BIO_CGROUP_ID_SHIFT)
> > > +
> > > +static inline unsigned long page_cgroup_get_bio_id(struct page_cgroup *pc)
> > > +{
> > > +	return pc->flags >> BIO_CGROUP_ID_SHIFT;
> > > +}
> > > +
> > > +static inline void page_cgroup_set_bio_id(struct page_cgroup *pc,
> > > +				unsigned long id)
> > > +{
> > > +	WARN_ON(id >= (1UL << BIO_CGROUP_ID_BITS));
> > > +	pc->flags &= (1UL << BIO_CGROUP_ID_SHIFT) - 1;
> > > +	pc->flags |= (unsigned long)(id << BIO_CGROUP_ID_SHIFT);
> > > +}
> > > +#endif
> > > +
> > Ah, there is "Lock" bit in pc->flags and above "set" code does read-modify-write
> > without lock_page_cgroup().
> > 
> > Could you use lock_page_cgroup() or cmpxchg ? (or using something magical technique ?)
> 
> If I'm not wrong this should guarantee atomicity without using
> lock_page_cgroup().

I'll consider carefully how is the best way to minimize the overhead
as far as possible.
First, I'll post the new bio-cgroup patches that use css_id as
bio_cgroup_id soon.

Thanks,
Ryo Tsuruta
