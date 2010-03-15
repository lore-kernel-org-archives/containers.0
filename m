From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 00/13][user-cr]: Cleanups checkpoint.c, restart.c
Date: Sun, 14 Mar 2010 23:49:33 -0400
Message-ID: <4B9DAE4D.5040307@cs.columbia.edu>
References: <20100304074354.GA29320@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100304074354.GA29320-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Series applied (will push shortly).

Oren.

Sukadev Bhattiprolu wrote:
> [PATCH 00/13][user-cr]: Cleanups checkpoint.c, restart.c
> 
> These patches perform some cleanups/reorg of the code in checkpoint.c and
> restart.c files.  These changes remove redundant fields in data structures,
> rename some fields/functions and avoid directly using stdout/stderr.
> 
> The changes will help us later export app_checkpoint() and app_restart()
> to larger container implementations such as LXC.
> 
> 	[PATCH 01/13][user-cr]: restart: Remove args->no_pidns.
> 	[PATCH 02/13][user-cr]: restart: Rename args->logfd
> 	[PATCH 03/13][user-cr]: restart: Remove args->logfile 
> 	[PATCH 04/13][user-cr]: restart: Use ckpt_msg() to log
> 	[PATCH 05/13][user-cr]: restart: Use ckpt_perror()
> 	[PATCH 06/13][user-cr]: restart: Remove args->input
> 	[PATCH 07/13][user-cr]: Define app_restart()
> 	[PATCH 08/13][user-cr]: restart: Rename struct args.
> 	[PATCH 09/13][user-cr]: checkpoint: Remove args->output
> 	[PATCH 10/13][user-cr]: checkpoint: Remove ->logfile
> 	[PATCH 11/13][user-cr]: checkpoint: Rename struct args
> 	[PATCH 12/13][user-cr]: Define app_checkpoint()
> 	[PATCH 13/13] checkpoint: Use ckpt_perror()
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
