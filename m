From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/8] blkcg: kill blkio_list and replace blkio_list_lock
	with a mutex
Date: Fri, 13 Apr 2012 09:55:19 -0700
Message-ID: <20120413165519.GA12233__47821.4066512466$1334336133$gmane$org@google.com>
References: <1334273380-30233-1-git-send-email-tj@kernel.org>
	<1334273380-30233-2-git-send-email-tj@kernel.org>
	<20120413133226.GB26383@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120413133226.GB26383-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Fri, Apr 13, 2012 at 09:32:26AM -0400, Vivek Goyal wrote:
> On Thu, Apr 12, 2012 at 04:29:33PM -0700, Tejun Heo wrote:
> 
> Hi Tejun,
> 
> > @@ -732,20 +732,21 @@ void blkio_policy_register(struct blkio_policy_type *blkiop)
> >  {
> >  	struct request_queue *q;
> >  
> > +	mutex_lock(&blkcg_pol_mutex);
> > +
> >  	blkcg_bypass_start();
> > -	spin_lock(&blkio_list_lock);
> >  
> >  	BUG_ON(blkio_policy[blkiop->plid]);
> 
> A minor nit. It might be a good idea to check that blkiop->plid is not
> greater than BLKIO_NR_POLICIES for both registration and unresitration
> functions to avoid touching memory beyond blkio_policy[] array.

I'm making ->plid to be dynamically allocated on registration anyway,
so I don't think it really matters.  The updated unregistration
function does BUG_ON(blkio_policy[pol->plid] != pol) which should
catch stray plid.

Thanks.

-- 
tejun
