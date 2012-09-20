From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Thu, 20 Sep 2012 11:39:46 -0700
Message-ID: <CALCETrX78_twPUkNTZbtXQv9yBnW+-c9RhetassdrQKicOiDFg__35051.0717290037$1348166425$gmane$org@mail.gmail.com>
References: <20120913205827.GO7677@google.com>
	<505A725B.2080901@amacapital.net>
	<20120920182651.GH28934@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120920182651.GH28934-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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

On Thu, Sep 20, 2012 at 11:26 AM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Hello,
>
> On Wed, Sep 19, 2012 at 06:33:15PM -0700, Andy Lutomirski wrote:
>> [grr.  why does gmane scramble addresses?]
>
> You can append /raw to the message url and see the raw mssage.
>
>   http://article.gmane.org/gmane.linux.kernel.containers/23802/raw

Thanks!

>
>> >   I think this level of flexibility should be enough for most use
>> >   cases.  If someone disagrees, please voice your objections now.
>>
>> OK, I'll bite.
>>
>> I have a server that has a whole bunch of cores.  A small fraction of
>> those cores are general purpose and run whatever they like.  The rest
>> are tightly controlled.
>>
>> For simplicity, we have two cpusets that we use.  The root allows all
>> cpus.  The other one only allows the general purpose cpus.  We shove
>> everything into the general-purpose-only cpuset, and then we move
>> special stuff back to root.  (We also shove some kernel threads into a
>> non-root cpuset using the 'cset' tool.)
>
> Using root for special stuff probably isn't a good idea and moving
> bound kthreads into !root cgroups is already disallowed.

Agreed.  I do it this way because it's easy and it works.  I can
change it in the future if needed.

>
>> Enter systemd, which wants a hierarchy corresponding to services.  If we
>> were to use it, we might end up violating its hierarchy.
>>
>> Alternatively, if we started using memcg, then we might have some tasks
>> to have more restrictive memory usage but less restrictive cpu usage.
>>
>> As long as we can still pull this off, I'm happy.
>
> IIUC, you basically want just two groups w/ cpuset and use it for
> loose cpu ioslation for high priority jobs.  Structure-wise, I don't
> think it's gonna be a problem although using root for special stuff
> would need to change.

Right.

But what happens when multiple hierarchies go away and I lose control
of the structure?  If systemd or whatever sticks my whole session or
my service (or however I organize it) into cgroup /whatever, then
either I can put my use-all-cpus tasks into /whatever/everything or I
can step outside the hierarchy and put them into /everything.  The
former doesn't work, because

<quote>
The following rules apply to each cpuset:

 - Its CPUs and Memory Nodes must be a subset of its parents.
</quote>

The latter might confuse systemd.

My real objection might be to that requirement a cpuset can't be less
restrictive than its parents.  Currently I can arrange for a task to
simultaneously have a less restrictive cpuset and a more restrictive
memory limit (or to stick it into a container or whatever).  If the
hierarchies have to correspond, this stops working.

--Andy
