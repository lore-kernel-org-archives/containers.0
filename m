From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroups: handle failure of cgroup_populate_dir()
	at	mount/remount
Date: Mon, 25 May 2009 17:14:58 +0800
Message-ID: <4A1A6192.6050608__1014.39102222702$1243243044$gmane$org@cn.fujitsu.com>
References: <4A16153C.2080004@cn.fujitsu.com>
	<20090522172545.1e5e5f81.kamezawa.hiroyu@jp.fujitsu.com>
	<4A1663C2.4080401@cn.fujitsu.com>
	<20090522173421.ecacb40e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090522091034.GC8696@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090522091034.GC8696-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Dhaval Giani wrote:
> On Fri, May 22, 2009 at 05:34:21PM +0900, KAMEZAWA Hiroyuki wrote:
>> On Fri, 22 May 2009 16:35:14 +0800
>> Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>
>>> KAMEZAWA Hiroyuki wrote:
>>>> On Fri, 22 May 2009 11:00:12 +0800
>>>> Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>>>
>>>>> Now we have 'stat' file in both memory and cpuacct subsystems. If we
>>>>> mount these 2 subsystems with option 'noprefix', the creation of 'stat'
>>>>> file for cpuacct will fail, but without any notificatin to the user.
>>>>>
>>>>> With this patch, we fail the mount/remount in this case.
>>>>>
>>>> Hm, shouldn't we allow "noprefix" to be effective only agaisnt cpuset ?
>>>> I think it's just for backward-compatibility of cpuset.
>>>> (I don't like the option at all.)
>>>>
>>> Yes, this mount option was introduced for cpuset. But it has been here for
>>> a long time and people may use it when mounting other cgroup subsystems,
>>> then is it OK to change to restrict its use within cpuset only?
>> Asking libcgroup people may be appropriate...added CC.
> 
> We just realized that we were not handling the noprefix usage in

I guess handling noprefix will increase complexity of libcgroup? since we
can't figure out which subsystem the file belongs to by looking at the
prefix of the file.

> libcgroup. From the pov of the library, the option should either not
> exist for any subsystem or for all of them. Anything else would mean
> having to add special cases.
> 

I don't see how to totally remove 'noprefix' while keep the backward 
compatibility of cpuset, so I think we have to reserve it, and fix
name collision caused by this option.
