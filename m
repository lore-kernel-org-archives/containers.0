From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: fanotify: the fscking all notification system
Date: Sat, 11 Jul 2009 12:18:16 -0700
Message-ID: <20090711191816.GA5222__14846.1331068122$1247339929$gmane$org@us.ibm.com>
References: <1246306125.754.300.camel@dhcp235-23.rdu.redhat.com>
	<20090701041039.GB23013@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090701041039.GB23013-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, malware-list-h+Im9A44IAFcMpApZELgcQ@public.gmane.org
List-Id: containers.vger.kernel.org

| > struct fanotify_event_metadata {
| >         __u32 event_len;
| >         __s32 fd;
| >         __u32 mask;
| >         __u32 f_flags;
| >         pid_t pid;
| >         pid_t tgid;
| >         __u64 cookie;
| > }  __attribute__((packed));
| 
| Since it passes pids from the kernel to userspace via a socket I suspect
| this needs input from the folks working on pid namespaces. The events may
| need to be dropped if the pid namespace of the event's origin doesn't
| match that of the destination. Otherwise the pid would be ambiguous and
| this interface will only work for tasks in the initial pid namespace.

If we do have the destination pid namespace, we could translate the pid
of the process modifying the file, into the pid namespace of the process
receiving the notification, like we do in mq_notify().

So when a process in an ancestor or unrelated pid namespace modifies the
file, the si_pid would get set to 0. 

Sukadev
