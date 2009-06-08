From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support (v2)
Date: Mon, 08 Jun 2009 14:39:14 -0400
Message-ID: <4A2D5AD2.40805@cs.columbia.edu>
References: <1244226434-8167-1-git-send-email-danms@us.ibm.com>	<4A2CA97D.1060002@cs.columbia.edu>
	<87iqj6sqvs.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87iqj6sqvs.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
> OL> People objected to "cr" prefix/ending in file- and function-
> OL> names. I suggest "net/checkpoint.c".
> 
> Sure.  I actually had this patch started before the big rename thing,
> so I changed the functions and not the file.  net/checkpoint.c seems
> good to me.
> 
> OL> Also, is there a reason to split checkpoint_... and restore_...
> OL> code between two files ?  I'd put everything in net/checkpoint.c
> 
> Personally, I don't like that separation, and judging by the amount of
> code I currently have for UNIX and INET sockets, I think having
> everything in one file is reasonable.

I meant that it's better to have it in one file/place. So we agree.
(Because right now sock_file_restore() and __sock_file_restore() are
separated into two files).

> 
> OL> I believe you can use skb_clone() here, and avoid the actual
> OL> memory allocation and data copy.
> 
> Okay, I'll check that out.
> 
> OL> I think the GFP_ATOMIC in this case isn't that bad. But you could
> OL> get mitigate (at least some of) it by pre-allocating skb's before
> OL> grabbing the lock and then use skb_morph().
> 
> Okay.
> 
> OL> What about passed file-descriptors ?  Either handle them or fail
> OL> with an error (e.g. -EBUSY) when found.
> 
> Ah, yeah, I'll add a test and failure for now and address it later.
> 
> OL> Seems like you intend for the code to be generic and useful for
> OL> not only for unix domain sockets. Skb's may point to fragmented
> OL> data as well. If not supported, then the code should test for it
> OL> and report an error in that case.
> 
> Okay.
> 
> OL> What's the advantage of writing skb's instead of one long stream
> OL> of data ?
> 
> If the receiver does a read() on the socket of (for example) 1024 long
> and the next skb in the stack is only 512 bytes long, they'll only get
> 512 bytes back until the next read(), right?  If so, then
> restructuring the stream of data so that it behaves a little
> differently after restart seems less desirable to me.

Is that for stream or dgram socket ?

For stream sockets that shouldn't really matter for the application.
There is nothing in posix that mandates such behavior, and all apps
should be ready to retry the read.

For dgram sockets of course we should maintain dgram boundaries.

For seq_packet too.

> 
> OL> Later we'll have sock_inet_... and then others, and this file will
> OL> grow indefinitely. Perhaps place family specific logic
> OL> (sock_un_checkpoint, sock_un_restore) in the corresponding subdir
> OL> (unix/checkpoint.c) ?
> 
> If you like, sure.  It doesn't seem like enough code to justify all
> the interfaces needed between them, but if it will help to make it
> easier to read then I can do that.
> 

I expect sock_inet_.... code to aggregate code with time. On the other
hand, we can leave it as is and split when it actually grows or if
someone complains ?

> OL> bind() may also be required for TCP_ESTABLISHED or TCP_CLOSED (and
> OL> of course, to SOCK_DRGRAM).
> 
> Hmm, and how do I tell?

For unix domain sockets, if unix_sk(sk)->addr is set, then there
is a chance that it had a bind() call. A bind() can be by-inode
(via filesystem) or abstract (first character is '\0'). You can
test like this (code may be outdated) -

  int is_unixsock_bind_byinode(struct sock *sk)
  {
  	struct sock *skk;

 	if (unix_sk(sk)->dentry) {
		skk =
		unix_find_socket_byinode(unix_sk(sk)->dentry->d_inode);
		if (skk) {
			sock_put(skk);
			return (sk == skk);
		}
	}
	return 0;
  }

  int is_unixsock_bind_byname(struct sock *sk)
  {
	struct unix_address *addr = unix_sk(sk)->addr;
	unsigned short type = sk_memb(sk, type);
	/* see net/unix/af_unix.c to explain this xor: */
	unsigned hash = addr->hash ^ type;
	struct sock *skk;

        read_lock(&unix_table_lock);
        skk = __unix_find_socket_byname(addr->name, addr->len,
					type, hash);
        read_unlock(&unix_table_lock);
	return (sk == skk);
}

If a test succeeds, you need to bind it explicitly. If it fails,
(and unix_sk(sk)->addr is not NULL), it means that the address
was inherited from the listening socket.  This is also how you
can tell between a connect and an accept side of a connection.

> 
> OL> Also, usually when you checkpoint a listening socket with a
> OL> standard (non-abstract) address, the socket inode will exist in
> OL> the file system. So it will be there on restart (assuming the file
> OL> system view was restored too, e.g. from snapshot).  So bind() will
> OL> fail with -EADDRINUSE.
> 
> OL> Therefore you need to first unlink() the desired pathname.
> 
> OL> And if it wasn't there, you need to unlink() after the bind()...
> 
> I had a conversation about this with someone privately at one point
> and the thought was that userspace should handle removing the path
> before restart.  It seems to make sense to me, to avoid having the
> kernel unlink() something as a side effect of the restart when there
> should be a userspace component managing more of the high-level
> stuff.

To me the opposite makes sense. I don't see anything wrong with
the kernel unlink()ing it (temporarily).

At checkpoint time, the pathname may, or may not, exist (could have
been removed, and even re-created).

If you unlink it from userspace, how would you ensure that the file
is gone after the restart succeeds ?

> 
> h-> state may hold arbitrary value, and in particular not
> OL> necessarily in agreement with h->sock_state :(
> 
> ...I'm not sure I follow :)

You need to check what the user provides in the header for that field
before putting it inside a kernel data structure. In this particular
case, it must "agree" with sk_state as well: the set of valid values
depends on the value already in (and validate for) h->sock_state.

> 
> OL> Missing call to sock_cptrst() ?  And in that case, will need to
> OL> sanitize the data.
> 
> Whoops, that must have been a casualty of splitting out the UNIX and
> INET bits :)
> 
> OL> The local addresses of sockets are not restored. This means that
> OL> getpeername() will not give the expected result.
> 
> Heh, this too.
> 
> OL> I also wonder how this scheme will end up working when we add
> OL> support to INET sockets - at first, locally connected. I like the
> OL> simplicity of your approach that creates two separate sockets and
> OL> manually connect them. Unfortunately, this "manually" is going to
> OL> be very complicated with INET sockets.
> 
> Well, it doesn't seem too bad thus far, FWIW.

Maybe because I haven't seen your INET code, so I can't comment.

Personally I tend to stay away from unneeded tinkering of complex
kernel data structures. Needing to rebuilding the tcp control
block by hand, which is what I assume you'll be doing, is something
I'd like to avoid.

> 
> OL> Here's an alternative approach for SOCK_STEAM sockets (SOCK_DGRAM
> OL> later):
> 
> OL> A socket may be either listening, connect or accept (dgram: only
> OL> connect). If a socket is not connected, then c/r is relatively
> OL> easy.
> 
> OL> -- Checkpoint:
> 
> OL> If it is connected, then locate the correspondig other sockets:
> OL> listening (L), connect (C) and accept (A). Checkpoint them in
> OL> this order (regardless of which socket you hit first).
> 
> OL> If you first find the (L), then checkpoint it alone If it has
> OL> not-yet-accepted sockets pending, say (a1, a2), then locate
> OL> their corresponding (C1), (C2), and checkpoint (C1), (a1) and
> OL> then (C2), (a2) etc.
> 
> OL> If for a pair (C)-(A), the (L) was already checkpointed, then
> OL> save the objref only.
> 
> OL> If for a pair (C)-(A), the (L) does not exist anymore then save
> OL> objref=0 (objrefs are otherwise always > 0).
> 
> OL> -- Restart:
> 
> OL> When seeing an (L), create a listening socket. (If need to
> OL> later unlink the pathname, defer this to end of checkpoint).
> 
> OL> When seeing a (C), read it in, connect to the corresponding
> OL> (L). If there was no (L), create a temporary one. If the
> OL> peer was accepted, then accept to create (A), else leave as
> OL> is to create (a). Add both (C) and (A)/(a) to the objhash.
> 
> I assume you mean using connect() and accept() to simulate this
> interaction.  How do you handle doing this within one thread when
> connect() will block you before you get to accept()?  I must be
> missing some subtlety about the ordering.

Yes, of course:  using connect() and accept().

One thread is enough, provided that the connect() is done first:

Connect() succeeds as soon as the listening socket can ack the
connection (both INET and UNIX).

The to-be-accepted - aka 'pending' sock (not yet socket) is kept
with the listening socket in a (backlog) queue. In UNIX sockets
it is put in a skb. In INET it's a real queue.

A subsequent accept() will succeed immediately by accepting that
pending sock and attaching it to a proper socket.

> 
> OL> When seeing an (A) or (a), ckpt_obj_fetch() must succeed and
> OL> there is little work to do.
> 
> OL> --- For SOCK_DGRAM
> 
> OL> Here, each socket may be "connected" (in the DGRAM sense) to
> OL> another, or even to itself. To checkpoint, first save the
> OL> socket, then the peer, then connect - similar to what you
> OL> do now, but with a real "connect()" call, to get the full
> OL> behind-the-scenes effect.  For INET sockets, it's even
> OL> simpler.
> 
> OL> ---
> 
> OL> The advantages of this approach are:
> 
> OL> - You care not about the internals of socket connection, or
> OL>   not-yet-accepted sockets.
> 
> With respect to the state of things, I suppose that's true.  However,
> we'll still need to restore a fair bit of information about the socket
> settings (state, counters, etc) if we want to support anything other
> than trivial locally-connected sockets.  From memory, restoring the
> state of the sockets is a fraction of the rest of it.

Non locally connected sockets are different - because you only restore
_one_ side of the connection, not both. And it requires more tinkering.

But for locally connected sockets, what's the point in saving the
protocol specific state (which isn't socket-state), like sequence
numbers, acks, retransmits etc ?

> 
> OL> - The local- and peer-addresses are all set automagically.
> 
> OL> - It should work for INET sockets (locally connected, e.g.
> OL>   to localhost), without caring about e.g. TCP seq-numbers).
> 
> ...and what about non-local sockets?  I'm not sure I see how the above
> will work for INET sockets connected to remote machines, which is an
> important thing to support for migration.  Can you elaborate?

INET sockets connected to remote machines is a complex case.
One way is to manually restore all the network stack for a
connection. Another is to use connect/accept and fool the
kernel to build what we want.

I suggest that we start by handling listening sockets (easy),
closing previously connected sockets (as if connection broke,
like after a suspend/resume), and get some feedback from the
networking people.

Oren.
