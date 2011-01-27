From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH] cgroup : remove the ns_cgroup
Date: Thu, 27 Jan 2011 09:50:38 +0100
Message-ID: <4D4131DE.3080309__7889.25794554434$1296118394$gmane$org@free.fr>
References: <1295948388-15108-1-git-send-email-daniel.lezcano@free.fr>	<20110126161837.43830756.akpm@linux-foundation.org>	<4D40C5A3.4070703@cn.fujitsu.com>
	<20110126174513.c2a20fff.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110126174513.c2a20fff.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 01/27/2011 02:45 AM, Andrew Morton wrote:
> On Thu, 27 Jan 2011 09:08:51 +0800 Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>  wrote:
>
>> Andrew Morton wrote:
>>> On Tue, 25 Jan 2011 10:39:48 +0100
>>> Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org>  wrote:
>>>
>>>> This patch removes the ns_cgroup as suggested in the following thread:
>>> I had this patch queued up in September last year, but dropped it.  Why
>>> did I do that?
>> Because you wanted to wait for some time for users (if any) to notice this
>> coming change.
>>
>> Author: Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org>
>> Date:   Wed Oct 27 15:33:38 2010 -0700
>>
>>      cgroup: notify ns_cgroup deprecated
>>
>>      The ns_cgroup will be removed very soon.  Let's warn, for this version,
>>      ns_cgroup is deprecated.
>>
>>      Make ns_cgroup and clone_children exclusive.  If the clone_children is set
>>      and the ns_cgroup is mounted, let's fail with EINVAL when the ns_cgroup
>>      subsys is created (a printk will help the user to understand why the
>>      creation fails).
>>
>>      Update the feature remove schedule file with the deprecated ns_cgroup.
>>
>>      Signed-off-by: Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org>
>>      Acked-by: Paul Menage<menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>      Signed-off-by: Andrew Morton<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
>>      Signed-off-by: Linus Torvalds<torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> ooh, that was clever of me.
>
> Here is the text which was missing from the changelog:
>
>    This is a userspace-visible change.  Commit 45531757b45c ("cgroup:
>    notify ns_cgroup deprecated") (merged into 2.6.27) caused the kernel
>    to emit a printk warning users that the feature is planned for
>    removal.  Since that time we have heard from XXX users who were
>    affected by this.
>
> Please provide XXX.

Ok, AFAIK nobody makes use of the ns_cgroup except the LXC userspace 
tools which I maintain and where
the backward compatibility with the ns_cgroup and the clone_children 
flag is already implemented.
Since today nobody seems to be affected by this.

I Cc'ed the libvirt mailing list.

> How do we know that 2.6.37->2.6.38 is long enough?  Will any major
> distros be released containing this warning in that timeframe?  I doubt
> it.

Hmm, maybe it is too short but I don't think someone will complain about 
this feature removal.
Google chromium is using the namespaces, hence a lot of cgroup is 
created on the system. The vsftpd and some pam modules uses the 
namespaces too.
I won't be surprised if one of these applications fails with 'clone' 
returning EEXIST ...
