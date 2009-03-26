From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 3/7] make CONFIG_CHECKPOINT depend on
	CONFIG_CHECKPOINT_SUPPORT
Date: Wed, 25 Mar 2009 17:39:43 -0700
Message-ID: <1238027983.8286.441.camel@nimitz>
References: <1238022166-13422-1-git-send-email-ntl@pobox.com>
	<1238022166-13422-4-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1238022166-13422-4-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2009-03-25 at 18:02 -0500, Nathan Lynch wrote:
> 
> diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
> index e91e0fd..760c450 100644
> --- a/checkpoint/Kconfig
> +++ b/checkpoint/Kconfig
> @@ -1,6 +1,6 @@
>  config CHECKPOINT
>         bool "Enable checkpoint/restart (EXPERIMENTAL)"
> -       depends on (X86_32 || (S390 && 64BIT)) && EXPERIMENTAL
> +       depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
>         help
>           Application checkpoint/restart is the ability to save the
>           state of a running application so that it can later resume

Yeah, this is the right way to do it, very nice.

Could we add a wee little ARCH_ prepend on 'CHECKPOINT_SUPPORT' in
there?  That way, people at least know where to go looking when they
want to find out why it isn't enabled.  

-- Dave
