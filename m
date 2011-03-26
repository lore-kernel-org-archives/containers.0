From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [user-cr PATCH 1/1] Fix x86-64 syscall numbers
Date: Fri, 25 Mar 2011 22:08:03 -0400
Message-ID: <4D8D4A83.7070607@cs.columbia.edu>
References: <20110214164438.GA16666@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110214164438.GA16666@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Hmm... this is because:

1) Need to s/clone_with_pids/eclone/ in scripts/extract-headers.sh, and
2) Properly run scripts/extracr-headers.sh before pushing user-cr.

Will do for v23-rc2.

Oren.

On 02/14/2011 11:44 AM, Serge E. Hallyn wrote:
> Signed-off-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  clone_x86_64.c             |    2 +-
>  include/linux/checkpoint.h |    4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/clone_x86_64.c b/clone_x86_64.c
> index 5a22093..6750786 100644
> --- a/clone_x86_64.c
> +++ b/clone_x86_64.c
> @@ -26,7 +26,7 @@
>  #include "eclone.h"
>  
>  #ifndef __NR_eclone
> -#define __NR_eclone 300
> +#define __NR_eclone 303
>  #endif
>  
>  int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index b6ac12d..3688ae1 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -54,11 +54,11 @@
>  #elif __x86_64__
>  
>  #	ifndef __NR_checkpoint
> -#		define __NR_checkpoint 301
> +#		define __NR_checkpoint 304
>  #	endif
>  
>  #	ifndef __NR_restart
> -#		define __NR_restart 302
> +#		define __NR_restart 305
>  #	endif
>  
>  #else
