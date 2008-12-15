From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [Bug 12199] /proc/1/exe entry of PID namespace init process links
	to wrong executable
Date: Sun, 14 Dec 2008 23:44:59 -0800
Message-ID: <m1r649anlw.fsf@frodo.ebiederm.org>
References: <20081212015652.1417810800F@picon.linux-foundation.org>
	<4946076D.7040707@exasol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4946076D.7040707-GD4dBWQXeU/QT0dZR+AlfA@public.gmane.org> (robert rex's message of "Mon, 15
	Dec 2008 08:29:49 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: robert.rex-GD4dBWQXeU/QT0dZR+AlfA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
List-Id: containers.vger.kernel.org

robert.rex-GD4dBWQXeU/QT0dZR+AlfA@public.gmane.org writes:

> Thanks for your analysis! That sounds reasonable (I didn't recognize the use of
> CLONE_NEWNS - just pasting from the examples ;-) - but I needed it to mount a
> proc filesystem in the new PID namespace while using the other one
> "outside"). So, I may not count on the /proc/{PID}/exe link anymore in such
> cases as far as I see.

Just setup the mount namespace instead of setting up a chroot and all will be well.

Eric
