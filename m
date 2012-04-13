From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: problem with /proc/sysrq-trigger
Date: Fri, 13 Apr 2012 08:27:33 -0500
Message-ID: <20120413132733.GA3411@sergelap>
References: <4F87CA46.708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F87CA46.708-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> Hi all
> 
> when I using the container, I found the /proc/sysrq-trigger is not isolated with the host.
> when exec echo c > /proc/sysrq-trigger in the container,
> the host will crash too.
> 
> I don't know if it's correct.
> And if it's incorrect,can I fix this by just like this?

Certainly the fix wouldn't be right - the nsproxy is not the right thing
to validate.  It might make more sense to tie it to the pid namespace or,
when it pops into existence, the device namespace.  Device ns makes sense
as you can see the host as a device, and pidns makes sense since if you're
in a child pidns, you can't safely make assumptions about killing all
tasks.

In Ubuntu 12.04+, the apparmor profile simply refuses this write from
containers.  I'll soon need to generalize the support for that in lxc
so you can do the same with selinux and smack.

> diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
> index 05728894..da4d812 100644
> --- a/drivers/tty/sysrq.c
> +++ b/drivers/tty/sysrq.c
> @@ -865,6 +865,10 @@ EXPORT_SYMBOL(unregister_sysrq_key);
>  static ssize_t write_sysrq_trigger(struct file *file, const char __user *buf,
>                                    size_t count, loff_t *ppos)
>  {
> +       if (current->nsproxy != &init_nsproxy)
> +               return -EFAULT;
> 
>         if (count) {
>                 char c;
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
