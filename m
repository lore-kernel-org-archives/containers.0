From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Wed, 19 Sep 2012 18:33:15 -0700
Message-ID: <505A725B.2080901__2395.67985195226$1348104824$gmane$org@amacapital.net>
References: <20120913205827.GO7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120913205827.GO7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4RrovVCs/uTlw@public.gmane.org>, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

[grr.  why does gmane scramble addresses?]

On 09/13/2012 01:58 PM, Tejun Heo wrote:
> 
> 6. Multiple hierarchies
> 
>   Apart from the apparent wheeeeeeeeness of it (I think I talked about
>   that enough the last time[1]), there's a basic problem when more
>   than one controllers interact - it's impossible to define a resource
>   group when more than two controllers are involved because the
>   intersection of different controllers is only defined in terms of
>   tasks.
> 
>   IOW, if an entity X is of interest to two controllers, there's no
>   way to map X to the cgroups of the two controllers.  X may belong to
>   A and B when viewed by one task but A' and B when viewed by another.
>   This already is a head scratcher in writeback where blkcg and memcg
>   have to interact.
> 
>   While I am pushing for unified hierarchy, I think it's necessary to
>   have different levels of granularities depending on controllers
>   given that nesting involves significant overhead and noticeable
>   controller-dependent behavior changes.
> 
> 

> ...

>   I think this level of flexibility should be enough for most use
>   cases.  If someone disagrees, please voice your objections now.
> 

OK, I'll bite.

I have a server that has a whole bunch of cores.  A small fraction of
those cores are general purpose and run whatever they like.  The rest
are tightly controlled.

For simplicity, we have two cpusets that we use.  The root allows all
cpus.  The other one only allows the general purpose cpus.  We shove
everything into the general-purpose-only cpuset, and then we move
special stuff back to root.  (We also shove some kernel threads into a
non-root cpuset using the 'cset' tool.)

Enter systemd, which wants a hierarchy corresponding to services.  If we
were to use it, we might end up violating its hierarchy.

Alternatively, if we started using memcg, then we might have some tasks
to have more restrictive memory usage but less restrictive cpu usage.

As long as we can still pull this off, I'm happy.

--Andy

P.S.  I'm sure you can guess why based on my email address :)
