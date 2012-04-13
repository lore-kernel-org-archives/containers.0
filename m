From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/8] blkcg: make sure blkg_lookup() returns %NULL if @q
	is bypassing
Date: Fri, 13 Apr 2012 10:03:34 -0700
Message-ID: <20120413170334.GB12233@google.com>
References: <1334273380-30233-1-git-send-email-tj@kernel.org>
	<1334273380-30233-6-git-send-email-tj@kernel.org>
	<20120413160053.GE26383@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120413160053.GE26383-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey,

On Fri, Apr 13, 2012 at 12:00:53PM -0400, Vivek Goyal wrote:
> On Thu, Apr 12, 2012 at 04:29:37PM -0700, Tejun Heo wrote:
> 
> [..]
> >   * In bypass mode, only the dispatch FIFO queue of @q is used.  This
> >   * function makes @q enter bypass mode and drains all requests which were
> >   * throttled or issued before.  On return, it's guaranteed that no request
> > - * is being throttled or has ELVPRIV set.
> > + * is being throttled or has ELVPRIV set and blk_queue_bypass() is %true
> > + * inside queue or RCU read lock.
> >   */
> >  void blk_queue_bypass_start(struct request_queue *q)
> >  {
> > @@ -426,6 +427,7 @@ void blk_queue_bypass_start(struct request_queue *q)
> >  	spin_unlock_irq(q->queue_lock);
> >  
> >  	blk_drain_queue(q, false);
> > +	synchronize_rcu();
> 
> I guess this synchronize_rcu() needs some comments here to make it clear
> what it meant for. IIUC, you are protecting against policy data (stats
> update) which happen under rcu in throttling code? You want to make sure
> all these updaters are done before you go ahead with
> activation/deactivation of a policy.
> 
> Well, I am wondering if CFQ is policy being activated/deactivated why
> should we try to drain other policie's requests. Can't one continue
> to work without draining all the throttled requests. We probably just
> need to make sure new groups are not created.

So, I think synchronization rules like this are something which the
core should define.  cfq may not use it but the sync rules should
still be the same for all policies.  In this case, what the core
provides is "blk_queue_bypass() is guaranteed to be seen as %true
inside RCU read lock section once this function returns", which in
turn will guarantee that RCU read-lock protected blkg_lookup() is
guaranteed to fail once the function returns.  This property makes RCU
protected blkg_lookup() safe against queue bypassing, which is what we
want.

Now, all these are something which happens (and should happen) inside
blkcg core.  All blk-throtl knows is that if it sticks to the rules
defined by blkcg core (e.g. blkg_lookup() should be RCU protected),
it's not stepping on anyone's toe, so, no, this definitely belongs to
block / blkcg core proper.  We can move it from block to blkcg but I
think it's a nice property to have for queue bypassing and it's not
like queue bypassing is a hot path.

That said, yeah, I think it can use a bit more documentation.  Will
add more comments.

Thanks.

-- 
tejun
