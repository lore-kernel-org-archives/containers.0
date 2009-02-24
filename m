From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: Question for remount
Date: Tue, 24 Feb 2009 10:47:51 +0900
Message-ID: <20090224104751.4767a3a1.kamezawa.hiroyu__27133.2915676341$1235440555$gmane$org@jp.fujitsu.com>
References: <20090220190223.e8b4f6a8.kamezawa.hiroyu@jp.fujitsu.com>
	<49A20976.2050301@cn.fujitsu.com> <49A21044.40402@cn.fujitsu.com>
	<20090224103659.069e6b33.kamezawa.hiroyu@jp.fujitsu.com>
	<49A35048.3000304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49A35048.3000304-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 24 Feb 2009 09:41:28 +0800
Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:

> >>  To change the set of subsystems bound to a mounted hierarchy, just
> >>  remount with different options:
> >> +# mount -o remount,cpuset,ns hier1 /dev/cgroup
> >>  
> >> -# mount -o remount,cpuset,ns  /dev/cgroup
> >> +Now numtasks is removed from the hierarchy and ns is added.
> >> +
> >> +Note this will add ns to the hierarchy but won't remove numtasks or
> >> +cpuset:
> >> +# mount -o remount,ns /dev/cgroup
> >>  
> > 
> > Just a question. What is "numtasks" here ? We have numtasks cgroup ?
> > 
> 
> No, I guess that's a proposed but not implemented cgroup subsystem. :)
> And I can change it to an existing one.
> 
O.K. thanks.

BTW, how about writing this kind of text in explicit way ?
+Note: this will add ns to the hierarchy but won't remove numtasks or
+cpuset because new options is appended to old options. If you want to
+override, please use.....

-Kame
