From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 4/4] Handle unconnected DGRAM sockets with buffers
	in-flight
Date: Thu, 13 Aug 2009 16:33:56 -0400
Message-ID: <4A8478B4.2070207@librato.com>
References: <1250191750-3864-1-git-send-email-danms@us.ibm.com>
	<1250191750-3864-5-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250191750-3864-5-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> This patch avoids connecting an unconnected DGRAM socket to a fake peer as
> part of the restore process.  Note that it will appear to rewrite all packets
> received as coming from a single unbound sender.

Hmm.. I think this would break recvfrom() syscall:  it eventually calls
unix_dgram_recvmsg(), which grabs the next skb (datagram) in the queue,
and fills in the address of the socket from which the datagram had been
sent (af_unix.c:1672)

	if (msg->msg_name)
		unix_copy_addr(msg, skb->sk);

?

The more I think about it, it seems better to also checkpoint those
unconnected sockets that are the source of dgrams. IOW, when looping
through the received skb's of an unconnected dgram socket, then check
the skb->sk of each pending packet, and checkpoint that socket too.

And in restore, restore those too, even though they may be orphan
(closed, not referenced by any process anymore), and send each packet
from the correct origin socket.

This, btw, will be another case of sock without sk->sk_socket...

Oren.
