From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: Fw: cgroups and dbus
Date: Wed, 23 Dec 2009 08:58:07 +0800
Message-ID: <4B316B1F.7010108@cn.fujitsu.com>
References: <20091221142438.1c70fadb.kamezawa.hiroyu@jp.fujitsu.com>	<661de9470912202135s5869f0d0w6379ef6f3a668e8a@mail.gmail.com>	<4B2F480E.8090303@collabora.co.uk>	<20091222134649.61a0e290.kamezawa.hiroyu@jp.fujitsu.com>
	<4B30A1C6.5040405@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B30A1C6.5040405-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ian Molton <ian.molton-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

>> It seems what you asked was an example of cgroup.
>> Maybe the simplest cgroup in the kernel is CONFIG_CGROUP_CPUACCT. 
>> (kernel/sched.c) The next one is CGROUP_DEVICE (security/device_cgroup.c)
>>
>> Documentation under Documentation/cgroups/ is always taken care to be updated.
>> If you notice some description is unclear or obsolete, please report it.
> 
> I found my problem with the example there,
> 
> my machine has no RAM on node 0.
> 
> Can I suggest that the example might be better if it uses node 0 ? or had a
> note saying that if you have no memory on node 1 that it will fail with:
> "/bin/echo: write error: No space left on device" ?
> 
> Also it would be a good idea if the example pointed out that the parent to
> 'sh' is in the cgroup Charlie also.
> 
> Heres a patch:
> 
>>From e6e430d3c3e865f21dffc75ff090bb283a4f32a0 Mon Sep 17 00:00:00 2001
> From: Ian Molton <ian.molton-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
> Date: Tue, 22 Dec 2009 10:31:20 +0000
> Subject: [PATCH] cgroup: Clarify documentation
> 
>         This patch clarifies the cgroup documentation, giving some info on why
> the example given may fail, and a little more detail on its expected behaviour.
> 
> Signed-off-by: Ian Molton <ian.molton-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
> ---
>  Documentation/cgroups/cgroups.txt |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
> index 0b33bfe..8ac8615 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -309,7 +309,9 @@ the "cpuset" cgroup subsystem, the steps are something like:
> 
>  For example, the following sequence of commands will setup a cgroup
>  named "Charlie", containing just CPUs 2 and 3, and Memory Node 1,
> -and then start a subshell 'sh' in that cgroup:
> +and then start a subshell 'sh' in that cgroup. Note that if you have no RAM
> +on node 1 or dont have 4 CPUs you will want to modify the example
> +accordingly:
> 
>    mount -t cgroup cpuset -ocpuset /dev/cgroup
>    cd /dev/cgroup
> @@ -317,7 +319,12 @@ and then start a subshell 'sh' in that cgroup:
>    cd Charlie
>    /bin/echo 2-3 > cpuset.cpus
>    /bin/echo 1 > cpuset.mems
> +  # If you have no RAM on Node 0 the next command will return an error, eg.
> +  # write error: No space left on device

Please patch Documentation/cgroups/cpusets.txt instead, and CC
the maintainers.

>    /bin/echo $$ > tasks
> +  # The current shell is now in cgroup Charlie. You can check this with:
> +  cat /proc/self/cgroup

This is a duplicate. The documenation just below has showed
the use of /proc/self/cgroup.

> +  # Now launch a subshell which should inherit the cgroup:
>    sh
>    # The subshell 'sh' is now running in cgroup Charlie
>    # The next line should display '/Charlie'
