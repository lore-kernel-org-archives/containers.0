From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v4 0/4] cgroups: support for module-loadable subsystems
Date: Thu, 07 Jan 2010 14:42:19 +0800
Message-ID: <4B45824B.9030108__44243.745195172$1262846599$gmane$org@cn.fujitsu.com>
References: <20091231051050.GA714@andrew.cmu.edu>	<20100106160414.bd555474.akpm@linux-foundation.org>	<20100107012606.GA25577@andrew.cmu.edu>
	<20100107120732.97d502bd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100107120732.97d502bd.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Wed, 6 Jan 2010 20:26:06 -0500
> Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> 
>> On Wed, Jan 06, 2010 at 04:04:14PM -0800, Andrew Morton wrote:
>>> On Thu, 31 Dec 2009 00:10:50 -0500
>>> Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
>>>
>>>> This patch series implements support for building, loading, and
>>>> unloading subsystems as modules, both within and outside the kernel
>>>> source tree. It provides an interface cgroup_load_subsys() and
>>>> cgroup_unload_subsys() which modular subsystems can use to register and
>>>> depart during runtime. The net_cls classifier subsystem serves as the
>>>> example for a subsystem which can be converted into a module using these
>>>> changes.
>>> What is the value in this?  What are the usage scenarios?  Why does the
>>> benefit of this change exceed the cost/risk/etc of merging it?
>> As discussed in the first posting of these patches, this provides the
>> ability for arbitrary subsystems to be used with cgroups.. cls_cgroup
>> would have already been a module except for a lack of support from
>> cgroups, and the change also allows other module-loadable classifiers
>> to add subsystems of their own.
> 
> Hmm, do you have your own module in plan ?
> 

Maybe the new blkio_cgroup can also be made module-able.
