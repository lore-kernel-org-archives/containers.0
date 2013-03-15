From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 0/4] fix depvpts in user namespaces
Date: Fri, 15 Mar 2013 13:13:39 +0400
Message-ID: <1363338823-25292-1-git-send-email-glommer@parallels.com>
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
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

devpts mounts in user namespaces is queued for 3.9. However, while playing
with it I found it to be less than ideal. Although it could possibly work
with custom software that can be made to point to /dev/pts/ptmx, a few things
prevent it from working correctly for people that, like us, are booting full
distributions.

In those scenarios, things like udev will kick in, maybe remount /dev undoing
any setup we might have done, and then software like sshd or anything else
calling openpty will search for /dev/ptmx, not /dev/pts/ptmx.

One of the problems that I am addressing in here is that we are disallowing
mknod in usernamespaces. Although I understand the motivation for that, I
believe that to be too restrictive, specially because we already control access
to the files separately. There should be no harm in mknod'ing something per se,
if manipulating it is forbidden.

That too, however, is too restrictive. Following the precedence that we set by
letting memcg manage the memory for tmpfs mounts, I am doing the same here with
the device cgroup. With the exception that instead of suggesting, here we have
a way to actually enforce it. Unless the mount was specifically marked as
nodev, reads and writes will be allowed to proceed if a device cgroup is
containing the process. The device cgroup will then be the one responsible for
setting fine grained access about which devices can and cannot be manipulated.

Last, /dev/ptmx will still always be the global ptmx device. We need to somehow
link it to our namespaces'. My proposal is to multiplex it and return the
correct "root ptmx" depending on which userns is reading that device.

Glauber Costa (4):
  dev_cgroup: keep track of which cgroup is the root cgroup
  fs: allow dev accesses in userns in controlled situations
  fs: allow mknod in user namespaces
  devpts: fix usage in user namespaces

 fs/devpts/inode.c        | 157 +++++++++++++++++++++++++++++++++++++++++++++--
 fs/namei.c               |   6 +-
 fs/namespace.c           |   2 +-
 include/linux/mount.h    |   2 +
 include/linux/security.h |   1 +
 security/device_cgroup.c |  15 ++++-
 6 files changed, 173 insertions(+), 10 deletions(-)

-- 
1.8.1.2
