From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 3/3] Store socket owner with buffers
Date: Wed, 26 Aug 2009 16:34:18 -0400
Message-ID: <4A959C4A.6050803@librato.com>
References: <1251133918-8117-1-git-send-email-danms@us.ibm.com>	<1251133918-8117-4-git-send-email-danms@us.ibm.com>	<4A9377B8.1010400@librato.com>
	<87bpm2qy6q.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87bpm2qy6q.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
> OL> I suspect this won't pass a test in which the sender of a dgram
> OL> has been closed already (and therefore is "dangling") ?
> 
> I had a test case for this, but it was passing because I was closing
> the wrong socket.  However, a few modifications to the code (and a
> corrected test case) have it working now.  I'll post that in the next
> go-round.
> 
> OL> I'm not sure why you removed that code completely.
> 
> OL> It can be executed, for example, by the caller of
> OL> unix_read_buffers(), before and after that call ?
> 
> You're right, I was confusing the behavior of sk_sndbuf with
> sk_wmem_alloc and thinking that I'd need to track it separately.
> 
>>> +		ret = ckpt_write_obj_type(ctx, NULL, sizeof(*h) + skb->len,
>>> CKPT_HDR_SOCKET_BUFFER);
>>> -		if (ret)
>>> +		if (ret < 0)
>>> +			goto end;
>>> +
>>> +		ret = ckpt_kwrite(ctx, h, sizeof(*h));
> 
> OL> The 'struct ckpt_hdr' part of @h was already written in the call
> OL> to ckpt_write_obj_type() above.
> 
> I'll admit that the increased complexity of header and object writing
> recently has me a bit unsure of what to do when, but I'm not sure how
> it is not failing to run if you're correct.  Certainly restore would
> get out of sync with the headers if there was an extra ckpt_hdr in the
> stream, no?

Lol - well, it worked because you wrote the ckpt_hdr twice at checkpoint
and then read it twice at restart...

> 
> Anyway, I've changed that bit to avoid the unnecessary appearance that
> the buffer data is actually part of the ckpt_hdr_socket_buffer
> structure.  It would never be optimal to read it that way anyway.
> 
> OL> I wonder if we need to consider this: With unix domain sockets,
> OL> when a connected, or unconnected dgram socket is (re)connected or
> OL> disconnected, IIRC, all the existing data in the receive buffers
> OL> is removed.
> 
> OL> I suppose this will automagically be enforced, because when you
> OL> connect the socket, old buffers will be discarded already, and if
> OL> it is already connected, then sending from other sockets (not
> OL> peer) will fail.
> 
> OL> So I think we're protected from such malicious data. Perhaps this
> OL> is worth a comment ?
> 
> While swizzling things to handle SOCK_DEAD, I explicitly avoid writing
> buffers for DEAD sockets (like LISTEN sockets).  That should make it
> clear enough, right?

I'm confused...

The concern I raised above is about manipulated checkpoint data that
attempts to make a connected socket to have data from another (not
peer) socket.

Then I realized that since you use the usual send functions, this
_should_ be covered by the existing checks in the unix networking
code itself.

So I wondered if it's worth a comment somewhere, just to let readers
of the code know that this scenario was considered. (Of course, after
verifying that my statement is indeed correct :)

Regarding DEAD sockets - the may still be needed if they are the
source of skb's, no ?  (of course, whatever they had in receive
buffer should have been discarded).

> 
> OL> Hmmm... I suspect this is plain wrong. Objects that are treated
> OL> via checkpoint_obj() and restore_obj() should only be added to the
> OL> objhash via these two functions.
> 
> OL> Because at checkpoint you used un->peer = checkpoint_obj(...), a
> OL> ckpt_obj_fetch() on @un->peer _must_ return the matching object,
> OL> or the image file data is invalid.
> 
> No, because the restore() may be a result of another restore() not yet
> completed, right?  If I'm restoring A, which restores B as a
> side-effect, the restore of B will expect to see its peer (A) as
> already in the objhash or it will fail.

Maybe I need to read the code again. My impression was that when you
checkpoint socket A, and you need B, then you call checkpoint_obj()
on B, from within the processing of checkpoint_obj(A).

restart-obj() - it gets called automatically when ckpt_read_obj() sees
an object of type CKPT_HDR_OBJREF; there is never an explicit call.
That's why I assumed that it will be called for A and then, while
processing A, it will be called for B, since A will read in data and
the ckpt_obj_read() will see the shared object.

> 
> OL> Unfortunately, neither restore_obj() nor ckpt_obj_insert() will
> OL> complain about adding the same objref twice...
> 
> That's going to be a problem for other scenarios where we have a
> circular dependency, right?
> 
> Assume A and B have buffers outstanding for each other.  When we
> restore A, we restore the first buffer and see that we need to restore
> B.  While restoring B's first buffer, we see think that we need to
> restore A because it's not in the objhash yet, and then we're stuck.

I wonder what would the checkpoint image look like ?
Reading the code, I expect the following to occur during checkpoint:

1) find A through the file pointers, call checkpoint_obj(S_a).
2) while in there, find B as peer, call checkpoint_obj(S_b)
3) write B's state, including B's buffers which will reference A
4) (back to A) write A's state, and buffers which will reference B

And at restart:

1) See ckpt_hdr_socket of A (start restart of A)
2) See ckpt_hdr_socket of B (start restart of B)
3) Read B's state in, including buffers. A will not have completed
at this point, so it won't be in the hash either...
...

So I guess it works because you explicitly ckpt_obj_insert() the
sockets to the objhash;  Then later restart_obj() inserts them
(or something) again, but the second instance is never actually
found in a lookup/fetch - the first instance is always returned.

Or am I missing something... ?

> 
> We could permit the restore function to insert itself (if necessary)
> and then we could check before re-insert it after ops->restore(),
> right?
> 

Hmmm... I need to think about it.

Oren.
