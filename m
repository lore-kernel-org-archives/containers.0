From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] Add support for in-kernel process creation during
	restart
Date: Tue, 25 Nov 2008 03:45:11 +0300
Message-ID: <20081125004024.GA4440__38836.7880289026$1227573828$gmane$org@x200.localdomain>
References: <1227541175-30301-1-git-send-email-major@openvz.org>
	<1227541175-30301-2-git-send-email-major@openvz.org>
	<1227541175-30301-3-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1227541175-30301-3-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Nov 24, 2008 at 06:39:35PM +0300, Andrey Mirkin wrote:
> +static int cr_rstr_task_struct(struct cr_ctx *ctx, struct cr_hdr_task *ht)
> +{
> +	struct task_struct *t = current;
> +	char *buf;
> +	int ret = -EINVAL;
> +
> +	/* upper limit for task_comm_len to prevent DoS */
> +	if (ht->task_comm_len < 0 || ht->task_comm_len > PAGE_SIZE)
> +		goto out;
> +
> +	buf = kmalloc(ht->task_comm_len, GFP_KERNEL);
> +	if (!buf)
> +		goto out;
> +	ret = cr_read_string(ctx, buf, ht->task_comm_len);
> +	if (!ret) {
> +		/* if t->comm is too long, silently truncate */
> +		memset(t->comm, 0, TASK_COMM_LEN);
> +		memcpy(t->comm, buf, min(ht->task_comm_len, TASK_COMM_LEN));
> +	}
> +	kfree(buf);
> +
> +	/* FIXME: restore remaining relevant task_struct fields */
> +out:
> +	return ret;
> +}

->comm is only 16 bytes wide, you can just use on-stack variable.
