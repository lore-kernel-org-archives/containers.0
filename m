From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support (v3)
Date: Mon, 06 Jul 2009 18:46:16 -0400
Message-ID: <4A527EB8.4060201@cs.columbia.edu>
References: <1245167716-28906-1-git-send-email-danms@us.ibm.com>	<4A42E163.1080700@cs.columbia.edu>	<871vp3x81s.fsf@caffeine.danplanet.com>	<4A4C7AC7.3090004@cs.columbia.edu>	<87y6r1slxz.fsf@caffeine.danplanet.com>	<4A524B40.4040600@cs.columbia.edu>
	<87tz1psbpq.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87tz1psbpq.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
> OL> (You'll need to slightly refactor sock_setsockopt() for that).
> 
> It seems much easier and less invasive to just check against
> sysctl_{r,w}mem_max.  I've got that added to the patch now.

But there are two cases:  if you are CAP_NET_ADMIN you are allowed
to go beyond that limit. So you need to add that test too.

And in general, this helps to keep the checks - be it security,
resource limits, or whatever - in one place, instead of having
to duplicate code and, more importantly, risk getting out of
sync with the original checks (e.g., if sock_setsockopt changes).

> 
> OL> 2) 	s = socket(.., SOCK_DGRAM,...);
> OL> 	bind(s, any_addr);
> OL> 	connect(s, other_addr, ...);
> --> now s is connected, but after restart you can't connect another
> OL> socket to it because the address wasn't bind() properly.
> 
> Okay, I guess that's true.  So, since there isn't a "I'm bound, but
> not listening or connected" flag anywhere, does it suffice to bind()
> any socket that is not connected but that does have a local address?
> Sockets that get a local address via connect() should never transition
> through that state, so I think that should work.  At least for INET,
> any socket that is restored into a connected state is properly hashed
> such that another socket can't bind() to its local address (tested).

Yes, with the exception below (for UNIX)...

> 
> OL> (And if the address was a pathname, but already unlinked, then
> OL> also unlink after the bind, FWIW).
> 
> For path-based UNIX sockets, we don't care about this exclusion,
> right?  As long as we make the socket owner think everything is as it

You are correct in that you don't need it for the scenario you
presented below.

But we do care, because it is necessary to do the unlink() after the
bind(), like you do for listening sockets, for this scenario:

	s = socket()
	bind(s, pathname)
	unlink(pathname)
				<---- checkpoint/restart
	r = socket()
	bind(r, pathname)

The second bind() will succeed on the original system, but will
fail on the restarted system, unless you do that.

> was, that is.  Given that a normal system doesn't fail the bind of b
> in this case:
> 
>   a = socket(AF_UNIX);
>   b = socket(AF_UNIX);
> 
>   bind(a, addr);
>   unlink(addr);
>   bind(b, addr);
> 

BTW, I just looked again at the code, and I'm concerned about:

+		if (!un->linked) {
+			struct sockaddr_un *sun =
+				(struct sockaddr_un *)&h->laddr;
+			ret = sock_unix_unlink(sun->sun_path);
+		}

You need to verify that the address is not abstract, because
I'm not sure what sock_unix_unlink() would do given the empty
string. Usually this is filtered higher in the VFS (getname).

Oren.
