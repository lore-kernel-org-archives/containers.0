From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [PATCH 01/30] headers: fixup cred.h, ipc_namespace.h
Date: Fri, 10 Apr 2009 10:47:47 +0200
Message-ID: <20090410084747.GB17962@elte.hu>
References: <20090410023248.GB27788@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090410023248.GB27788-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org


* Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> cred.h uses __init
> ipc_namespace.h uses kern_ipc_perm.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> 
>  include/linux/cred.h          |    1 +
>  include/linux/ipc_namespace.h |    2 ++
>  2 files changed, 3 insertions(+)
> 
> --- a/include/linux/cred.h
> +++ b/include/linux/cred.h
> @@ -13,6 +13,7 @@
>  #define _LINUX_CRED_H
>  
>  #include <linux/capability.h>
> +#include <linux/init.h>
>  #include <linux/key.h>
>  #include <asm/atomic.h>
>  
> --- a/include/linux/ipc_namespace.h
> +++ b/include/linux/ipc_namespace.h
> @@ -6,6 +6,8 @@
>  #include <linux/rwsem.h>
>  #include <linux/notifier.h>
>  
> +struct kern_ipc_perm;
> +

Please, not yet another forward declaration...

I believe this should be cleaned up properly, instead of sprinkling 
the kernel with random placed forward declarations.

In a cleanly structured piace of code there's rarely any need for 
forward declarations like this. There's two basic header types 
needed:

   foo_types.h       declares all the data types and constants
                     [no complex inline functions]

   foo.h             externs, complex inlines

foo.h includes all foo_types.h and bar_types.h headers it needs.

The foo_types.h file includes all other bar_types.h headers it 
depends on for its data type definitions.

foo_types.h never includes a bar.h file.

The end result will be a clean hieararchy of data types, separated 
from methods. Complex inlines dont create the incestous 
cross-dependency hell anymore and dont contaminate the foo_types.h 
files.

Yes, this is quite a bit of work, but this has been done before for 
several complex headers so it's possible to do it. Also, you 
namespace guys compounded this particular IPC headers sub-problem to 
begin with:

 | commit ae5e1b22f17983da929a0d0178896269e19da186
 | Author: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
 | Date:   Fri Feb 8 04:18:22 2008 -0800
 |
 |     namespaces: move the IPC namespace under IPC_NS option

So when touching the IPC header code please clean it up all 
properly. We need separate ipc_types.h and ipc.h headers with clean 
rules and a clean, consistent looking total presentation.

To borrow a recent phrase of hch, right now when i look at all the 
ipc related headers it looks like as if a cat barfed all over the 
place ;-)

Thanks,

	Ingo
