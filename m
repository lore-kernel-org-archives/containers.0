From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support (v3)
Date: Tue, 07 Jul 2009 11:33:19 -0400
Message-ID: <4A536ABF.8060708@cs.columbia.edu>
References: <1245167716-28906-1-git-send-email-danms@us.ibm.com>	<4A42E163.1080700@cs.columbia.edu>	<871vp3x81s.fsf@caffeine.danplanet.com>	<4A4C7AC7.3090004@cs.columbia.edu>	<87y6r1slxz.fsf@caffeine.danplanet.com>	<4A524B40.4040600@cs.columbia.edu>	<87tz1psbpq.fsf@caffeine.danplanet.com>	<4A527EB8.4060201@cs.columbia.edu>
	<87prccsfyp.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87prccsfyp.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



Dan Smith wrote:
> OL> But there are two cases: if you are CAP_NET_ADMIN you are allowed
> OL> to go beyond that limit. So you need to add that test too.
> 
> Okay, fair enough.
> 
> OL> And in general, this helps to keep the checks - be it security,
> OL> resource limits, or whatever - in one place, instead of having to
> OL> duplicate code and, more importantly, risk getting out of sync
> OL> with the original checks (e.g., if sock_setsockopt changes).
> 
> But sock_setsockopt() will also set the userlocks flag saying that
> you've specified the buffer size.  At the point at which I currently
> restore the buffers, we've already restored the value specified in the
> checkpoint stream, so we'd need to re-reset it as a special case after
> the call to sock_setsockopt().  Further, to get the "override" case,
> you have to call it with SO_RCVBUFFORCE which fails if you're not
> CAP_SYS_ADMIN.  So, do we try force, then if it fails try SO_RCVBUF,
> then if it fails actually fail?  Since sock_setsockopt() doubles the
> buffer size we get it, do we cut the value we want in half before
> passing it in?
> 
> Doing all that seems like an abuse of sock_setsockopt() to me when the
> alternative is to check CAP_SYS_ADMIN and set the buffer size.
> 
> OL> But we do care, because it is necessary to do the unlink() after
> OL> the bind(), like you do for listening sockets, for this scenario:
> 
> OL> 	s = socket()
> OL> 	bind(s, pathname)
> OL> 	unlink(pathname)
> OL> 				<---- checkpoint/restart
> OL> 	r = socket()
> OL> 	bind(r, pathname)
> 
> OL> The second bind() will succeed on the original system, but will
> OL> fail on the restarted system, unless you do that.
> 
> Not if we don't actually call bind(s) in the unlinked case.  What I
> meant in my previous response is: if we're unlinked, then just fake
> the bind actions but don't actually do the bind()..unlink().  We
> already went over the case where we might unlink() a valid socket
> depending on the order, right?
> 
> OL> BTW, I just looked again at the code, and I'm concerned about:
> 
> OL> +		if (!un->linked) {
> OL> +			struct sockaddr_un *sun =
> OL> +				(struct sockaddr_un *)&h->laddr;
> OL> +			ret = sock_unix_unlink(sun->sun_path);
> OL> +		}
> 
> OL> You need to verify that the address is not abstract, because I'm
> OL> not sure what sock_unix_unlink() would do given the empty
> OL> string. Usually this is filtered higher in the VFS (getname).
> 
> Yep, but luckily that's gone with my recent changes to fake the bind()
> for unlinked sockets instead of actually doing the unlink() :)

Ahh.. and forgot to ask/mention: you do need to call sock_unix_unlink()
before attempting bind(), for the reasons we had discussed earlier
(consider same example as above, checkpoint/restart done before the
unlink(), then restart will otherwise fail).

So you still need to sanitize the file name for that case, no ?

Oren.
