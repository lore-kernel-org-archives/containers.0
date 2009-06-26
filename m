From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Add AF_INET c/r support
Date: Fri, 26 Jun 2009 15:09:06 -0700
Message-ID: <20090626220906.GF17502@count0.beaverton.ibm.com>
References: <1245697976-29159-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1245697976-29159-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Mon, Jun 22, 2009 at 12:12:56PM -0700, Dan Smith wrote:
> This patch adds AF_INET c/r support based on the framework established in
> my AF_UNIX patch.  I've tested it by checkpointing a single app with a
> pair of sockets connected over loopback.
> 
> I expect a pile of comments :)
> 
> A couple points about the operation:
> 
>  1. In order to properly hook up the established sockets with the matching
>     listening parent socket, I added a new list to the ckpt_ctx and run the
>     parent attachment in the deferqueue at the end of the restart process.
>  2. I don't do anything to redirect or freeze traffic flowing to or from the
>     remote system (to prevent a RST from breaking things).  I expect that
>     userspace will bring down a veth device or freeze traffic to the remote
>     system to handle this case.
> 
> Cc: Oren Laaden <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/sys.c                 |    2 +
>  include/linux/checkpoint_hdr.h   |    1 +
>  include/linux/checkpoint_types.h |    2 +
>  include/linux/socket.h           |   95 ++++++++++
>  net/checkpoint.c                 |  369 +++++++++++++++++++++++++++++++++-----
>  5 files changed, 428 insertions(+), 41 deletions(-)
> 
> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 38a5299..b6f18ea 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -242,6 +242,8 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
>  	INIT_LIST_HEAD(&ctx->pgarr_pool);
>  	init_waitqueue_head(&ctx->waitq);
> 
> +	INIT_LIST_HEAD(&ctx->listen_sockets);
> +
>  	err = -EBADF;
>  	ctx->file = fget(fd);
>  	if (!ctx->file)
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 46285f8..0a19767 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -87,6 +87,7 @@ enum {
>  	CKPT_HDR_SOCKET_BUFFERS,
>  	CKPT_HDR_SOCKET_BUFFER,
>  	CKPT_HDR_SOCKET_UN,
> +	CKPT_HDR_SOCKET_IN,

Nano-nit: I think it's easier to read if we call these CKPT_HDR_SOCKET_UNIX 
and CKPT_HDR_SOCKET_INET. The extra 2 characters are worth that. This also
applies to the struct names later in the patch.

Cheers,
	-Matt Helsley
