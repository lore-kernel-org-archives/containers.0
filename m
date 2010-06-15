From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 2/3] Make extract_headers.sh bring out the __NR_setns
	symbol
Date: Tue, 15 Jun 2010 10:30:12 -0400
Message-ID: <4C178E74.1000108@cs.columbia.edu>
References: <1274884956-21005-1-git-send-email-danms@us.ibm.com>
	<1274884956-21005-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274884956-21005-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



On 05/26/2010 10:42 AM, Dan Smith wrote:
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  scripts/extract-headers.sh |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/scripts/extract-headers.sh b/scripts/extract-headers.sh
> index 8c8ae69..0deed98 100755
> --- a/scripts/extract-headers.sh
> +++ b/scripts/extract-headers.sh
> @@ -144,7 +144,7 @@ echo '#endif /* _CHECKPOINT_CKPT_HDR_H_ */' >> "${OUTPUT_INCLUDES}/linux/checkpo
>  # We use ARCH_COND to break up architecture-specific sections of the header.
>  #
>  ARCH_COND='#if'
> -REGEX='[[:space:]]*#[[:space:]]*define[[:space:]]*__NR_(checkpoint|restart|clone_with_pids)[[:space:]]+[0-9]+'
> +REGEX='[[:space:]]*#[[:space:]]*define[[:space:]]*__NR_(checkpoint|restart|clone_with_pids|setns)[[:space:]]+[0-9]+'

Which reminds me that "clone_with_pids" is now "eclone" ...

Oren.

>  
>  cat - <<-EOFOE
>  /*
