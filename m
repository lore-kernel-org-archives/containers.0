From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: containers and cgroups mini-summit @ Linux Plumbers
Date: Thu, 02 Aug 2012 11:42:53 +0200
Message-ID: <501A4B9D.50606@monom.org>
References: <4FFDF321.4030103@openvz.org> <501A3C48.6060607@monom.org> <501A3C4D.1020101@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <501A3C4D.1020101-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Daniel Lezcano <daniel.lezcano-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Rohit Seth <rohitseth-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Dhaval Giani <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Tim Hockin <thockin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Suleiman Souhlal <ssouhlal-HZy0K5TPuP5AfugRpC6u6w@public.gmane.org>, Dave Kleikamp <dave.kleikamp-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Maxim Patlasov <MPatlasov-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Glauber,

On 02.08.2012 10:37, Glauber Costa wrote:
> On 08/02/2012 12:37 PM, Daniel Wagner wrote:
>> Hi,
>>
>> On 11.07.2012 23:41, Kir Kolyshkin wrote:
>>> Gentlemen,
>>>
>>> We are organizing containers mini-summit during next Linux Plumbers (San
>>> Diego, August 29-31).
>>> The idea is to gather and discuss everything relevant to namespaces,
>>> cgroups, resource management,
>>> checkpoint-restore and so on.
>>>
>>> We are trying to come up with a list of topics to discuss, so please
>>> reply with topic suggestions, and
>>> let me know if you are going to come.
>>
>> I'd like to give a short presentation on what we would like to do with
>> cgroups and ConnMan including a demonstration. The demo will show what
>> will happpen when orthogonal cgroup hierarchies are getting used by more
>> than just systemd. Also I'd like to trigger some discussion on the
>> future of the networking controllers (net_prio, net_cls).
>>
>
> Daniel, could you fill up the details of this proposal in the plumbers
> system? I believe kir sent out the details on how to do it somewhere
> down this thread...

Thanks, just added this one here:

https://blueprints.launchpad.net/lpc/+spec/lpc2012-cont-network

cheers,
daniel
