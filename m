From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/2] inetpeer: add namespace support for
	inetpeer
Date: Tue, 05 Jun 2012 14:00:30 +0200
Message-ID: <1338897630.2760.2433.camel__37512.6039064073$1338897649$gmane$org@edumazet-glaptop>
References: <1338882737-11914-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1338886626.2760.2109.camel@edumazet-glaptop>
	<20120605112728.GB27795@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120605112728.GB27795-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Steffen Klassert <steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2012-06-05 at 13:27 +0200, Steffen Klassert wrote:

> > 
> > By the way, I think we have a bug in inetpeer_gc_worker()
> > 
> > Steffen ?
> > 
> > We have no rcu grace period to make sure the following is safe :
> > 
> > if (!atomic_read(&p->refcnt)) {
> > 	list_del(&p->gc_list);
> > 	kmem_cache_free(peer_cachep, p);
> > }
> 
> I think this is ok as it is. inetpeer_invalidate_tree()
> unlinks the whole inetpeer tree from the inetpeer base and
> adds it to a gc_list. These intetpeer entries are stale,
> they can't be looked up again. So noone should increment the
> refcount, they just wait until the refcount get zero.
> 

Its not OK, lookups are done under rcu.

Since there is no RCU grace period, the worker free the entries while
another cpus are doing their lookups.

Alternative would be to wait a RCU grace period before feeding them to
worker.
