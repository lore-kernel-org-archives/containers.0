From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] Store socket owner with buffers
Date: Wed, 26 Aug 2009 10:31:25 -0700
Message-ID: <87bpm2qy6q.fsf@caffeine.danplanet.com>
References: <1251133918-8117-1-git-send-email-danms@us.ibm.com>
	<1251133918-8117-4-git-send-email-danms@us.ibm.com>
	<4A9377B8.1010400@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

OL> I suspect this won't pass a test in which the sender of a dgram
OL> has been closed already (and therefore is "dangling") ?

I had a test case for this, but it was passing because I was closing
the wrong socket.  However, a few modifications to the code (and a
corrected test case) have it working now.  I'll post that in the next
go-round.

OL> I'm not sure why you removed that code completely.

OL> It can be executed, for example, by the caller of
OL> unix_read_buffers(), before and after that call ?

You're right, I was confusing the behavior of sk_sndbuf with
sk_wmem_alloc and thinking that I'd need to track it separately.

>> +		ret = ckpt_write_obj_type(ctx, NULL, sizeof(*h) + skb->len,
>> CKPT_HDR_SOCKET_BUFFER);
>> -		if (ret)
>> +		if (ret < 0)
>> +			goto end;
>> +
>> +		ret = ckpt_kwrite(ctx, h, sizeof(*h));

OL> The 'struct ckpt_hdr' part of @h was already written in the call
OL> to ckpt_write_obj_type() above.

I'll admit that the increased complexity of header and object writing
recently has me a bit unsure of what to do when, but I'm not sure how
it is not failing to run if you're correct.  Certainly restore would
get out of sync with the headers if there was an extra ckpt_hdr in the
stream, no?

Anyway, I've changed that bit to avoid the unnecessary appearance that
the buffer data is actually part of the ckpt_hdr_socket_buffer
structure.  It would never be optimal to read it that way anyway.

OL> I wonder if we need to consider this: With unix domain sockets,
OL> when a connected, or unconnected dgram socket is (re)connected or
OL> disconnected, IIRC, all the existing data in the receive buffers
OL> is removed.

OL> I suppose this will automagically be enforced, because when you
OL> connect the socket, old buffers will be discarded already, and if
OL> it is already connected, then sending from other sockets (not
OL> peer) will fail.

OL> So I think we're protected from such malicious data. Perhaps this
OL> is worth a comment ?

While swizzling things to handle SOCK_DEAD, I explicitly avoid writing
buffers for DEAD sockets (like LISTEN sockets).  That should make it
clear enough, right?

OL> Hmmm... I suspect this is plain wrong. Objects that are treated
OL> via checkpoint_obj() and restore_obj() should only be added to the
OL> objhash via these two functions.

OL> Because at checkpoint you used un->peer = checkpoint_obj(...), a
OL> ckpt_obj_fetch() on @un->peer _must_ return the matching object,
OL> or the image file data is invalid.

No, because the restore() may be a result of another restore() not yet
completed, right?  If I'm restoring A, which restores B as a
side-effect, the restore of B will expect to see its peer (A) as
already in the objhash or it will fail.

OL> Unfortunately, neither restore_obj() nor ckpt_obj_insert() will
OL> complain about adding the same objref twice...

That's going to be a problem for other scenarios where we have a
circular dependency, right?

Assume A and B have buffers outstanding for each other.  When we
restore A, we restore the first buffer and see that we need to restore
B.  While restoring B's first buffer, we see think that we need to
restore A because it's not in the objhash yet, and then we're stuck.

We could permit the restore function to insert itself (if necessary)
and then we could check before re-insert it after ops->restore(),
right?

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
