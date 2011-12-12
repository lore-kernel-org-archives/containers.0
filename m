From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: How to draw values for /proc/stat
Date: Mon, 12 Dec 2011 13:35:09 +0400
Message-ID: <4EE5CACD.5080606@parallels.com>
References: <4EDC8FB1.60407@parallels.com> <1323439411.17673.65.camel@twins>  <4EE22179.5090106@parallels.com> <1323682413.16764.55.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323682413.16764.55.camel@twins>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Cc: Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 12/12/2011 01:33 PM, Peter Zijlstra wrote:
> On Fri, 2011-12-09 at 12:55 -0200, Glauber Costa wrote:
>> On 12/09/2011 12:03 PM, Peter Zijlstra wrote:
>
>>> Namespaces seem to be about limiting visibility, cgroups about
>>> controlling resources.
>>>
>>> The two things are hopelessly disjoint atm, but I believe someone was
>>> looking at this mess.
>>
>> I did take a look at this (if anyone else was, I'd like to know so we
>> can share some ideas), but I am not convinced we should do anything to
>> join them anymore. We virtualization people are to the best of my
>> knowledge the only ones doing namespaces. Cgroups, OTOH, got a lot bigger.
>>
>> What I am mostly concerned about now, is how consistent they will be.
>> /proc always being always global indeed does make sense, but my question
>> still stands: if you live in a resource-controlled world, why should you
>> even see resources you will never own ?
>
> Since without namespaces you can still see the rest of the world. So it
> makes sense to me to still see all resources too.
>
> Also, proportional controllers might not see a consistent slice of the
> resource, making the stats rather awkward to interpret.
>
> Furthermore, not everybody might care about these statistics at all and
> I know pjt objected to being subjected to the extra accounting (pjt do
> speak up etc..).
>
>> If it is not co-mounted, we draw the global value. If you don't mount
>> it, I someone does not mount it, I can assure you he doesn't care about
>> it. We for sure will.
>
> Anyway, looking at the rest of the emails in this thread the current
> proposal is a cgroup mount option that indicates if you want these
> per-cgroup stats or not, right?

Well, it is something in this direction. I don't think it's entirely 
clear what exactly it will look like, but it seems we're making progress.

--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
