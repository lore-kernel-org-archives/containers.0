From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] mktree: long is bigger on 64-bit (v2)
Date: Thu, 14 May 2009 06:12:39 -0400
Message-ID: <4A0BEE97.1000409@cs.columbia.edu>
References: <20090514022932.GA29738@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090514022932.GA29738-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan T Lynch <natlynch-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

applied, thanks.

Serge E. Hallyn wrote:
> mktree's hash function assumes that long is 32 bits.  Fix.
> 
> This version takes Nathan's suggestion of using sizeof(key)
> instead of sizeof(long).
> 
> Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  mktree.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mktree.c b/mktree.c
> index 7a8cecc..c1f13b8 100644
> --- a/mktree.c
> +++ b/mktree.c
> @@ -1291,7 +1291,7 @@ static void hash_exit(struct ckpt_ctx *ctx)
>  static inline int hash_func(long key)
>  {
>  	unsigned long hash = key * GOLDEN_RATIO_PRIME_32;
> -	return (hash >> (32 - HASH_BITS));
> +	return (hash >> (sizeof(key)*8 - HASH_BITS));
>  }
>  
>  static int hash_insert(struct ckpt_ctx *ctx, long key, void *data)
