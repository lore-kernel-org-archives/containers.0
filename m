From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 08/12][user-cr] Create common.h
Date: Mon, 8 Mar 2010 13:44:27 -0600
Message-ID: <20100308194427.GB20030@us.ibm.com>
References: <20100305223439.GA15300@us.ibm.com>
	<20100305223907.GH15939@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100305223907.GH15939-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> 
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Thu, 4 Mar 2010 21:30:50 -0800
> Subject: [PATCH 08/12][user-cr] Create common.h
> 
> Code in common.h can be shared by checkpoint.c and restart.c for now.

There is already user-cr.h and restart.h...  a 'common.h' filename
isn't particularly helpful.  Should they all get combined?

Not NACking the patch, btw, just something to consider for a future
patch.

> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  Makefile     |    4 ++
>  checkpoint.c |   31 +---------------
>  common.h     |  112 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  restart.c    |  110 +--------------------------------------------------------
>  4 files changed, 119 insertions(+), 138 deletions(-)
>  create mode 100644 common.h
> 
> diff --git a/Makefile b/Makefile
> index b312358..acebdd5 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -5,6 +5,8 @@ CKPT_HEADERS = include/linux/checkpoint.h \
>  		include/linux/checkpoint_hdr.h \
>  		include/asm/checkpoint_hdr.h
> 
> +CR_OBJS = checkpoint.o restart.o
> +
>  # detect architecture (for eclone)
>  SUBARCH = $(patsubst i%86,x86_32,$(shell uname -m))
> 
> @@ -41,6 +43,8 @@ $(LIB_ECLONE):
>  # restart needs to be thread-safe
>  restart: CFLAGS += -D__REENTRANT -pthread
> 
> +$(CR_OBJS): common.h
> +
>  # eclone() is architecture specific
>  ifneq ($(SUBARCH),)
>  $(ECLONE_PROGS): $(LIB_ECLONE) 
> diff --git a/checkpoint.c b/checkpoint.c
> index ace17e2..6e91149 100644
> --- a/checkpoint.c
> +++ b/checkpoint.c
> @@ -21,6 +21,8 @@
> 
>  #include <linux/checkpoint.h>
> 
> +#include "common.h"
> +
>  static char usage_str[] =
>  "usage: ckpt [opts] PID\n"
>  "  'checkpoint' takes a checkpoint of the task indicated by PID, and all\n"
> @@ -55,35 +57,6 @@ inline static int checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
>  	return syscall(__NR_checkpoint, pid, fd, flags, logfd);
>  }
> 
> -#define BUFSIZE  (4 * 4096)
> -static inline void ckpt_msg(int fd, char *format, ...)
> -{
> -        va_list ap;
> -        char *bufp;
> -        if (fd < 0)
> -                return;
> -
> -        va_start(ap, format);
> -
> -        bufp = malloc(BUFSIZE);
> -        if(bufp) {
> -                vsnprintf(bufp, BUFSIZE, format, ap);
> -                write(fd, bufp, strlen(bufp));
> -        }
> -        free(bufp);
> -
> -        va_end(ap);
> -}
> -
> -#define ckpt_err(...)  \
> -	ckpt_msg(global_uerrfd, __VA_ARGS__)
> -
> -#define ckpt_perror(s)                                                  \
> -        do {                                                            \
> -                ckpt_msg(global_uerrfd, s);                             \
> -                ckpt_msg(global_uerrfd, ": %s\n", strerror(errno));     \
> -        } while (0)
> -
>  static void usage(char *str)
>  {
>  	ckpt_err("%s", str);
> diff --git a/common.h b/common.h
> new file mode 100644
> index 0000000..99b224d
> --- /dev/null
> +++ b/common.h
> @@ -0,0 +1,112 @@
> +#include <stdio.h>
> +#include <signal.h>
> +
> +#define BUFSIZE  (4 * 4096)
> +
> +static inline void ckpt_msg(int fd, char *format, ...)
> +{
> +	va_list ap;
> +	char *bufp;
> +	if (fd < 0)
> +		return;
> +
> +	va_start(ap, format);
> +
> +	bufp = malloc(BUFSIZE);
> +	if(bufp) {
> +		vsnprintf(bufp, BUFSIZE, format, ap);
> +		write(fd, bufp, strlen(bufp));
> +	}
> +	free(bufp);
> +
> +	va_end(ap);
> +}
> +
> +#define ckpt_perror(s) 							\
> +	do {								\
> +		ckpt_msg(global_uerrfd, s);				\
> +		ckpt_msg(global_uerrfd, ": %s\n", strerror(errno));	\
> +	} while (0)
> +
> +#ifdef CHECKPOINT_DEBUG
> +#define ckpt_dbg(_format, _args...)					\
> +	do {								\
> +		if (global_debug)					\
> +			ckpt_msg(global_uerrfd, "<%d>" _format, 	\
> +					_gettid(), ##_args); 		\
> +	} while (0)
> +#define ckpt_dbg_cont(_format, _args...)				\
> +	do {								\
> +		if (global_debug)					\
> +			ckpt_msg(global_uerrfd, _format, ##_args);	\
> +	} while (0)
> +#else
> +#define ckpt_dbg(_format, _args...)  \
> +	do { } while (0)
> +#define ckpt_dbg_cont(_format, _args...)  \
> +	do { } while (0)
> +#endif
> +
> +#define ckpt_err(...)  \
> +	ckpt_msg(global_uerrfd, __VA_ARGS__)
> +
> +#define ckpt_verbose(...)					\
> +	do {							\
> +		if (global_verbose)				\
> +			ckpt_msg(global_ulogfd, __VA_ARGS__);	\
> +	} while(0)
> +
> +struct signal_array {
> +	int signum;
> +	char *sigstr;
> +};
> +
> +#define SIGNAL_ENTRY(signal)  { SIG ## signal, #signal }
> +
> +#define INIT_SIGNAL_ARRAY { 	\
> +	{ 0, "NONE" },		\
> +	SIGNAL_ENTRY(ALRM),	\
> +	SIGNAL_ENTRY(HUP),	\
> +	SIGNAL_ENTRY(INT),	\
> +	SIGNAL_ENTRY(KILL),	\
> +	SIGNAL_ENTRY(PIPE),	\
> +	SIGNAL_ENTRY(POLL),	\
> +	SIGNAL_ENTRY(PROF),	\
> +	SIGNAL_ENTRY(TERM),	\
> +	SIGNAL_ENTRY(USR1),	\
> +	SIGNAL_ENTRY(USR2),	\
> +	SIGNAL_ENTRY(VTALRM),	\
> +	SIGNAL_ENTRY(STKFLT),	\
> +	SIGNAL_ENTRY(PWR),	\
> +	SIGNAL_ENTRY(WINCH),	\
> +	SIGNAL_ENTRY(CHLD),	\
> +	SIGNAL_ENTRY(URG),	\
> +	SIGNAL_ENTRY(TTIN),	\
> +	SIGNAL_ENTRY(TTOU),	\
> +	SIGNAL_ENTRY(STOP),	\
> +	SIGNAL_ENTRY(CONT),	\
> +	SIGNAL_ENTRY(ABRT),	\
> +	SIGNAL_ENTRY(FPE),	\
> +	SIGNAL_ENTRY(ILL),	\
> +	SIGNAL_ENTRY(QUIT),	\
> +	SIGNAL_ENTRY(SEGV),	\
> +	SIGNAL_ENTRY(TRAP),	\
> +	SIGNAL_ENTRY(SYS),	\
> +	SIGNAL_ENTRY(BUS),	\
> +	SIGNAL_ENTRY(XCPU),	\
> +	SIGNAL_ENTRY(XFSZ),	\
> +	{ -1, "LAST" },		\
> +}
> +
> +#define CKPT_COND_PIDZERO  0x1
> +#define CKPT_COND_MNTPROC  0x2
> +#define CKPT_COND_MNTPTY   0x4
> +
> +#define CKPT_COND_NONE     0
> +#define CKPT_COND_ANY      ULONG_MAX
> +
> +/* default for skip/warn/fail */
> +#define CKPT_COND_WARN     (CKPT_COND_MNTPROC | \
> +			    CKPT_COND_MNTPTY)
> +#define CKPT_COND_FAIL     (CKPT_COND_NONE)
> +
> diff --git a/restart.c b/restart.c
> index b37bf81..f65eafb 100644
> --- a/restart.c
> +++ b/restart.c
> @@ -40,6 +40,7 @@
>  #include "eclone.h"
>  #include "genstack.h"
>  #include "compat.h"
> +#include "common.h"
> 
>  static char usage_str[] =
>  "usage: restart [opts]\n"
> @@ -102,103 +103,6 @@ static char usage_str[] =
>   * of the checkpoint image stream.
>   */
> 
> -#define BUFSIZE  (4 * 4096)
> -
> -static inline void ckpt_msg(int fd, char *format, ...)
> -{
> -	va_list ap;
> -	char *bufp;
> -	if (fd < 0)
> -		return;
> -
> -	va_start(ap, format);
> -
> -	bufp = malloc(BUFSIZE);
> -	if(bufp) {
> -		vsnprintf(bufp, BUFSIZE, format, ap);
> -		write(fd, bufp, strlen(bufp));
> -	}
> -	free(bufp);
> -
> -	va_end(ap);
> -}
> -
> -#define ckpt_perror(s) 							\
> -	do {								\
> -		ckpt_msg(global_uerrfd, s);				\
> -		ckpt_msg(global_uerrfd, ": %s\n", strerror(errno));	\
> -	} while (0)
> -
> -#ifdef CHECKPOINT_DEBUG
> -#define ckpt_dbg(_format, _args...)					\
> -	do {								\
> -		if (global_debug)					\
> -			ckpt_msg(global_uerrfd, "<%d>" _format, 	\
> -					_gettid(), ##_args); 		\
> -	} while (0)
> -#define ckpt_dbg_cont(_format, _args...)				\
> -	do {								\
> -		if (global_debug)					\
> -			ckpt_msg(global_uerrfd, _format, ##_args);	\
> -	} while (0)
> -#else
> -#define ckpt_dbg(_format, _args...)  \
> -	do { } while (0)
> -#define ckpt_dbg_cont(_format, _args...)  \
> -	do { } while (0)
> -#endif
> -
> -#define ckpt_err(...)  \
> -	ckpt_msg(global_uerrfd, __VA_ARGS__)
> -
> -#define ckpt_verbose(...)					\
> -	do {							\
> -		if (global_verbose)				\
> -			ckpt_msg(global_ulogfd, __VA_ARGS__);	\
> -	} while(0)
> -
> -struct signal_array {
> -	int signum;
> -	char *sigstr;
> -};
> -
> -#define SIGNAL_ENTRY(signal)  { SIG ## signal, #signal }
> -
> -#define INIT_SIGNAL_ARRAY { 	\
> -	{ 0, "NONE" },		\
> -	SIGNAL_ENTRY(ALRM),	\
> -	SIGNAL_ENTRY(HUP),	\
> -	SIGNAL_ENTRY(INT),	\
> -	SIGNAL_ENTRY(KILL),	\
> -	SIGNAL_ENTRY(PIPE),	\
> -	SIGNAL_ENTRY(POLL),	\
> -	SIGNAL_ENTRY(PROF),	\
> -	SIGNAL_ENTRY(TERM),	\
> -	SIGNAL_ENTRY(USR1),	\
> -	SIGNAL_ENTRY(USR2),	\
> -	SIGNAL_ENTRY(VTALRM),	\
> -	SIGNAL_ENTRY(STKFLT),	\
> -	SIGNAL_ENTRY(PWR),	\
> -	SIGNAL_ENTRY(WINCH),	\
> -	SIGNAL_ENTRY(CHLD),	\
> -	SIGNAL_ENTRY(URG),	\
> -	SIGNAL_ENTRY(TTIN),	\
> -	SIGNAL_ENTRY(TTOU),	\
> -	SIGNAL_ENTRY(STOP),	\
> -	SIGNAL_ENTRY(CONT),	\
> -	SIGNAL_ENTRY(ABRT),	\
> -	SIGNAL_ENTRY(FPE),	\
> -	SIGNAL_ENTRY(ILL),	\
> -	SIGNAL_ENTRY(QUIT),	\
> -	SIGNAL_ENTRY(SEGV),	\
> -	SIGNAL_ENTRY(TRAP),	\
> -	SIGNAL_ENTRY(SYS),	\
> -	SIGNAL_ENTRY(BUS),	\
> -	SIGNAL_ENTRY(XCPU),	\
> -	SIGNAL_ENTRY(XFSZ),	\
> -	{ -1, "LAST" },		\
> -}
> -
>  static struct signal_array signal_array[] = INIT_SIGNAL_ARRAY;
> 
>  static char *sig2str(int sig)
> @@ -399,18 +303,6 @@ struct app_restart_args {
>  	int keep_lsm;
>  };
> 
> -#define CKPT_COND_PIDZERO  0x1
> -#define CKPT_COND_MNTPROC  0x2
> -#define CKPT_COND_MNTPTY   0x4
> -
> -#define CKPT_COND_NONE     0
> -#define CKPT_COND_ANY      ULONG_MAX
> -
> -/* default for skip/warn/fail */
> -#define CKPT_COND_WARN     (CKPT_COND_MNTPROC | \
> -			    CKPT_COND_MNTPTY)
> -#define CKPT_COND_FAIL     (CKPT_COND_NONE)
> -
>  static void usage(char *str)
>  {
>  	ckpt_err("%s", str);
> -- 
> 1.6.0.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
