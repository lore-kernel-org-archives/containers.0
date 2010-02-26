From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 10/12] Move uts ns into kernel/utsname*.c
Date: Fri, 26 Feb 2010 12:49:14 -0600
Message-ID: <1267210154.15300.110.camel@localhost.localdomain>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
	<3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
	<5d3d0d1f5d294ccd13453a19c15828faa789bb0f.1267173752.git.matthltc@us.ibm.com>
	<06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc@us.ibm.com>
	<e3af5631e13c748bb0cc16fb9281b582f4d8d079.1267173752.git.matthltc@us.ibm.com>
	<4f4de129024a206dad6ef5484d3eed3b8426d16d.1267173752.git.matthltc@us.ibm.com>
	<d07190b20cd4f1db380c11e1baaa337a814626f6.1267173752.git.matthltc@us.ibm.com>
	<6351cfb95abae11068f8e4d8a700562ac0bd211d.1267173752.git.matthltc@us.ibm.com>
	<385a4b0ab0cf5cf2bf2fc33a8668ae0d98c45687.1267173752.git.matthltc@us.ibm.com>
	<c3d5659bdb38b39c1542d9c87381579cfd9ad5ba.1267173752.git.matthltc@us.ibm.com>
	<a400fe6d2e9e15803dd364cb551e34d6ba75b099.1267173752.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <a400fe6d2e9e15803dd364cb551e34d6ba75b099.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Fri, 2010-02-26 at 00:45 -0800, Matt Helsley wrote:
> Unlike other checkpoint object ops we're moving out of checkpoint/objhash.c,
> the one for uts namespaces needs to be defined even if CONFIG_UTS_NS is not.
> Because the definitions used in kernel/utsname_sysctl.c can come from
> kernel/utsname.c, we declare them in include/linux/utsname.h. If the
> definitions are missing then utsname_sysctl.c defines its own.
> 

...

> diff --git a/kernel/utsname.c b/kernel/utsname.c
> index c82ed83..865a6f4 100644
> --- a/kernel/utsname.c
> +++ b/kernel/utsname.c
> @@ -74,3 +74,88 @@ void free_uts_ns(struct kref *kref)
>  	ns = container_of(kref, struct uts_namespace, kref);
>  	kfree(ns);
>  }
> +
> +#ifdef CONFIG_CHECKPOINT
> +/* default debug level for output */
> +#undef CKPT_DFLAG
> +#define CKPT_DFLAG  CKPT_DSYS
> +#include <linux/checkpoint.h>
> +#include <linux/checkpoint_hdr.h>

I don't have any problem with #ifdef CONFIG_CHECKPOINT around blocks of
functions -- it's pretty much unavoidable and it's common practice.  But
#undef and #include in such an #ifdef block are somewhat unusual, and in
this case they seem to be additions, not code movement.  Can you explain
what's going on here?
