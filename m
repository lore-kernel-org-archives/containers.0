From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 7/7] cgroups: Update documentation for bindable subsystems
Date: Mon, 08 Nov 2010 13:27:54 +0800
Message-ID: <4CD78A5A.30309__34473.7797081054$1289194193$gmane$org@cn.fujitsu.com>
References: <4CC146A4.9090505@cn.fujitsu.com> <4CC14769.2000406@cn.fujitsu.com>
	<AANLkTinbtLkF=haFeDkzecEWv_FE9jG4TefiptSnZcPi@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTinbtLkF=haFeDkzecEWv_FE9jG4TefiptSnZcPi-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
>>  Called when a cgroup subsystem is rebound to a different hierarchy
>> -and root cgroup. Currently this will only involve movement between
>> -the default hierarchy (which never has sub-cgroups) and a hierarchy
>> -that is being created/destroyed (and hence has no sub-cgroups).
>> +and root cgroup. For some subsystems this will only involve movement
>> +between the default hierarchy (which never has sub-cgroups) and a
>> +hierarchy that is being created/destroyed (and hence has no sub-cgroups).
>> +For some other subsystems this can involve movement between the default
>> +hierarchy and a mounted hierarchy which may have sub-cgroups in it.
> 
> This is a bit vague. How about:
> 
> For non-bindable subsystems, this will  only involve movement
> between the default hierarchy (which never has sub-cgroups) and a
> hierarchy that is being created/destroyed (and hence has no sub-cgroups).
> 
> For binadable subsystems, this may also involve movement between the
> default hierarchy and a mounted hierarchy that's populated with
> sub-cgroups.
> 
> Also, the docs should mention that a cgroup setting the can_bind flag
> has to be able to support side-effect free movement of a task into any
> just-created cgroup, and into the root cgroup at any time. i.e. it's
> not suitable for any subsystem where can_attach() might return false
> for the root cgroup or a newly-created cgroup, or attach() might have
> side-effects for those same cases.
> 
> Actually, perhaps we should forbid the combination of having both an
> attach() callback and can_bind=true ?
> 
> Also, post_clone() doesn't get called when creating the css hierarchy
> during binding.
> 

This is much better. :)

Documentation often causes my headache due to my limited English skill.
