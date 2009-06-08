From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support (v2)
Date: Mon, 08 Jun 2009 14:15:25 -0700
Message-ID: <87eitus9zm.fsf@caffeine.danplanet.com>
References: <1244226434-8167-1-git-send-email-danms@us.ibm.com>
	<4A2CA97D.1060002@cs.columbia.edu>
	<87iqj6sqvs.fsf@caffeine.danplanet.com>
	<4A2D5AD2.40805@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A2D5AD2.40805-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of "Mon\,
	08 Jun 2009 14\:39\:14 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

OL> I meant that it's better to have it in one file/place. So we
OL> agree.  (Because right now sock_file_restore() and
OL> __sock_file_restore() are separated into two files).

Ah, I see.  The reason for that was because I needed a static function
in socket.c for the restart function.  However, I can make that
cleaner.

OL> Is that for stream or dgram socket ?

Both, AFAIK.

OL> For stream sockets that shouldn't really matter for the
OL> application.  There is nothing in posix that mandates such
OL> behavior, and all apps should be ready to retry the read.

It shouldn't matter, I agree.  However, it may change the way the app
behaves depending on whether it's just been restored or not.  Plus,

OL> For dgram sockets of course we should maintain dgram boundaries.

Why special-case stream?

h-> state may hold arbitrary value, and in particular not
OL> necessarily in agreement with h->sock_state :(
>> 
>> ...I'm not sure I follow :)

OL> You need to check what the user provides in the header for that
OL> field before putting it inside a kernel data structure. In this
OL> particular case, it must "agree" with sk_state as well: the set of
OL> valid values depends on the value already in (and validate for)
OL> h->sock_state.

Oh, I missed your point entirely before.  Thanks.

OL> Maybe because I haven't seen your INET code, so I can't comment.

Not that this helps, but:

 checkpoint/sys.c                 |    3 
 include/linux/checkpoint_hdr.h   |   94 ++++++++++++
 include/linux/checkpoint_types.h |    2 
 net/ipv4/inet_connection_sock.c  |    3 
 net/socket_cr.c                  |  288 +++++++++++++++++++++++++++++++++++++++
 5 files changed, 390 insertions(+)

That's about as much as should see the light of day yet.  It needs a
whole bunch of cleanup :)

OL> Personally I tend to stay away from unneeded tinkering of complex
OL> kernel data structures. Needing to rebuilding the tcp control
OL> block by hand, which is what I assume you'll be doing, is
OL> something I'd like to avoid.

It works effectively the same way the unix patch does, yes.

OL> Connect() succeeds as soon as the listening socket can ack the
OL> connection (both INET and UNIX).

OL> The to-be-accepted - aka 'pending' sock (not yet socket) is kept
OL> with the listening socket in a (backlog) queue. In UNIX sockets
OL> it is put in a skb. In INET it's a real queue.

OL> A subsequent accept() will succeed immediately by accepting that
OL> pending sock and attaching it to a proper socket.

Okay, I'll switch it to this and see what it looks like.

OL> Non locally connected sockets are different - because you only
OL> restore _one_ side of the connection, not both. And it requires
OL> more tinkering.

Well, not in my approach, of course.  The way I have the inet stuff
done, I yank the socket into being.  If you have two halves that
happen to point at each other, then they will be connected after
restart.  If not, and you only restore one half, it's still connected
to whatever is on the other end (provided it didn't go away).

OL> But for locally connected sockets, what's the point in saving the
OL> protocol specific state (which isn't socket-state), like sequence
OL> numbers, acks, retransmits etc ?

Symmetry with the non-special case?

OL> INET sockets connected to remote machines is a complex case.  One
OL> way is to manually restore all the network stack for a
OL> connection. Another is to use connect/accept and fool the kernel
OL> to build what we want.

Well, approaching this from the container point of view, I'd expect to
have a veth device that can be shut down ahead of time to stop arping
for the destination address, avoid a RST while monkeying with the
connection, etc.

OL> I suggest that we start by handling listening sockets (easy),
OL> closing previously connected sockets (as if connection broke,
OL> like after a suspend/resume), and get some feedback from the
OL> networking people.

Sounds good.  I'll make some of the above changes to the unix patch
and re-post, and then follow it by a patch to enable listen-only INET
sockets.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
