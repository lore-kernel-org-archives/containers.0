From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [linux-cr PATCH 1/1] update x86-64 eclone and cr syscall numbers
Date: Fri, 25 Mar 2011 22:06:14 -0400
Message-ID: <4D8D4A16.3080908@cs.columbia.edu>
References: <20110214164644.GA16802@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110214164644.GA16802@localhost>
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

Pulled for v23-rc2... thanks.

Oren.

On 02/14/2011 11:46 AM, Serge E. Hallyn wrote:
> (for ckpt-v23-rc1-pids branch)
> 
> Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  arch/x86/include/asm/unistd_64.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
> index 706d90a..f5d1b9e 100644
> --- a/arch/x86/include/asm/unistd_64.h
> +++ b/arch/x86/include/asm/unistd_64.h
> @@ -671,9 +671,9 @@ __SYSCALL(__NR_fanotify_mark, sys_fanotify_mark)
>  __SYSCALL(__NR_prlimit64, sys_prlimit64)
>  #define __NR_eclone				303
>  __SYSCALL(__NR_eclone, stub_eclone)
> -#define __NR_checkpoint				301
> +#define __NR_checkpoint				304
>  __SYSCALL(__NR_checkpoint, stub_checkpoint)
> -#define __NR_restart				302
> +#define __NR_restart				305
>  __SYSCALL(__NR_restart, stub_restart)
>  
>  #ifndef __NO_STUBS
