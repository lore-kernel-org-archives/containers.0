From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [C/R][PATCH] Use __WALL option in waitpid()
Date: Sat, 27 Jun 2009 22:17:08 -0700
Message-ID: <20090628051707.GA21192@us.ibm.com>
References: <20090627192704.GA14326@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090627192704.GA14326-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren,

(Following up on the discussion from IRC)

I had run my application as:

	ns_exec -cpuimP pid.ptree1 -- ./ptree1 -n 2 -d 1 -w sleep

ns_exec creates the application in new container, with p->exit_signal 0.
for the container-init. When we checkpoint the process tree, we
correctly save and restore the exit_signal to 0. Because of that,
we need the coordinator to use __WALL.

Sukadev

Sukadev Bhattiprolu [sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| 
| The coordinator creates the children with clone(), so pass the __WALL
| option to waitpid(). Otherwise the waitpid() will fail, and bring the
| container down even as the application is restarting successfully :-)
| 
| Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
| 
| ---
|  mktree.c |    2 +-
|  1 file changed, 1 insertion(+), 1 deletion(-)
| 
| Index: user-cr/mktree.c
| ===================================================================
| --- user-cr.orig/mktree.c	2009-06-27 12:16:42.000000000 -0700
| +++ user-cr/mktree.c	2009-06-27 12:17:02.000000000 -0700
| @@ -523,7 +523,7 @@ static int ckpt_collect_child(pid_t pid,
|  {
|  	int status;
| 
| -	pid = waitpid(pid, &status, 0);
| +	pid = waitpid(pid, &status, __WALL);
|  	if (pid < 0) {
|  		perror("WEIRD: collect child task");
|  		exit(1);
| _______________________________________________
| Containers mailing list
| Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
| https://lists.linux-foundation.org/mailman/listinfo/containers
