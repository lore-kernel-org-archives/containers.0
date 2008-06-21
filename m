From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] introduce task cgroup v2
Date: Sat, 21 Jun 2008 08:48:07 -0700
Message-ID: <6599ad830806210848q1a1538bcw79c2f3217dd49303@mail.gmail.com>
References: <6599ad830806210056n44c7ff37g7cd643f95aef4aa0@mail.gmail.com>
	 <485CC255.9010504@linux.vnet.ibm.com>
	 <20080621180530.E82D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754457AbYFUPts@vger.kernel.org>
In-Reply-To: <20080621180530.E82D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Pavel Emelianov <xemul@openvz.org>, containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Sat, Jun 21, 2008 at 2:10 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>
> I am going to convert spinlock in task limit cgroup to atomic_t.
> task limit cgroup has following caractatics.
>        - many write (fork, exit)
>        - few read
>        - fork() is performance sensitive systemcall.

This is true, but I don't see how it can be more performance-sensitive
than the overhead of allocating/freeing a page.

What kinds of performance regressions did you see?

>          if increase fork overhead, system total performance cause degression.

What kind of overhead were you seeing? How about if you delay doing
any task accounting until the task_limit subsystem is bound to a
hierarchy? That way there's no noticeable overhead for people who
aren't using your subsystem.

Paul
