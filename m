From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] Syslog are now containerized
Date: Sat, 13 Feb 2010 07:50:50 -0800
Message-ID: <20100213155050.GT3714@count0.beaverton.ibm.com>
References: <201002110552.o1B5qwbL024561@kernel.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201002110552.o1B5qwbL024561-X4ZF2iejbABnc3BsFfMrZw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Thanks for working on this. Some minor style issues below:

On Thu, Feb 11, 2010 at 01:00:20AM -0500, Jean-Marc Pigeon wrote:
> 	Added syslog.c such container /proc/kmsg and host /proc/kmsg
> 	do not leak in each other.
> 	Running rsyslog daemon within a container won't destroy
> 	host kernel messages.
> ---

<snip>

> diff --git a/kernel/syslog.c b/kernel/syslog.c
> new file mode 100644
> index 0000000..69d30a9
> --- /dev/null
> +++ b/kernel/syslog.c
> @@ -0,0 +1,157 @@

<snip>

> +		(void) kfree(old_buf);
> +		}
> +	(void) printk(KERN_NOTICE "log_buf_len: %u\n", syslog_ns->buf_len);

I don't understand why you chose to put in all of the "(void)" casts.
They do nothing -- they don't change how the code works nor do they
improve the readability of the code.

> +	return syslog_ns;
> +}
> +/*
> + * Procedure to free all ressources tied to syslog
> + *
> + */
> +struct syslog_ns *syslog_free(struct syslog_ns *syslog)
> +
> +{
> +	if (syslog != (struct syslog_ns *)0) {

Why aren't you using NULL? Better yet, in these cases it's common to use:

if (syslog) {

Once this gets out of the RFC steps perhaps run these through checkpatch..

Cheers,
	-Matt Helsley
