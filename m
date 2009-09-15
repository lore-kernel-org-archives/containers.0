From: Sergey Kononenko <sergk-Xso+ZjpL9WJWk0Htik3J/w@public.gmane.org>
Subject: Restriction of filesystem mounting
Date: Tue, 15 Sep 2009 23:35:27 +0300
Message-ID: <20090915233527.3c0129ed@vingilot.sergknet>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

I've come across the need to restrict ability of mounting filesystems
inside container and probably forbid remounting of already mounted
filesystems in container namespace (mounted by lxc-start for example).
It semms that the obvious solution is to drop capability from bounding
set of processes inside container. Unfortunately there is no separate
capability for mount/umount and dropping of CAP_SYS_ADMIN is
unacceptable in my case.
I don't see a way to solve this problem without modifying kernel code,
though I don't know how exactly to modify it. My first thought was to
create new separate capability CAP_SYS_MOUNT, although it may break
existing applications which presume CAP_SYS_ADMIN would be enough to do
mount/umount. Another option to solve this problem would be to create
cgroup controller with list of permitted filesystem types similar to
existing controller for devices (CGROUP_DEVICE).
Any suggestions will be helpful.

With best reagrds,
Sergey Kononenko.
