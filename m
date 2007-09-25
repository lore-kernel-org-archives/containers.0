From: Badari Pulavarty <pbadari-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Unable to remove control groups on 2.6.23-rc8-mm1
Date: Tue, 25 Sep 2007 16:38:01 -0700
Message-ID: <1190763481.13955.52.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

I am playing with control groups on 2.6.23-rc8-mm1.

I am able to mount cgroup and create subgroups. I was able
to move some tasks into them. But, after killing tasks I am
not able to remove the subgroups. Any idea on why ?

Thanks,
Badari

elm3b155:/dev/cgroup # ls -l /dev/cgroup
total 175
drwxr-xr-x   4 root root      0 Sep 25 15:02 .
drwxr-xr-x  35 root root 179272 Sep 25 14:18 ..
-rw-r--r--   1 root root      0 Sep 25 14:22 cpuacct.load
-rw-r--r--   1 root root      0 Sep 25 14:22 cpuacct.usage
-rw-r--r--   1 root root      0 Sep 25 14:22 debug.cgroup_refcount
-rw-r--r--   1 root root      0 Sep 25 14:22 debug.current_css_set
-rw-r--r--   1 root root      0 Sep 25 14:22
debug.current_css_set_refcount
-rw-r--r--   1 root root      0 Sep 25 14:22 debug.taskcount
-rw-r--r--   1 root root      0 Sep 25 14:22 memory.control_type
-rw-r--r--   1 root root      0 Sep 25 14:22 memory.failcnt
-rw-r--r--   1 root root      0 Sep 25 14:22 memory.limit_in_bytes
-rw-r--r--   1 root root      0 Sep 25 14:22 memory.usage_in_bytes
-rw-r--r--   1 root root      0 Sep 25 14:22 notify_on_release
-rw-r--r--   1 root root      0 Sep 25 14:22 releasable
-rw-r--r--   1 root root      0 Sep 25 14:22 release_agent
-rw-r--r--   1 root root      0 Sep 25 14:22 tasks
drwxr-xr-x   2 root root      0 Sep 25 16:27 xxx
drwxr-xr-x   2 root root      0 Sep 25 14:22 yyy


elm3b155:/dev/cgroup # cat xxx/tasks
elm3b155:/dev/cgroup # cat yyy/tasks
elm3b155:/dev/cgroup #

elm3b155:/dev/cgroup # rmdir yyy
rmdir: `yyy': Device or resource busy
elm3b155:/dev/cgroup # rmdir xxx
rmdir: `xxx': Device or resource busy
elm3b155:/dev/cgroup #
