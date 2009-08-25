From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/3] Make sockets proper objhash objects and use
	checkpoint_obj() on them
Date: Tue, 25 Aug 2009 13:55:08 -0400
Message-ID: <4A94257C.5060702@librato.com>
References: <1251133918-8117-1-git-send-email-danms@us.ibm.com>	<1251133918-8117-3-git-send-email-danms@us.ibm.com>	<4A937031.10300@librato.com>
	<87y6p8q728.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87y6p8q728.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org



Dan Smith wrote:
> OL> It's perhaps more accurate to s/most sockets/some sockets/. It may
> OL> be more likely for a socket to be checkpointed as a peer of
> OL> another process, or as the sender of an skb.
> 
> Um, how about "most of the time" ?  I definitely think that the
> (overwhelmingly) common case is a pair of sockets each attached to a
> file descriptor.
> 
> OL> Now that you made 'struct sock' a 1st class object, they deserve to
> OL> enjoy 1st class treatment :p  That also means proper collect() method
> OL> - probably starting with the f_op ...
> 
> Okay.
> 
> OL> I may be mistaken, but I suspect that the suggested implementation
> OL> cannot limit the depth of recursive calls to checkpoint_obj(). For
> OL> instance, consider a dgram socket that received data from another
> OL> dgram socket, that received data from another dgram, ad infinitum.
> 
> At the very least, a single receive socket is limited in how many
> skb's may be queued for it, which limits an attacker's ability to
> reach the "ad infinitum" case, I'd say.  Do we need something more?

Multiple buffers adds iteration, and one level of recursion. I had in
mind a slightly different scenario: instead of many buffers for one
socket, many sockets "chained" -

Assume N sockets S_1...S_n, all dgram, none is connected. Each socket
S_i send one packet to S_i+1.  Suppose you first checkpoint S_n, then
you'll need to checkpoint S_n-1, for which you'll need to checkpoint
S_n-2 etc.

> OL> I'm thinking about the two other use cases that I mentioned:
> OL> "dangling" (not-referenced by a file) and "pending" (not yet
> OL> accepted) sockets.
> 
> OL> In both cases (well, at least with "pending"), the 'struct sock'
> OL> exist but the 'struct socket' does not exit until after the socket
> OL> is attached to a file descriptor. IIRC, the lifespan of 'struct
> OL> socket' is coupled to that of the referencing file.
> 
> OL> In that case, I guess it make more sense to leave the 'struct
> OL> socket' related data within ckpt_hdr_file_socket.
> 
> Hmm, not by my reading.  From what I can tell, the accept operation

You are right: sock_init_data() sets it up, and I believe it is
for the entire lifetime of the sock/socket.

>>> +		return ERR_PTR(PTR_ERR(sk));
> 
> OL> Nit: I vaguely recall some disapproval of such construct...
> OL> How about '(struct file *) sk' ?
> 
> Casting it to the wrong type seems less desirable to me.  I was
> following the lead of:
> 
>   % fgrep -r 'ERR_PTR(PTR_ERR' . | wc -l
>   36

Yep. That settles it then :)

> 
> and:
> 
>   % fgrep -r 'ERR_PTR(PTR_ERR' checkpoint
>   checkpoint/namespace.c:		return ERR_PTR(PTR_ERR(h));
>   checkpoint/signal.c:		return ERR_PTR(PTR_ERR(h));

(FWIW, this was criticized ...)

Oren.
