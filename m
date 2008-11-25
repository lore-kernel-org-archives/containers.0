From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 0/2] In-kernel process restart
Date: Tue, 25 Nov 2008 15:02:37 -0500
Message-ID: <492C59DD.5070401__32912.7060286284$1227643501$gmane$org@cs.columbia.edu>
References: <1227541175-30301-1-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227541175-30301-1-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Andrey Mirkin wrote:
> These patchset introduces OpenVZ kernel based restart procedure on top of
> Oren's checkpoint/restart patchset v9.
> 
> For restarting a set of processes one will need to call sys_restart() once with
> new flag CR_CTX_RSTR_IN_KERNEL. All work will be done in kernel in this case.
> 
> Small changes to image format are required to make in-kernel process creation
> more easy.
> 
> Oren, please take a look on this patchset. I've tried to port OpenVZ
> functionality on top of yours with minimal changes.
> 

Thanks, Andrey. The patch looks simple and good.

Did you look at my (user-space) process creation code ?  specifically, it
uses the task-pids array (that is saved during checkpoint) to figure out
how many children a task has to spawn and their corresponding pids.

Is there a particular reason that you chose not to use that data during
restart ?  eventually, you'll need to add the rest of it, too, to the task
data, like you did with the number of children in this patch.

Instead, since the data is available and the logic is available, we can
have each new thread call do_restart_task(), and the container init
should call do_restart_root().

What do you think ?  I can go ahead and make the changes on top of your
patch.

Oren.
