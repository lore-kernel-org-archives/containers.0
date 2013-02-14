From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] kernel: allow reboots from user_ns
Date: Thu, 14 Feb 2013 06:58:12 -0800
Message-ID: <87wqubc58b.fsf@xmission.com>
References: <1360843000-31228-1-git-send-email-glommer@parallels.com>
	<20130214142745.GA4470@sergelap> <511CF51C.6050504@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <511CF51C.6050504-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> (Glauber Costa's message of
	"Thu, 14 Feb 2013 18:30:52 +0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:

> On 02/14/2013 06:27 PM, Serge Hallyn wrote:
>> Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
>>> Reboot support for pid namespaces is already implemented and it works
>>> well. However, in most containers the tasks will join all namespaces,
>>> including the now supported user namespace. In that situation, we will
>>> fail the "capable" test and won't be able to reboot.
>>>
>>> The proposed solution is to allow reboots for CAP_SYS_BOOT processes
>>> in the user namespace that owns the pid namespace.
>>>
>>> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>> 
>> Note Li Zefan sent this identical patch last year.  It's in my own
>> built userns kernel, and definately required :)
>> 
> I didn't see that, and using Linus' master my stop container scripts
> stopped working after I started using Eric's userns...

The patch has been sitting in my for-next branch for quite a while
just waiting for the merge window.

Eric

commit 923c7538236564c46ee80c253a416705321f13e3
Author: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Date:   Thu Dec 27 11:39:12 2012 +0800

    userns: Allow unprivileged reboot
    
    In a container with its own pid namespace and user namespace, rebooting
    the system won't reboot the host, but terminate all the processes in
    it and thus have the container shutdown, so it's safe.
    
    Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

diff --git a/kernel/sys.c b/kernel/sys.c
index 265b376..24d1ef5 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -433,11 +433,12 @@ static DEFINE_MUTEX(reboot_mutex);
 SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
                void __user *, arg)
 {
+       struct pid_namespace *pid_ns = task_active_pid_ns(current);
        char buffer[256];
        int ret = 0;
 
        /* We only trust the superuser with rebooting the system. */
-       if (!capable(CAP_SYS_BOOT))
+       if (!ns_capable(pid_ns->user_ns, CAP_SYS_BOOT))
                return -EPERM;
 
        /* For safety, we require "magic" arguments. */
@@ -453,7 +454,7 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
         * pid_namespace, the command is handled by reboot_pid_ns() which will
         * call do_exit().
         */
-       ret = reboot_pid_ns(task_active_pid_ns(current), cmd);
+       ret = reboot_pid_ns(pid_ns, cmd);
        if (ret)
                return ret;
