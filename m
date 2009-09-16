From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 20/23] io-controller: Per cgroup request descriptor support
Date: Wed, 16 Sep 2009 14:47:49 -0400
Message-ID: <20090916184749.GF5221__38163.4109108292$1253129602$gmane$org@redhat.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<1251495072-7780-21-git-send-email-vgoyal@redhat.com>
	<e98e18940909141133m5186b780r3215ce15141e4f87@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e98e18940909141133m5186b780r3215ce15141e4f87-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Sep 14, 2009 at 11:33:37AM -0700, Nauman Rafique wrote:

[..]
> > =A0struct request *blk_get_request(struct request_queue *q, int rw, gfp=
_t gfp_mask)
> > =A0{
> > =A0 =A0 =A0 =A0struct request *rq;
> > + =A0 =A0 =A0 struct request_list *rl;
> >
> > =A0 =A0 =A0 =A0BUG_ON(rw !=3D READ && rw !=3D WRITE);
> >
> > =A0 =A0 =A0 =A0spin_lock_irq(q->queue_lock);
> > + =A0 =A0 =A0 rl =3D blk_get_request_list(q, NULL);
> > =A0 =A0 =A0 =A0if (gfp_mask & __GFP_WAIT) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rq =3D get_request_wait(q, rw, NULL);
> > =A0 =A0 =A0 =A0} else {
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rq =3D get_request(q, rw, NULL, gfp_mask);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rq =3D get_request(q, rw, NULL, gfp_mask,=
 rl, NULL);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!rq)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irq(q->queue=
_lock);
> > =A0 =A0 =A0 =A0}
> > @@ -1085,12 +1269,13 @@ void __blk_put_request(struct request_queue *q,=
 struct request *req)
> > =A0 =A0 =A0 =A0if (req->cmd_flags & REQ_ALLOCED) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int is_sync =3D rq_is_sync(req) !=3D 0;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int priv =3D req->cmd_flags & REQ_ELVPRI=
V;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct request_list *rl =3D rq_rl(q, req);
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(!list_empty(&req->queuelist));
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(!hlist_unhashed(&req->hash));
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_free_request(q, req);
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 freed_request(q, is_sync, priv);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 freed_request(q, is_sync, priv, rl);
> =

> We have a potential memory bug here. freed_request should be called
> before blk_free_request as blk_free_request might result in release of
> cgroup, and request_list. Calling freed_request after blk_free_request
> would result in operations on freed memory.
> =


Good point Nauman. freeing rq will drop reference on the io queue. Which
in turn will drop reference on io group and if associated cgroup is
already gone, then io group will be freed hence request list pointer is
no more valid and any operation on that is bad.

So either we can take a reference on the queue, call free_request() and
then drop the reference or we can call freed_request() before
blk_free_request(). Calling freed_request() before blk_free_request()
sounds better to me. The only thing is that this function name and other
dependent function names should now be freeing_request() instead of
freed_request(). :-)

Will move freed_request() before blk_free_request() in next version.

Thanks
Vivek
