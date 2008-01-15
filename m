From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] An attempt to have an unlimitedly extendable sys_clone
Date: Tue, 15 Jan 2008 09:54:20 -0800
Message-ID: <1200419660.22674.68.camel@localhost>
References: <478CAC32.4080809@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <478CAC32.4080809-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2008-01-15 at 15:50 +0300, Pavel Emelyanov wrote:
> +static struct long_clone_arg *get_long_clone_arg(int __user
> *child_tidptr)
> +{
> +       int size;
> +       struct long_clone_arg *carg;
> +
> +       if (get_user(size, child_tidptr))
> +               return ERR_PTR(-EFAULT);
> +
> +       if (size > sizeof(struct long_clone_arg))
> +               return ERR_PTR(-EINVAL); 

This little bit means that any newer app (with a large
long_clone_arg->size) trying to run on an older kernel (with a smaller
struct) would simply fail to run clone().  Perhaps it shouldn't be _so_
generic as to allow anything in the struct and should stick to bits.
That way, we can actually go look to see whether there are any _unknown_
bits set just like we do now with clone flags.

The more I think about this, the more nervous I get about it.  It is
really neat, but has a bit of the stink of ioctl()s on it.  I'd
personally rather see a new system call.

But, this seems like a good Linus question.  Want to keep us on cc, but
run it by him (and the rest of LKML)?

-- Dave
