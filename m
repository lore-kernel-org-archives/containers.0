From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] [RFC] Add c/r support for listening INET sockets
Date: Tue, 29 Sep 2009 12:56:56 -0700
Message-ID: <87r5tpo77b.fsf@caffeine.danplanet.com>
References: <1254164330-23072-1-git-send-email-danms@us.ibm.com>
	<20090929195025.GA14956@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090929195025.GA14956-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Tue\, 29 Sep 2009 14\:50\:25 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

>> +	if ((h->sock_common.family == AF_INET) &&
>> +	    (h->sock.state != TCP_LISTEN)) {
>> +		/* Temporary hack to enable restore of TCP_LISTEN sockets
>> +		 * while forcing anything else to a closed state
>> +		 */
>> +		sock->sk->sk_state = TCP_CLOSE;

SH> I'll admit by this point I'm a bit confused about the order in
SH> which these things are restored.  Does do_sock_restore() run
SH> before inet_restore() below (curious whether its check for
SH> TCP_CLOSE will catch these particular sockets).

It runs after inet_restore(), which was called above via
sock->ops->restore().  Thus, inet_restore() can largely ignore the
connected sockets and then they're forced closed here (since
inet_restore() runs before the common restore routine, otherwise it
could set them closed itself).

>> +int inet_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
>> +{
>> +	struct ckpt_hdr_socket_inet *in;
>> +	int ret = -EINVAL;
>> +
>> +       in = ckpt_hdr_get_type(ctx, sizeof(*in), CKPT_HDR_SOCKET_INET);
>> +       if (!in)
>> +               goto out;

SH> Better to just return...  I don't think this'll cause a crash (it
SH> only makes ckpt_hdr_put() pass ((struct ckpt_hdr *)NULL)->len to
SH> _ckpt_hdr_put which then ignores it and does a safe kfree(NULL)),
SH> but it won't be safe if the implementation of the ckpt_hdr_*()
SH> calls end up changing.

Sure.  Also note my broken whitespace that came as a result of me
cutting patches into pieces.  I'll fix that too.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
