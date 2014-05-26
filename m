From: Vasily Kulikov <segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] /proc/pid/status: show all sets of pid according to ns
Date: Mon, 26 May 2014 22:04:43 +0400
Message-ID: <20140526180443.GA11145@cachalot>
References: <1401098728-2001-1-git-send-email-chenhanxiao@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1401098728-2001-1-git-send-email-chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Chen,

On Mon, May 26, 2014 at 18:05 +0800, Chen Hanxiao wrote:
> We need a direct method of getting the pid inside containers.
> If some issues occurred inside a container guest, host user
> could not know which process is in trouble just by guest pid:
> the users of container guest only knew the pid inside containers.
> This will bring obstacle for trouble shooting.
> 
> This patch expands fields of Tgid and Pid:
> a) In init_pid_ns, nothing changed;
> 
> b) In one pidns, they will tell the pid inside containers:
> Tgid:	1628 	9 	3
> Pid:	1628 	9 	3
> ** process id is 1628 in level 0, 9 in level 1, 3 in level 2.

1. It breaks ABI.  Any application which does something like "grep pid: | cut -d: -f2"
is now broken by the patch.  Maybe add a new field like 'Pid-ns', 'PidNS',
or 'Pids' and leave the old one for compatibility?

2. Is it OK to show internal pids to unprivileged processes?  I cannot
see anything obviously dangerous with it, though.

> c) If pidns is nested, it depends on which pidns are you in.
> Tgid:	9 	3
> Pid:	9 	3
> ** Views from level 1 for Pid 1628 in host.

-- 
Vasily
