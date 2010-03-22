From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/5][lxc] Hook up lxc_checkpoint() with app_checkpoint()
Date: Mon, 22 Mar 2010 15:44:50 +0100
Message-ID: <4BA78262.6050109@fr.ibm.com>
References: <20100319063912.GA25732@us.ibm.com>
	<20100319064141.GF25732@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100319064141.GF25732-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu wrote:
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Thu, 11 Mar 2010 21:32:38 -0800
> Subject: [PATCH 5/5][lxc] Hook up lxc_checkpoint() with app_checkpoint()
> 
> Have lxc_checkpoint() call app_checkpoint() implemented in checkpoint.o
> in the USER-CR git tree
> 
> TODO:
> 	- Map lxc_flags to flags in sys_checkpoint()
> 	- Initialize app_checkpoint_args.debug and other fields based on
> 	  command line options to lxc_checkpoint rather than hard-coding
> 	  them
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  src/lxc/checkpoint.c |   91 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  src/lxc/commands.c   |    3 ++
>  src/lxc/commands.h   |    1 +
>  src/lxc/state.c      |   26 ++++++++++++++
>  4 files changed, 120 insertions(+), 1 deletions(-)
> 
> diff --git a/src/lxc/checkpoint.c b/src/lxc/checkpoint.c
> index 7e8a93e..0fbabc8 100644
> --- a/src/lxc/checkpoint.c
> +++ b/src/lxc/checkpoint.c
> @@ -22,10 +22,99 @@
>   */
>  #include <lxc/lxc.h>
>  #include <lxc/log.h>
> +#include <sys/stat.h>
> +#include <fcntl.h>
> +#include <errno.h>
> +#include <linux/checkpoint.h>
> +
> +#include "commands.h"
> +#include "arguments.h"
> +#include "app-checkpoint.h"
> 
>  lxc_log_define(lxc_checkpoint, lxc);
> 
> -int lxc_checkpoint(const char *name, const char *statefile, int flags)
> +find_cinit_pid(const char *name)
>  {
> +	struct lxc_command command = {
> +		.request = { .type = LXC_COMMAND_CINIT_PID },
> +	};
> +
> +	int ret, stopped;
> +
> +	ret = lxc_command(name, &command, &stopped);
> +	if (ret < 0) {
> +		ERROR("failed to send command");
> +		return -1;
> +	}
> +
> +	ERROR("find_cinit_pid %d\n", command.answer.ret);
> +
> +	return command.answer.ret;
> +}

I just committed the same function for the lxc_attach command. I think 
you can reuse it.

> +int lxc_checkpoint(const char *name, const char *statefile, int lxc_flags)
> +{
> +	int ret;
> +	int pid;
> +	int flags;
> +	struct stat statbuf;
> +	struct app_checkpoint_args crargs;
> +
> +	if (access(statefile, F_OK) == 0) {
> +		ret = stat(statefile, &statbuf);
> +		if (ret < 0) {
> +			ERROR("stat(%s): %s\n", statefile, strerror(errno));
> +			return -1;
> +		}
> +
> +		if (S_ISDIR(statbuf.st_mode)) {
> +			ERROR("--directory option not implemented");
> +			return -1;
> +		} else {
> +			ERROR("Checkpoint image file %s exists\n", statefile);
> +			return -1;
> +		}
> +	}

For the checkpoint, you don't need to check if it's a directory or a 
file (but it should be done at restart time). I am not sure 'access' is 
really necessary because the O_EXCL is set in the open below.

> +
> +	pid = find_cinit_pid(name);
> +	if (pid < 0) {
> +		ERROR("Unable to find cinit pid");
> +		return -1;
> +	}
> +
> +	memset(&crargs, 0, sizeof(crargs));
> +
> +	ret = open(statefile, O_CREAT|O_RDWR|O_EXCL, 0644);
> +	if (ret < 0) {
> +		ERROR("open(%s) failed\n", statefile);
> +		return -1;
> +	}

As the statefile may contain sensible data, it would be preferable to 
set it 0600, no ?

> +	crargs.outfd = ret;
> +	crargs.logfd = lxc_log_fd;
> +	crargs.uerrfd = lxc_log_fd;
> +	/*
> +	 * TODO: Set this to 0 for now - otherwise we get an objhash leak
> +	 * 	 due to mismatched references to current PTY which needs to
> +	 * 	 be investigated.
> +	 *
> +	 * TODO: Map @lxc_flags to user-cr flags ?
> +	 *
> +	 * TODO: We can probably drop the ->container field since @flags
> +	 * 	 can provide the same selection. 
> +	 *
> +	 * TODO: Do we may need a --container option to lxc_checkpoint or
> +	 * 	 assume that we always work with full containers ?
> +	 */
> +	crargs.container = 0;
> +
> +	flags = CHECKPOINT_SUBTREE;
> +
> +	ret = app_checkpoint(pid, flags, &crargs);
> +	if (ret < 0) {
> +		ERROR("checkpoint of %s (pid %d) failed\n", name);
> +		return -1;
> +	}
> +
>  	return 0;
>  }
