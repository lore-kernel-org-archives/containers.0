From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Mon, 22 Apr 2013 14:41:59 -0700
Message-ID: <20130422214159.GG12543@htj.dyndns.org>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Cc: jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Tim.

On Mon, Apr 22, 2013 at 11:26:48PM +0200, Tim Hockin wrote:
> We absolutely depend on the ability to split cgroup hierarchies.  It
> pretty much saved our fleet from imploding, in a way that a unified
> hierarchy just could not do.  A mandated unified hierarchy is madness.
>  Please step away from the ledge.

You need to be a lot more specific about why unified hierarchy can't
be implemented.  The last time I asked around blk/memcg people in
google, while they said that they'll need different levels of
granularities for different controllers, google's use of cgroup
doesn't require multiple orthogonal classifications of the same group
of tasks.

Also, cgroup isn't dropping multiple hierarchy support over-night.
What has been working till now will continue to work for very long
time.  If there is no fundamental conflict with the future changes,
there should be enough time to migrate gradually as desired.

> More, going towards a unified hierarchy really limits what we can
> delegate, and that is the word of the day.  We've got a central
> authority agent running which manages cgroups, and we want out of this
> business.  At least, we want to be able to grant users a set of
> constraints, and then let them run wild within those constraints.
> Forcing all such work to go through a daemon has proven to be very
> problematic, and it has been great now that users can have DIY
> sub-cgroups.

Sorry, but that doesn't work properly now.  It gives you the illusion
of proper delegation but it's inherently dangerous.  If that sort of
illusion has been / is good enough for your setup, fine.  Delegate at
your own risks, but cgroup in itself doesn't support delegation to
lesser security domains and it won't in the foreseeable future.

> Strong disagreement, here.  We use split hierarchies to great effect.
> Containment should be composable.  If your users or abstractions can't
> handle it, please feel free to co-mount the universe, but please
> PLEASE don't force us to.
> 
> I'm happy to talk more about what we do and why.

Please do so.  Why do you need multiple orthogonal hierarchies?

Thanks.

-- 
tejun
