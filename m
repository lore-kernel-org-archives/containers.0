From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support (v3)
Date: Thu, 02 Jul 2009 05:15:51 -0400
Message-ID: <4A4C7AC7.3090004@cs.columbia.edu>
References: <1245167716-28906-1-git-send-email-danms@us.ibm.com>	<4A42E163.1080700@cs.columbia.edu>
	<871vp3x81s.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871vp3x81s.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
> OL> Value of some fields below needs to be verified/checked:
> 
> Yep, okay, I think I've got some sane sanity checks in place now.
> 
>>> +	CKPT_COPY(op, h->sock.err, sock->sk_err);
>>> +	CKPT_COPY(op, h->sock.err_soft, sock->sk_err_soft);
> 
> OL> I'm unsure if we need ensure that an error value is in range...
> OL> can it do harm to pass an out-of-range value back to the caller ?
> 
> I don't think any of the kernel code would care, but it's probably
> best to make sure that it's in a reasonable range.
> 
> OL> This is 'int' in struct sock, but assignment may make it negative
> OL> ?
> 
> Fixed this and others.
> 
>>> +	CKPT_COPY(op, h->sock.rcvtimeo, sock->sk_rcvtimeo);
>>> +	CKPT_COPY(op, h->sock.sndtimeo, sock->sk_sndtimeo);
> 
> OL> These two too. Perhaps refactor and use sock_set_timeout() ?
> 
> From the look of sock_set_timeout() I'm not sure it's expected to be
> called from kernel space.  Regardless, I think just setting it (and
> not corrupting it) should be fine.
> 
> OL> These should be checked for sign-ness, limited in magnitude (e.g.
> OL> <= sysctl_wmem_max), checked against a minimum (see setting it in
> OL> net/core/sock.c), and finally perhaps correlated with a flag
> OL> against sk_userlocks ?
> 
> Yep, fixed.
> 
>>> +	if ((sock->sk_state != TCP_LISTEN) &&
>>> +	    (socket->ops->getname(socket, &h->raddr, &h->raddr_len, 1))) {
>>> +		if (sock->sk_type != SOCK_DGRAM) {
>>> +			ret = -EINVAL;
>>> +			goto out;
>>> +		}
> 
> OL> I suspect this fails for !SOCK_DGRAM that isn't connected,
> OL> e.g. newly created.
> 
> Okay, yeah.  I changed the logic to only bail if it's a DGRAM socket
> and the state is TCP_ESTABLISHED, which I think is probably what we
> want.  Since we bail on the transitional TCP states, I think this
> should be okay.
> 
>>> +		h->raddr_len = 0;
> 
> OL> Hmmm.. do you need to ensure that this value is consistent with
> OL> the value of ->peer ?  (at restart)
> 
> I dunno, why would I?  If I hook up the two peers to the same address
> structure on restart everything should be correct, no?

Because in the kernel:
	"->peer != NULL"  if-and-only-if   "h->raddr is meaningful"
so I wonder whether you should detect such input and complain,
in case a malicious user does that ?

> 
> As somewhat of a side question, is there a rule that says that
> getname() must return the exact same thing each time it is called?

I, for one, would expect it to remain the same unless my program
re-connected the sockets.

Or better: is there a reason why we would want to behave otherwise ?

> 
> OL> I'd suggest a ckpt_write_err() here (and in other key places) to
> OL> explain to the user what caused the checkpoint to fail.
> 
> Yep, I hadn't followed the introduction of that, but it's a very
> welcome addition.  I've added calls in the appropriate places.
> 
> OL> Any reason to write the buffers of a listening socket ?  they only
> OL> contain not-yet-accepted sockest, which aren't supported anyway.
> 
> Nope, fixed.
> 
> OL> And while there is not support for not-yet-accepted sockets, maybe
> OL> add an explicit test (if LISTEN and has skb's) and fail with an
> OL> error, as well as call ckpt_write_err().
> 
> Isn't that just this (from the patch):

Yes. I guess I misread the code.

> 
> +	if ((sock->sk_state == TCP_LISTEN) &&
> +	    !skb_queue_empty(&sock->sk_receive_queue)) {
> +		ckpt_debug("listening socket has unaccepted peers");
> +		return -EBUSY;
> +	}
> 
> ?  I've put a ckpt_write_err() there now...
> 
>>> +	/* FIXME: write out-of-order queue for TCP */
> 
> OL> I'd prefer failing if such data exists...
> 
> Yep, indeed.  I've removed the comment here and will augment the INET
> patch to check for that and fail appropriately.
> 
>>> +	memcpy(skb_put(*skb, len), (char *)(h + 1), len);
> 
> OL> Can we avoid this memory copy ?  Perhaps add _ckpt_read_hdr() and
> OL> _ckpt_read_payload() helpers ?
> 
> Okay, yep.
> 
>>> +static int sock_read_buffers(struct ckpt_ctx *ctx,
>>> +			     struct sock *sock,
>>> +			     struct sk_buff_head *queue)
>>> +{
>>> +	struct ckpt_hdr_socket_buffer *h;
>>> +	int ret = 0;
>>> +	int i;
>>> +
>>> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFERS);
>>> +	if (IS_ERR(h)) {
>>> +		ret = PTR_ERR(h);
>>> +		goto out;
>>> +	}
>>> +
>>> +	for (i = 0; i < h->skb_count; i++) {
>>> +		struct sk_buff *skb = NULL;
>>> +
>>> +		ret = sock_read_buffer(ctx, sock, &skb);
>>> +		if (ret)
>>> +			break;
>>> +
>>> +		skb_queue_tail(queue, skb);
>>> +	}
> 
> OL> Make sure that total length is within limits, or this is an
> OL> opening for DoS.
> 
> You mean the number of buffers?  The sock_read_buffer() function will
> limit each skb to SKB_MAX_ALLOC.  What is a sane maximum number of
> buffers?  Maybe we need a sysctl for that?

Well, it should not be more than allowed by ->rcvbuf, or some other
system limits (which I'm sure exists). At least apply the restrictions
put by a regular read() syscall.

One exception is when a socket's rcvbuf fills with large amount
of data, and then the user calls setsockopt() to reduce the buffer
to a lower size... in which case relying on the restored value for
->rcvbuf limit is clearly wrong.

> 
> OL> I checked below, but you don't examine @len before calling this
> OL> function. So a DoS is possible by exhausting kernel memory with
> OL> these kmalloc()s.
> 
> Yep, fixed.
> 
> OL> Hmmm... a socket that is connected may also be bind(), so I'm not
> OL> sure the test below is always correct ?
> 
> You mean because it could have been bind()'ed to a different address
> than it's peer before it called connect()?  Wouldn't the connect()
> have changed the local address?

Nope.

The connect() syscall will auto-bind only if the socket isn't
already bound. And in the case of ad_unix, even that happens only
when SOCK_PASSCRED bit is set in sock->flags.

> 
> OL> A thought: do we want to restore sharing of addresses at restart ?
> OL> For instance, all sockets accepted from a single listening socket
> OL> share their local addresses.
> 
> For INET it seems important, but I don't think I've seen anything in
> the UNIX code that cares.  However, I can move some of the
> parent-tracking stuff to this patch in order to hook up the shared
> addresses if you think it's important.

Don't think it's important, definitely not for af_unix (the amount
of memory spent isn't worth the optimization, I reckon). But INET
(or other sockets) may indeed require this.

> 
> OL> 1) Non-listening sockets may also need bind(). Especially
> OL> SOCK_DGRAM.
> 
> Perhaps if the socket is not established and had a local address, we
> call bind?

Even an established socket may have a local address that needs to
be saved, to make getsockname() consistent across c/r.

> 
> OL> 2) What happens if s1 is checkpointed before s2 in this scenario:
> OL> 	s1 = socket(); bind(s1, addr); unlink(addr);
> OL> 	s2 = socket(); bind(s1, addr);
			^^^^^^^^
			   (s2, addr)    <-- should have been	
> 
> OL> I'd suggest that a socket that is did bind() and that
> OL> corresponding inode was later unlink()ed, will not be re-bind at
> OL> all. After all, it is unreachable in terms of connect() syscall.
> 
> I'm not sure what you're saying here...
>

Neither was I  :p

Now with the fixed example, the problem is if s2 is restored first,
the restore of s1 will fail, or succeed and make s1 unreachable.

However, we know that s1 is no longer reachable through connect()
(or sendto() for dgram) - so during restart we want to manually
set the local address, without the side-effect of creating an inode
in the filesystem, for those sockets that are 1) bound with pathname
address, and 2) the corresponding socket inode isn't unlinked.

> OL> 3) If the sockets path is relative, you can't blindly rely on the
> OL> socket address reported by ->getname(), because the original
> OL> bind() occured _relative_ to the task's current-working-directory
> OL> at the time of the socket() syscall.
> 
> OL> The cwd of the restarting task may differ. Moreover, the resulting
> OL> path: cwd + sockaddr may exceed 108 bytes. Lastly, getsockname()
> OL> reports the original, relative pathname anyways.
> 
> OL> So if the address doesn't begin with a '/', you need to also save
> OL> the cwd and on restart, go there before caling bind().
> 
> But the app could have changed its cwd after binding the socket so the
> cwd of the checkpointed task isn't what we want, right?  Maybe we
> could do a dentry lookup to find the actual path it's bound to and
> store that separately from the local and remote addresses?
> 

I meant "cwd at the time of the bind()". To find it, you can "subtract"
the sock-address from the total pathname of the inode (assuming, of
course, that the address is relative).

Oren.
