From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] CONFIG_SECURITY_FILE_CAPABILITIES has been gone awhile
Date: Fri, 30 Apr 2010 21:29:05 -0400
Message-ID: <4BDB83E1.10308@cs.columbia.edu>
References: <20100430234224.GA19790@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100430234224.GA19790-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Applied for v21.

Serge E. Hallyn wrote:
> Thanks Matt for noticing the sbits testcase was screaming at us
> about this being broken!
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/capability.c |   16 ----------------
>  1 files changed, 0 insertions(+), 16 deletions(-)
> 
> diff --git a/kernel/capability.c b/kernel/capability.c
> index ccb8907..c39d6b0 100644
> --- a/kernel/capability.c
> +++ b/kernel/capability.c
> @@ -316,7 +316,6 @@ SYSCALL_DEFINE2(capset, cap_user_header_t, header, const cap_user_data_t, data)
>  
>  }
>  
> -#ifdef CONFIG_SECURITY_FILE_CAPABILITIES
>  int apply_securebits(unsigned securebits, struct cred *new)
>  {
>  	if ((((new->securebits & SECURE_ALL_LOCKS) >> 1)
> @@ -361,21 +360,6 @@ static inline int restore_cap_bset(kernel_cap_t bset, struct cred *cred)
>  	return 0;
>  }
>  
> -#else /* CONFIG_SECURITY_FILE_CAPABILITIES */
> -
> -int apply_securebits(unsigned securebits, struct cred *new)
> -{
> -	/* settable securebits not supported */
> -	return 0;
> -}
> -
> -static inline int restore_cap_bset(kernel_cap_t bset, struct cred *cred)
> -{
> -	/* bounding sets not supported */
> -	return 0;
> -}
> -#endif /* CONFIG_SECURITY_FILE_CAPABILITIES */
> -
>  #ifdef CONFIG_CHECKPOINT
>  static int do_restore_caps(struct ckpt_capabilities *h, struct cred *cred)
>  {
