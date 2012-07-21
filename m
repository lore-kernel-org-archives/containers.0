From: Avinash Chiganmi <avinash.ca-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Cgroups: Cannot move certain kernel threads from root cgroup
Date: Sat, 21 Jul 2012 12:23:52 -0700
Message-ID: <CAGt76inhheRoxVKkDqdE4gxZVemKUmAL2GbUCbBSDJ5hmpHtzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

I created a "cpu" cgroup:
     mkdir /dev/cgroup
     mkdir /dev/cgroup/cpu
     mount -t cgroup -o cpu cpu /dev/cgroup/cpu
     cd /dev/cgroup/cpu/
     mkdir low

Now, I try to move tasks to the sub-cgroup "low":
     for task in `cat /dev/cgroup/cpu/tasks`; do   /bin/echo $task >
/dev/cgroup/cpu/low/tasks || echo "Failed to move PID $task"; done

/bin/echo: write error: Invalid argument
Failed to move PID 3
/bin/echo: write error: Invalid argument
Failed to move PID 4
/bin/echo: write error: Invalid argument
Failed to move PID 5
/bin/echo: write error: Invalid argument
Failed to move PID 6
/bin/echo: write error: Invalid argument
Failed to move PID 7
/bin/echo: write error: Invalid argument
Failed to move PID 8
/bin/echo: write error: Invalid argument
.
.
.
/bin/echo: write error: Invalid argument
Failed to move PID 58

I was able to move the "init" process itself. However, I failed to move
specific kernel threads:

root         3     2  0 18:16 ?        00:00:00 [migration/0]
root         4     2  0 18:16 ?        00:00:00 [sirq-high/0]
root         5     2  0 18:16 ?        00:00:04 [sirq-timer/0]
root         6     2  0 18:16 ?        00:00:00 [sirq-net-tx/0]
root         7     2  0 18:16 ?        00:00:00 [sirq-net-rx/0]
root         8     2  0 18:16 ?        00:00:00 [sirq-block/0]
root         9     2  0 18:16 ?        00:00:00 [sirq-block-iopo]
root        10     2  0 18:16 ?        00:00:00 [sirq-tasklet/0]
root        11     2  0 18:16 ?        00:00:00 [sirq-sched/0]
root        12     2  0 18:16 ?        00:00:00 [sirq-hrtimer/0]
root        13     2  0 18:16 ?        00:00:04 [sirq-rcu/0]
root        14     2  0 18:16 ?        00:00:00 [watchdog/0]
root        15     2  0 18:16 ?        00:00:00 [desched/0]
root        16     2  0 18:16 ?        00:00:00 [migration/1]
root        17     2  0 18:16 ?        00:00:00 [sirq-high/1]
root        18     2  0 18:16 ?        00:00:03 [sirq-timer/1]
root        19     2  0 18:16 ?        00:00:00 [sirq-net-tx/1]
root        20     2  0 18:16 ?        00:00:00 [sirq-net-rx/1]
root        21     2  0 18:16 ?        00:00:00 [sirq-block/1]


Is there something special about these threads that prevents them from
being moved to a different cgroup? Is there something I am missing?

Thanks!
Avi.
