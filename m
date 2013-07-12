From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [OFFLIST] status of devcg
Date: Fri, 12 Jul 2013 13:04:37 +0000
Message-ID: <20130712130437.GA26910@mail.hallyn.com>
References: <20130710184655.GB16979@mtj.dyndns.org>
	<20130710195001.GW14011@redhat.com>
	<20130711093405.GC2377@redhat.com>
	<20130711155106.GB9229@mtj.dyndns.org>
	<20130711160532.GA14909@ac100>
	<20130711171037.GB10195@mtj.dyndns.org>
	<20130711191206.GA2149@ac100>
	<20130711203833.GA3974@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130711203833.GA3974-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> On Thu, Jul 11, 2013 at 02:12:06PM -0500, Serge Hallyn wrote:
> > Before I respond to that, could you please tell me precisely what
> > you mean by 'unified hierarchy'?  I thought it just meant all
> > controllers composed into one mount.  Maybe it means something
> > else.
> 
> Oh, it's gonna be a hierarchy which can dynamically enable / disable
> controllers in sub-hierarchies, so it isn't just co-mounting
> everything, which really wouldn't work for many use cases.  As some

I see.  (I'll let that sink in for a bit then look back at Aristeu's
email :)

> controllers are outright hostile against being co-mounted and this is
> basically gonna be v2 (or v1.1 whatever) of the itnerface, I'm trying
> to weed out weird behaviors.
> 
> Thanks.

Thanks

-serge
