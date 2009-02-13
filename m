From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [cgroup or VFS ?] WARNING: at fs/namespace.c:636
	mntput_no_expire+0xac/0xf2()
Date: Fri, 13 Feb 2009 05:47:51 +0000
Message-ID: <20090213054751.GI28946@ZenIV.linux.org.uk>
References: <49617D35.4040805@cn.fujitsu.com>
	<20090209004046.3ce1dde0.akpm@linux-foundation.org>
	<20090209093414.GU28946@ZenIV.linux.org.uk>
	<499013CC.2060808@cn.fujitsu.com> <4993BD5D.2020707@cn.fujitsu.com>
	<20090212062442.GE28946@ZenIV.linux.org.uk>
	<4993C2A0.3050507@cn.fujitsu.com> <4993C7C2.4060100@cn.fujitsu.com>
	<20090212070729.GF28946@ZenIV.linux.org.uk>
	<4995007D.7040101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4995007D.7040101-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Feb 13, 2009 at 01:09:17PM +0800, Li Zefan wrote:

> I ran following testcase, and triggered the warning in 1 hour:
> 
> thread 1:
> for ((; ;))
> {
>         mount --bind /cgroup /mnt > /dev/null 2>&1
>         umount /mnt > /dev/null 2>&1
> }
> 
> tread 2:
> for ((; ;))
> {
>         mount -t cgroup -o cpu xxx /cgroup > /dev/null 2>&1
>         mkdir /cgroup/0 > /dev/null 2>&1
>         rmdir /cgroup/0 > /dev/null 2>&1
>         umount -l /cgroup > /dev/null 2>&1
> }

Wow.  You know, at that point these redirects could probably be removed.
If anything in there ends up producing an output, we very much want to
see that.  Actually, I'd even make that
	mount --bind /cgroup/mnt || (echo mount1: ; date)
etc., so we'd see when do they fail and which one fails (if any)...
 
Which umount has failed in the above, BTW?
