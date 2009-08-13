From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] Handle unconnected DGRAM sockets with buffers
	in-flight
Date: Thu, 13 Aug 2009 13:39:50 -0700
Message-ID: <87my63phwp.fsf@caffeine.danplanet.com>
References: <1250191750-3864-1-git-send-email-danms@us.ibm.com>
	<1250191750-3864-5-git-send-email-danms@us.ibm.com>
	<4A8478B4.2070207@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A8478B4.2070207-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org> (Oren Laadan's message of "Thu\,
	13 Aug 2009 16\:33\:56 -0400")
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

OL> Hmm.. I think this would break recvfrom() syscall: it eventually
OL> calls unix_dgram_recvmsg(), which grabs the next skb (datagram) in
OL> the queue, and fills in the address of the socket from which the
OL> datagram had been sent (af_unix.c:1672)

Why would that be any different from the normal case of sending from
an unbound socket to a process receiving with recvfrom()?

OL> 	if (msg->msg_name)
OL> 		unix_copy_addr(msg, skb->sk);

If you look at unix_copy_addr() it bails if !sk->addr.

OL> The more I think about it, it seems better to also checkpoint
OL> those unconnected sockets that are the source of dgrams. IOW, when
OL> looping through the received skb's of an unconnected dgram socket,
OL> then check the skb->sk of each pending packet, and checkpoint that
OL> socket too.

That will, IMHO, make the restore process a little uglier.  I was
thinking more along the lines of saving the address of the skb's
sender (if needed) and doing something like a temporary bind of the
peer before sending the buffer on restore.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
