From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Add a ckpt_read_string() function (v3)
Date: Tue, 04 Aug 2009 16:56:34 -0500
Message-ID: <m3eirr450t.fsf@pobox.com>
References: <1249418420-807-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1249418420-807-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Dan Smith's
	message of "Tue\,  4 Aug 2009 13\:40\:20 -0700")
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

Hi Dan,

Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> +/**
> + * ckpt_read_string - read a string (variable length)
> + * @ctx: checkpoint context
> + * @str: pointer to buffer to store allocated string (caller must kfree())
> + * @max: maximum acceptable length
> + *
> + * This can be used to read a variable-length string from the checkpoint
> + * stream. @max limits the size of the resulting buffer.  Returns zero on
> + * success, negative on failure.
> + */
> +int ckpt_read_string(struct ckpt_ctx *ctx, char **str, int max)
> +{
> +	int len;
> +	int ret = 0;
> +
> +	*str = NULL;
> +
> +	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_STRING);
> +	if (len < 0)
> +		return len;
> +	else if (len > max)
> +		return -EINVAL;
> +
> +	*str = kzalloc(len + 1, GFP_KERNEL);
> +	if (!*str)
> +		return -ENOMEM;
> +
> +	ret = ckpt_kread(ctx, *str, len);
> +	if (ret < 0) {
> +		kfree(*str);
> +		*str = NULL;
> +	}
> +
> +	return ret;
> +}

Maybe I'm missing the utility this provides, but I think this helper is
trying to do too much.  It's often more straightforward to allow (or
force, depending on your POV) the caller to handle the allocation if
it's going to have to free it anyway.  It also allows the caller to
choose its own allocation method, e.g. on-stack for small things, or
maybe some filesystem-related code will need to use GFP_NOFS.

So I imagine a simple wrapper to probe the length of the string would
suffice?  Something like

ssize_t ckpt_next_string_length(struct ckpt_ctx *ctx)
{
        return _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_STRING);
}

...

len = ckpt_next_string_length(ctx);
if (len < 1 || len > max)
   return -EINVAL;

buf = kzalloc(len, GFP_KERNEL);
if (!buf)
   return -ENOMEM;

rc = ckpt_kread(ctx, buf, len);
if (rc < 0) {
   kfree(buf)
   return -EINVAL;
}

kfree(buf);
