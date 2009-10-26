From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] [RFC] Checkpoint/restart eventfd
Date: Mon, 26 Oct 2009 16:41:37 -0400
Message-ID: <4AE60981.50706@librato.com>
References: <1256447590-31138-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256447590-31138-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> Save/restore eventfd files. These are anon_inodes just like epoll
> but instead of a set of files to poll they are a 64-bit counter
> and a flag value. Used for AIO.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> NOTE: Marked [RFC] because it strangely does not pass my adapted LTP
> 	test cases unless it's running from a checkpointed image.
> 	Seems to be a mistake in the test case adaptation.
> ---

[...]

> @@ -223,11 +225,34 @@ static ssize_t eventfd_write(struct file *file, const char __user *buf, size_t c
>  	return res;
>  }

Following should be within #if/#endif CONFIG_CHECKPOINT, and same
for eventfd_restart(). (fix it when pulled).

>  
> +static int eventfd_checkpoint(struct ckpt_ctx *ckpt_ctx, struct file *file)
> +{
> +	struct eventfd_ctx *ctx;
> +	struct ckpt_hdr_file_eventfd *h;
> +	int ret = -ENOMEM;

[...]

Oren.
