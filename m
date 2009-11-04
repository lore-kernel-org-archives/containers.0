From: Jan Safranek <jsafrane-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] Mount point suggestions for cgroup
Date: Wed, 04 Nov 2009 17:24:46 +0100
Message-ID: <4AF1AACE.6060705__48628.3191050918$1257351991$gmane$org@redhat.com>
References: <20091104063005.GC3560@balbir.in.ibm.com>
	<20091104154024.0b8f6123.kamezawa.hiroyu@jp.fujitsu.com>
	<20091104081618.GD3560@balbir.in.ibm.com>
	<1257348117.31972.4360.camel@nimitz>
	<20091104161142.GA8825@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091104161142.GA8825-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Bharata B Rao <bharata.rao-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On 11/04/2009 05:11 PM, Serge E. Hallyn wrote:
> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>> On Wed, 2009-11-04 at 13:46 +0530, Balbir Singh wrote:
>>> The reason I liked /dev/cgroup was because cpusets could be
>>> mounted at /dev/cpuset or /dev/cgroup/cpuset. My concern with /cgroup
>>> is that a ls "/" now becomes larger in size. But I'll take your vote
>>> for it as +1 for /cgroup.
>>
>> /dev/pts is a decent precedent for doing it under /dev, although it does
>> deal with actual devices.  cgroups do not.
>
> Hmm, on whose behalf are you making this decision?
>
> LSB people will want to avoid using /cgroup,

LSB (and FHS) IMHO does not specify any place for such stuff:

/dev - for devices only, cgroups are not devices
/mnt - for admin temporary mounts and "should not affect the manner in 
which any program is run"
/var - for "any unsorted variable data", cgroups are not "unsorted 
variable data", it's interface to kernel

FHS does not specify either /sys and /selinux and it seems to me nobody 
complains about them.

/sys/cgroup would be the best, if sysfs supported mkdir(). But it does 
not :(. Our kernel guys told me it's relatively easy to create new empty 
directory /sys/cgroup (or /sys/kernel/cgroup), but it must be compiled 
into kernel or a module. Then I could mount some tmpfs to it, create 
/sys/cgroup/cpu, /sys/cgroup/memory etc. and mount the control group 
hierarchies there... but as you can see, it's really really ugly thing 
to do.

Jan
