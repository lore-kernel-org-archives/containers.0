From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 00/10] cgroups: Task counter subsystem v8
Date: Wed,  1 Feb 2012 04:37:40 +0100
Message-ID: <1328067470-5980-1-git-send-email-fweisbec@gmail.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

Changes In this version:

- Split 32/64 bits version of res_counter_write_u64() [1/10]
  Courtesy of Kirill A. Shutemov

- Added Kirill's ack [8/10]

- Added selftests [9/10], [10/10]

Please consider for merging. At least two users want this feature:
https://lkml.org/lkml/2011/12/13/309
https://lkml.org/lkml/2011/12/13/364

More general details provided in the last version posting:
https://lkml.org/lkml/2012/1/13/230

Thanks!


Frederic Weisbecker (9):
  cgroups: add res_counter_write_u64() API
  cgroups: new resource counter inheritance API
  cgroups: ability to stop res charge propagation on bounded ancestor
  res_counter: allow charge failure pointer to be null
  cgroups: pull up res counter charge failure interpretation to caller
  cgroups: allow subsystems to cancel a fork
  cgroups: Add a task counter subsystem
  selftests: Enter each directories before executing selftests
  selftests: Add a new task counter selftest

Kirill A. Shutemov (1):
  cgroups: add res counter common ancestor searching

 Documentation/cgroups/resource_counter.txt         |   20 ++-
 Documentation/cgroups/task_counter.txt             |  153 +++++++++++
 include/linux/cgroup.h                             |   20 +-
 include/linux/cgroup_subsys.h                      |    5 +
 include/linux/res_counter.h                        |   27 ++-
 init/Kconfig                                       |    9 +
 kernel/Makefile                                    |    1 +
 kernel/cgroup.c                                    |   23 ++-
 kernel/cgroup_freezer.c                            |    6 +-
 kernel/cgroup_task_counter.c                       |  272 ++++++++++++++++++++
 kernel/exit.c                                      |    2 +-
 kernel/fork.c                                      |    7 +-
 kernel/res_counter.c                               |  103 +++++++-
 tools/testing/selftests/Makefile                   |    2 +-
 tools/testing/selftests/run_tests                  |    6 +-
 tools/testing/selftests/task_counter/Makefile      |    8 +
 tools/testing/selftests/task_counter/fork.c        |   40 +++
 tools/testing/selftests/task_counter/forkbomb.c    |   40 +++
 tools/testing/selftests/task_counter/multithread.c |   68 +++++
 tools/testing/selftests/task_counter/run_test      |  198 ++++++++++++++
 .../selftests/task_counter/spread_thread_group.c   |   82 ++++++
 21 files changed, 1056 insertions(+), 36 deletions(-)
 create mode 100644 Documentation/cgroups/task_counter.txt
 create mode 100644 kernel/cgroup_task_counter.c
 create mode 100644 tools/testing/selftests/task_counter/Makefile
 create mode 100644 tools/testing/selftests/task_counter/fork.c
 create mode 100644 tools/testing/selftests/task_counter/forkbomb.c
 create mode 100644 tools/testing/selftests/task_counter/multithread.c
 create mode 100755 tools/testing/selftests/task_counter/run_test
 create mode 100644 tools/testing/selftests/task_counter/spread_thread_group.c

-- 
1.7.5.4
