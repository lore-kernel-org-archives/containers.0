From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH 0/3] procfs wrt pid namespace cleanups
Date: Mon, 14 Feb 2011 20:16:00 +0100
Message-ID: <1297710963-19843-1-git-send-email-daniel.lezcano__22740.8306826421$1297711191$gmane$org@free.fr>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

This patchset is a cleanup and a preparation to unshare the pid
namespace. These prerequisite prepare the next Eric's patchset
to give a file descriptor to a namespace and join an existing
namespace.

The initial authors of this patchset are Eric Biederman and Oleg
Nesterov.

Changelog:

        02/14/11 - daniel.lezcano-GANU6spQydw@public.gmane.org
        * patch 2/3 : fix return ENOMEM and put_pid_ns on error
        * removed buggy patch #4 from the initial patchset

        01/31/11 - daniel.lezcano-GANU6spQydw@public.gmane.org:
        * patch 1/4 : wrapped test in a function
        * patch 2/4 : handle proc_pid_ns_prepare_proc error
        * patch 2/4 : put parent pid_ns on error
        * other patches : refreshed against linux-next
