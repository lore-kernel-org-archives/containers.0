From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] fix checkpoint header exports
Date: Mon, 15 Jun 2009 15:54:54 -0400
Message-ID: <4A36A70E.1080804@cs.columbia.edu>
References: <m37hze2ib6.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m37hze2ib6.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Thanks, will apply.

git.ncl.cs.columbia.edu was down due to departmental network
issues. It's back to life.

Oren.

Nathan Lynch wrote:
> checkpoint_types.h is not useful to userspace.  Unexport it.
> 
> checkpoint.h contains definitions that userspace needs.  Export it.
> 
> user-cr can now be built against exported headers.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> 
> ---
> 
> (against ckpt-v16-x86 as of a couple days ago; git.ncl.cs.columbia.edu
> appears unresponsive atm)
> 
>  include/linux/Kbuild |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/Kbuild b/include/linux/Kbuild
> index 25b7c0e..df43556 100644
> --- a/include/linux/Kbuild
> +++ b/include/linux/Kbuild
> @@ -44,7 +44,7 @@ header-y += bpqether.h
>  header-y += bsg.h
>  header-y += can.h
>  header-y += cdk.h
> -header-y += checkpoint_types.h
> +header-y += checkpoint.h
>  header-y += checkpoint_hdr.h
>  header-y += chio.h
>  header-y += coda_psdev.h
