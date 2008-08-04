From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH -mm 2/3] i/o controller infrastructure
Date: Mon, 04 Aug 2008 08:31:46 +0200
Message-ID: <4896A252.3000907__29682.6241341934$1217831650$gmane$org@gmail.com>
References: <> <1217801698-13438-3-git-send-email-righi.andrea@gmail.com>
	<489651E6.90001@cn.fujitsu.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <489651E6.90001-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> Andrea Righi wrote:
>> This is the core io-throttle kernel infrastructure. It creates the basic
>> interfaces to cgroups and implements the I/O measurement and throttling
>> functions.
>>
>> Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>  block/Makefile                |    2 ++
>>  include/linux/cgroup_subsys.h |    6 ++++++
>>  init/Kconfig                  |   10 ++++++++++
>>  3 files changed, 18 insertions(+), 0 deletions(-)
>>
> 
> where is block/blk-io-throttle.c and include/linux/blk-io-throttle.h?
> 

mmmh.. they should have been here, I mean, in patch 2/3 but it seems
they're gone in patch 1/3 (subject: i/o controller documentation):

Documentation of the block device I/O controller: description, usage,
advantages and design.

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 Documentation/controllers/io-throttle.txt |  312 +++++++++++++
 block/blk-io-throttle.c                   |  719 +++++++++++++++++++++++++++++
 include/linux/blk-io-throttle.h           |   41 ++
 3 files changed, 1072 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/controllers/io-throttle.txt
 create mode 100644 block/blk-io-throttle.c
 create mode 100644 include/linux/blk-io-throttle.h
...

I'm pretty sure I did a:
git-commit -s Documentation/controllers/io-throttle.txt
in my local branch (history confirms this), but, anyway, if you think
it's worth it I can fix it and post the patchset again, just let me
know.

Thanks for looking at it!
-Andrea
