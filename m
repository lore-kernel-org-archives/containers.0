From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/8] blkcg: make sure blkg_lookup() returns %NULL if @q
	is bypassing
Date: Fri, 13 Apr 2012 13:23:36 -0400
Message-ID: <20120413172336.GF26383__14079.6411237263$1334337827$gmane$org@redhat.com>
References: <1334273380-30233-1-git-send-email-tj@kernel.org>
	<1334273380-30233-6-git-send-email-tj@kernel.org>
	<20120413160053.GE26383@redhat.com>
	<20120413170334.GB12233@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120413170334.GB12233-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 13, 2012 at 10:03:34AM -0700, Tejun Heo wrote:
> Hey,
> 
> On Fri, Apr 13, 2012 at 12:00:53PM -0400, Vivek Goyal wrote:
> > On Thu, Apr 12, 2012 at 04:29:37PM -0700, Tejun Heo wrote:
> > 
> > [..]
> > >   * In bypass mode, only the dispatch FIFO queue of @q is used.  This
> > >   * function makes @q enter bypass mode and drains all requests which were
> > >   * throttled or issued before.  On return, it's guaranteed that no request
> > > - * is being throttled or has ELVPRIV set.
> > > + * is being throttled or has ELVPRIV set and blk_queue_bypass() is %true
> > > + * inside queue or RCU read lock.
> > >   */
> > >  void blk_queue_bypass_start(struct request_queue *q)
> > >  {
> > > @@ -426,6 +427,7 @@ void blk_queue_bypass_start(struct request_queue *q)
> > >  	spin_unlock_irq(q->queue_lock);
> > >  
> > >  	blk_drain_queue(q, false);
> > > +	synchronize_rcu();
> > 
> > I guess this synchronize_rcu() needs some comments here to make it clear
> > what it meant for. IIUC, you are protecting against policy data (stats
> > update) which happen under rcu in throttling code? You want to make sure
> > all these updaters are done before you go ahead with
> > activation/deactivation of a policy.
> > 
> > Well, I am wondering if CFQ is policy being activated/deactivated why
> > should we try to drain other policie's requests. Can't one continue
> > to work without draining all the throttled requests. We probably just
> > need to make sure new groups are not created.
> 
> So, I think synchronization rules like this are something which the
> core should define.  cfq may not use it but the sync rules should
> still be the same for all policies.  In this case, what the core
> provides is "blk_queue_bypass() is guaranteed to be seen as %true
> inside RCU read lock section once this function returns", which in
> turn will guarantee that RCU read-lock protected blkg_lookup() is
> guaranteed to fail once the function returns.  This property makes RCU
> protected blkg_lookup() safe against queue bypassing, which is what we
> want.

I think now synchronize_rcu() has become part of cfq_init_queue()
effectively and that will slow down boot. In the past I had to remove
it.

Thanks
Vivek
