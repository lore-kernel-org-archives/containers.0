From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Question for remount
Date: Fri, 20 Feb 2009 19:02:23 +0900
Message-ID: <20090220190223.e8b4f6a8.kamezawa.hiroyu__7366.10296085036$1235124479$gmane$org@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
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
To: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Followings are 3 stories of remount cgroup,

1. remount with devices.

 # mount -t cgroup none /cgroups -ocpuacct,release_agent=xxx
 # echo > /cgroups/release_agent #clear release agent by hand
 # mount -t cgroup none /cgroups -oremount,cpuacct
 # cat /cgroups/release_agent
   => release_agent is ""

2. remount without devices, mount command will read /proc/mounts and
   copies option.

 # mount -t cgroup none /cgroups -ocpuacct,release_agent=xxx
 # echo > /cgroups/release_agent      #clear release agent by hand
 # mount /cgroups -oremount,cpuacct   #don't specify device
 # cat /cgroups/release_agent
   => xxx

Hmm, release_agent is copied from /proc/mounts and release_agent revives.

3. remount without devices, mount command will read /proc/mounts
 # mount -t cgroup none /cgroups -ocpuacct,release_agent=xxx
 # mount /cgroups -oremount,cpuacct,release_agent=xxx
 => error
 "release_agent=" will be found twice and this returns -INVAL

maybe case "2" is not ideal, I think. (but it may not be bug.)

My point is following.

1. Documentation/cgroups/cgroup.txt says
   #mount -oremount,cpuset,ns /dev/cgroup
   But this should be
   #mount -tcgroup none /dev/cgroup -oremount,cpuset,ns

2. /proc/mounts information of release_agent should be updated....
   when it's overwritten directly.

3. If "2" is impossible, changing release_agent at remount should not be allowed.

How do you think ?

Thanks,
-Kame
