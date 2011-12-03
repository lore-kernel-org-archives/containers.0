From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH 0/1][V2] Handle reboot in a child pid namespace
Date: Sun,  4 Dec 2011 00:51:19 +0100
Message-ID: <1322956280-13831-1-git-send-email-daniel.lezcano@free.fr>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

ChangeLog:

 * V2
   - added a lock for the pid namespace to prevent racy call
     to the 'reboot' syscall
   - Moved 'reboot' command assigned in zap_pid_ns_processes
     instead of wait_task_zombie
   - added tasklist lock around force_sig
   - added do_exit in pid_ns_reboot
   - used task_active_pid_ns instead of declaring a new variable in sys_reboot
   - moved code up before POWER_OFF changed to HALT in sys_reboot

Daniel Lezcano (1):
  Add reboot_pid_ns to handle the reboot syscall

 include/linux/pid_namespace.h |    9 ++++++-
 kernel/pid_namespace.c        |   54 +++++++++++++++++++++++++++++++++++++++++
 kernel/sys.c                  |    3 ++
 3 files changed, 65 insertions(+), 1 deletions(-)

-- 
1.7.5.4
