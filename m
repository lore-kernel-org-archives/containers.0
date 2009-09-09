From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/3] Make sockets proper objhash objects and
	use	checkpoint_obj() on them (v2)
Date: Wed, 09 Sep 2009 19:02:13 -0400
Message-ID: <4AA833F5.3040706@librato.com>
References: <1252508756-4278-1-git-send-email-danms@us.ibm.com>
	<1252508756-4278-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1252508756-4278-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> This changes the checkpoint/restart procedure for sockets a bit.  The
> socket file header is now checkpointed separately from the socket itself,
> which allows us to checkpoint a socket without arriving at it from a
> file descriptor.  Thus, most sockets will be checkpointed as a result
> of processing the file table, calling sock_file_checkpoint(fd), which
> in turn calls checkpoint_obj(socket).
> 
> However, we may arrive at some sockets while checkpointing other objects,
> such as the other end of an AF_UNIX socket with buffers in flight.  This
> patch just opens that door, which is utilized by the next patch.
> 
> Changes in v2:
>  - If we attempt to checkpoint an orphan socket, create a struct socket
>    to adopt it for the purposes of the checkpoint
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Looks good !

Did you also address this ?
https://lists.linux-foundation.org/pipermail/containers/2009-September/020385.html

-----
SH> Yes.  On the struct sock.  But what will drop the ref on the
SH> struct socket?  Or has one of your later patches, not yet in
SH> ckpt-v17-dev, added that?  Or, am I just missing a place where
SH> sock_put() will actually sock_release(sk->sk_socket)?

Hmm, I see what you mean.  I can't find any path where sock_put() will
release the struct socket.  What's weird is that there is a WARN_ON()
in af_unix.c:354 that should get tripped if we call sk_free() when we
still have a socket.  I don't see that, but now I'm not sure why.

Perhaps what we should do is orphan the struct sock before we add it
to the hash and then graft it onto a new struct socket before
attaching it to a struct file?
-----

[The reason sk_free() expects no sk_socket is because the socket at
this point must have been released already via proto_ops->release().
The callback is assumed to orphan the socket].

Oren.
