From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC] Change socket checkpoint to retain DGRAM source addresses
Date: Tue, 25 Aug 2009 00:33:11 -0400
Message-ID: <4A936987.7070405@librato.com>
References: <1251133918-8117-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251133918-8117-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> This is a proposed change to the way sockets are checkpointed.
> It makes the socket itself a proper objhash object, which can be
> checkpointed or restored as part of reading the stream (like many
> of the other first-class objects).  Thus, we worry about
> checkpointing and restoring the socket-typed file, and read the
> related socket object(s) as a matter of course.
> 
> By doing this, we are able to checkpoint sockets we find that
> aren't attached to descriptors.  This is used in the final patch
> to make sure that a socket buffer's owner socket has been
> checkpointed, allowing us to use that socket to re-send the
> buffer on restore (thus retaining the source address).

It will also be useful when restoring two other important cases:

1) A listening socket that with "pending" connections - that is,
established connections for which the app should call accept().

2) Sockets that are "dangling": have been closed by the owner
process but linger in the system because they are referenced
somehow (through skb, peer etc).

> 
> I've got a unit test for this that sets up three sockets, and
> loads some in-flight buffers before checkpoint, verifying that
> after checkpoint, recvfrom() sees them from the appropriate
> source socket.
> 
> Does this approach seem reasonable?  
> 

Yep.

Oren.
