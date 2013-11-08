From: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Subject: [Suggestion] kernel: cgroup: mount failure in LTP
	cgroup_regression_test.sh
Date: Fri, 08 Nov 2013 16:15:23 +0800
Message-ID: <527C9D9B.8090802@asianux.com>
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
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello Maintainers:

On Fedora16 with defconfig for next-20131107 kernel, use latest LTP
(Linux Test Project) version, test_5() in cgroup_regression_test.sh
will be fail. The related LTP output:

  <<<test_start>>>
  tag=cgroup stime=1383562810
  cmdline="       cgroup_regression_test.sh"
  contacts=""
  analysis=exit
  <<<test_output>>>
  cgroup_regression_test    1  TPASS  :  no kernel bug was found
  /opt/ltp/testcases/bin/cgroup_regression_test.sh: line 118: 13283 Terminated              ./fork_processes
  cgroup_regression_test    2  TPASS  :  notify_on_release is inherited
  cgroup_regression_test    3  TCONF  :  CONFIG_SCHED_DEBUG is not enabled
  cgroup_regression_test    4  TCONF  :  CONFIG_LOCKDEP is not enabled
  mount: xxx already mounted or cgroup/ busy
  cgroup_regression_test    5  TFAIL  :  mount freezer and cpuacct failed
  cgroup_regression_test    6  TCONF  :  CONFIG_CGROUP_NS
  /opt/ltp/testcases/bin/cgroup_regression_test.sh: line 360: 24428 Terminated              sleep 100 < cgroup/0
  /opt/ltp/testcases/bin/cgroup_regression_test.sh: line 381: 24447 Terminated              sleep 100 < cgroup/0
  cgroup_regression_test    7  TPASS  :  no kernel bug was found
  cgroup_regression_test    8  TPASS  :  no kernel bug was found
  cgroup_regression_test    9  TPASS  :  no kernel warning was found
  rmdir: failed to remove `cgroup/0': No such file or directory
  umount: /sys/fs/cgroup/systemd: device is busy.
          (In some cases useful info about processes that use
           the device is found by lsof(8) or fuser(1))
  cgroup_regression_test   10  TPASS  :  no kernel warning was found
  <<<execution_status>>>
  initiation_status="ok"
  duration=62 termination_type=exited termination_id=1 corefile=no
  cutime=3341 cstime=6353
  <<<test_end>>>

After simplify, the related operation, environments and output are:

  [root@gchenlinux tmp]# df -Th | grep cgroup
  tmpfs                             tmpfs    1001M     0 1001M   0% /sys/fs/cgroup
  [root@gchenlinux tmp]# lsof | grep cgroup | grep -v grep
  systemd       1          root    6r      DIR               0,18         0       5998 /sys/fs/cgroup/systemd/system
  [root@gchenlinux tmp]# cat /proc/cgroups 
  #subsys_name	hierarchy	num_cgroups	enabled
  cpuset	3	4	1
  cpu	4	35	1
  cpuacct	4	35	1
  freezer	5	4	1
  [root@gchenlinux tmp]# mkdir cgroup
  [root@gchenlinux tmp]# mount -t cgroup -o freezer,cpuacct xxx cgroup/
  mount: xxx already mounted or cgroup/ busy

Is it real issue of cgroup? If it is, I will/should continue analyzing.


Welcome any additional suggestions and completions.

Thanks.
--
Chen Gang
