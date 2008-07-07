From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/4] Container Freezer: Reuse Suspend Freezer
Date: Mon, 07 Jul 2008 16:02:24 -0700
Message-ID: <1215471744.9023.14.camel__6171.75595039061$1215471888$gmane$org@localhost.localdomain>
References: <20080707225823.502032693@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080707225823.502032693-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


On Mon, 2008-07-07 at 15:58 -0700, Matt Helsley wrote:
> This patchset reuses the container infrastructure and the swsusp freezer to
> freeze a group of tasks.
> 
> The freezer subsystem in the container filesystem defines a file named
> freezer.state. Writing "FROZEN" to the state file will freeze all tasks in the
> cgroup. Subsequently writing "RUNNING" will unfreeze the tasks in the cgroup. 
> Reading will return the current state. 
> 
> * Examples of usage :
> 
>    # mkdir /containers/freezer
>    # mount -t cgroup -ofreezer,signal freezer  /containers
>    # mkdir /containers/0
>    # echo $some_pid > /containers/0/tasks
> 
> to get status of the freezer subsystem :
> 
>    # cat /containers/0/freezer.state
>    RUNNING
> 
> to freeze all tasks in the container :
> 
>    # echo FROZEN > /containers/0/freezer.state
>    # cat /containers/0/freezer.state
>    FREEZING
>    # cat /containers/0/freezer.state
>    FROZEN
> 
> to unfreeze all tasks in the container :
> 
>    # echo RUNNING > /containers/0/freezer.state
>    # cat /containers/0/freezer.state
>    RUNNING
> 
> to kill all tasks in the container :
> 
>    # echo 9 > /containers/0/signal.kill
> 
> I've reworked Cedric's patches to use task_lock() to protect access to the
> task's cgroup.
> 
> Paul, Pavel asked me to send these to Rafael next. They are patches to make
> the freezer useful for checkpoint/restart using cgroups so it would be nice
> to get an explicit [N]Ack from you first.
> 
> Rafael, if Paul agrees, please consider applying these patches.
> 
> Changes since v3:
> v4 (Almost all of these changes are confined to patch 3):
> 	Reworked the series to use task_lock() instead of RCU.
> 	Reworked the series to use write_string() and read_seq_string()
> 		cgroup methods.

	FYI - This means these patches need Paul's patches introducing
write_string(). I can certainly restore the old code for .read
and .write, but I was anticipating write_string() making it into various
trees first. If that's not necessarily the case please let me know.

Cheers,
	-Matt
