From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 06/11] cgroups: Add res counter common ancestor searching
Date: Sat, 1 Oct 2011 18:19:49 +0300
Message-ID: <20111001151949.GA28764@shutemov.name>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
 <1315869091-18933-7-git-send-email-fweisbec@gmail.com>
 <20110918195932.GD28057@shutemov.name>
 <20111001150701.GC3391@somewhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111001150701.GC3391@somewhere>
Sender: linux-kernel-owner@vger.kernel.org
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Containers <containers@lists.osdl.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>
List-Id: containers.vger.kernel.org

On Sat, Oct 01, 2011 at 05:07:03PM +0200, Frederic Weisbecker wrote:
> On Sun, Sep 18, 2011 at 10:59:32PM +0300, Kirill A. Shutemov wrote:
> > On Tue, Sep 13, 2011 at 01:11:26AM +0200, Frederic Weisbecker wrote:
> > > Add a new API to find the common ancestor between two resource
> > > counters. This includes the passed resource counter themselves.
> > > 
> > > Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
> > > Acked-by: Paul Menage <paul@paulmenage.org>
> > > Cc: Li Zefan <lizf@cn.fujitsu.com>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: Aditya Kali <adityakali@google.com>
> > > Cc: Oleg Nesterov <oleg@redhat.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Kay Sievers <kay.sievers@vrfy.org>
> > > Cc: Tim Hockin <thockin@hockin.org>
> > > Cc: Tejun Heo <tj@kernel.org>
> > > ---
> > >  include/linux/res_counter.h |    3 +++
> > >  kernel/res_counter.c        |   22 ++++++++++++++++++++++
> > >  2 files changed, 25 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> > > index de4ba29..558f39b 100644
> > > --- a/include/linux/res_counter.h
> > > +++ b/include/linux/res_counter.h
> > > @@ -147,6 +147,9 @@ static inline void res_counter_uncharge(struct res_counter *counter,
> > >  	res_counter_uncharge_until(counter, NULL, val);
> > >  }
> > >  
> > > +struct res_counter *res_counter_common_ancestor(struct res_counter *l,
> > > +						struct res_counter *r);
> > > +
> > >  /**
> > >   * res_counter_margin - calculate chargeable space of a counter
> > >   * @cnt: the counter
> > > diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> > > index 0cc9c7e..22f07cc 100644
> > > --- a/kernel/res_counter.c
> > > +++ b/kernel/res_counter.c
> > > @@ -91,6 +91,28 @@ void res_counter_uncharge_until(struct res_counter *counter,
> > >  	local_irq_restore(flags);
> > >  }
> > >  
> > > +/*
> > > + * Walk through r1 and r2 parents and try to find the closest common one
> > > + * between both. If none is found, it returns NULL.
> > > + */
> > > +struct res_counter *
> > > +res_counter_common_ancestor(struct res_counter *r1, struct res_counter *r2)
> > > +{
> > > +	struct res_counter *iter;
> > > +
> > > +	while (r1) {
> > > +		iter = r2;
> > > +		while (iter) {
> > > +			if (iter == r1)
> > > +				return iter;
> > > +			iter = iter->parent;
> > > +		}
> > > +
> > > +		r1 = r1->parent;
> > > +	}
> > > +
> > > +	return NULL;
> > > +}
> > 
> > Your implementation is O(n*m).
> > 
> > What about:
> > 
> > struct res_counter *
> > res_counter_common_ancestor(struct res_counter *r1, struct res_counter *r2)
> > {
> > 	struct res_counter *iter;
> > 	int r1_depth = 0, r2_depth = 0;
> > 
> > 	for (iter = r1; iter; iter = iter->parent)
> > 		r1_depth++;
> > 	for (iter = r2; iter; iter = iter->parent)
> > 		r2_depth++;
> > 
> > 	while (r1_depth > r2_depth) {
> > 		r1 = r1->parent;
> > 		r1_depth--;
> > 	}
> > 	while (r2_depth > r1_depth) {
> > 		r2 = r2->parent;
> > 		r2_depth--;
> > 	}
> > 
> > 	while (r1 != r2) {
> > 		r1 = r1->parent;
> > 		r2 = r2->parent;
> > 	}
> > 
> > 	return r1;
> > }
> 
> While applying this (works well btw) I realize you rewrote the patch.
> 
> Can you give me your "Signed-off-by:" so that I correctly set the
> authorship and the tags that come along?

Sure.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

-- 
 Kirill A. Shutemov
