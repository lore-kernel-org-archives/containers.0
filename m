From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Date: Thu, 12 Mar 2009 09:53:11 -0500
Message-ID: <20090312145311.GC12390__13319.1772191369$1236871001$gmane$org@us.ibm.com>
References: <20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz>
	<1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz>
	<20090212141014.2cd3d54d.akpm@linux-foundation.org>
	<1234479845.30155.220.camel@nimitz>
	<20090226155755.GA1456@x200.localdomain>
	<20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49B775B4.1040800-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (legoater-GANU6spQydw@public.gmane.org):
> Alexey Dobriyan wrote:
> > On Thu, Feb 26, 2009 at 06:57:55PM +0300, Alexey Dobriyan wrote:
> >> On Thu, Feb 12, 2009 at 03:04:05PM -0800, Dave Hansen wrote:
> >>> dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... kernel/cpt/ | diffstat 
> > 
> >>>  47 files changed, 20702 insertions(+)
> >>>
> >>> One important thing that leaves out is the interaction that this code
> >>> has with the rest of the kernel.  That's critically important when
> >>> considering long-term maintenance, and I'd be curious how the OpenVZ
> >>> folks view it. 
> >> OpenVZ as-is in some cases wants some functions to be made global
> >> (and if C/R code will be modular, exported). Or probably several
> >> iterators added.
> >>
> >> But it's negligible amount of changes compared to main code.
> > 
> > Here is what C/R code wants from pid allocator.
> > 
> > With the introduction of hierarchical PID namespaces, struct pid can
> > have not one but many numbers -- tuple (pid_0, pid_1, ..., pid_N),
> > where pid_i is pid number in pid_ns which has level i.
> > 
> > Now root pid_ns of container has level n -- numbers from level n to N
> > inclusively should be dumped and restored.
> > 
> > During struct pid creation first n-1 numbers can be anything, because the're
> > outside of pid_ns, but the rest should be the same.
> > 
> > Code will be ifdeffed and commented, but anyhow, this is an example of
> > change C/R will require from the rest of the kernel.
> > 
> > 
> > 
> > --- a/kernel/pid.c
> > +++ b/kernel/pid.c
> > @@ -182,6 +182,34 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
> >  	return -1;
> >  }
> >  
> > +static int set_pidmap(struct pid_namespace *pid_ns, pid_t pid)
> > +{
> > +	int offset;
> > +	struct pidmap *map;
> > +
> > +	offset = pid & BITS_PER_PAGE_MASK;
> > +	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
> > +	if (unlikely(!map->page)) {
> > +		void *page = kzalloc(PAGE_SIZE, GFP_KERNEL);
> > +		/*
> > +		 * Free the page if someone raced with us
> > +		 * installing it:
> > +		 */
> > +		spin_lock_irq(&pidmap_lock);
> > +		if (map->page)
> > +			kfree(page);
> > +		else
> > +			map->page = page;
> > +		spin_unlock_irq(&pidmap_lock);
> > +		if (unlikely(!map->page))
> > +			return -ENOMEM;
> > +	}
> > +	if (test_and_set_bit(offset, map->page))
> > +		return -EBUSY;
> > +	atomic_dec(&map->nr_free);
> > +	return pid;
> > +}
> > +
> >  int next_pidmap(struct pid_namespace *pid_ns, int last)
> >  {
> >  	int offset;
> > @@ -239,7 +267,7 @@ void free_pid(struct pid *pid)
> >  	call_rcu(&pid->rcu, delayed_put_pid);
> >  }
> >  
> > -struct pid *alloc_pid(struct pid_namespace *ns)
> > +struct pid *alloc_pid(struct pid_namespace *ns, int *cr_nr, unsigned int cr_level)
> >  {
> >  	struct pid *pid;
> >  	enum pid_type type;
> > @@ -253,7 +281,10 @@ struct pid *alloc_pid(struct pid_namespace *ns)
> >  
> >  	tmp = ns;
> >  	for (i = ns->level; i >= 0; i--) {
> > -		nr = alloc_pidmap(tmp);
> > +		if (cr_nr && ns->level - i <= cr_level)
> > +			nr = set_pidmap(tmp, cr_nr[ns->level - i]);
> > +		else
> > +			nr = alloc_pidmap(tmp);
> >  		if (nr < 0)
> >  			goto out_free;
> 
> This patch supposes that the process is restored in a state which took several 
> clone(CLONE_NEWPID) to reach. if you replay these clone(), which is what restart
> is at the end : an optimized replay, you would only need something like below. 

No, what you're suggesting does not suffice.

Call
(5591,3,1) the task knows as 5591 in the init_pid_ns, 3 in a child pid
ns, and 1 in grandchild pid_ns created from there.  Now assume we are
checkpointing tasks T1=(5592,1), and T2=(5594,3,1).

We don't care about the first number in the tuples, so they will be
random numbers after the recreate.  But we do care about the second
numbers.  But specifying CLONE_NEWPID while recreating the process tree
in userspace does not allow you to specify the 3 in (5594,3,1).

Or are you suggesting that you'll do a dummy clone of (5594,2) so that
the next clone(CLONE_NEWPID) will be expected to be (5594,3,1)?

-serge
