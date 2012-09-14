From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Fri, 14 Sep 2012 12:55:36 +0400
Message-ID: <5052F108.6070407@parallels.com>
References: <20120913205827.GO7677@google.com> <1347621302.7172.22.camel@twins>
	<20120914125427.GW6819@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120914125427.GW6819-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 09/14/2012 04:54 PM, Daniel P. Berrange wrote:
> On Fri, Sep 14, 2012 at 01:15:02PM +0200, Peter Zijlstra wrote:
>> On Thu, 2012-09-13 at 13:58 -0700, Tejun Heo wrote:
>>>   The cpu ones handle nesting correctly - parent's accounting includes
>>>   children's, parent's configuration affects children's unless
>>>   explicitly overridden, and children's limits nest inside parent's. 
>>
>> The implementation has some issues with fixed point math limitations on
>> deep hierarchies/large cpu count, but yes.
>>
>> Doing soft-float/bignum just isn't going to be popular I guess ;-)
>>
>> People also don't seem to understand that each extra cgroup carries a
>> cost and that nested cgroups are more expensive still, even if the
>> intermediate levels are mostly empty (libvirt is a good example of how
>> not to do things).
>>
>> Anyway, I guess what I'm saying is that we need to work on the awareness
>> of cost associated with all this cgroup nonsense, people seem to think
>> its all good and free -- or not think at all, which, while depressing,
>> seem the more likely option.
> 
> In defense of what libvirt is doing, I'll point out that the kernel
> docs on cgroups make little to no mention of these performance / cost
> implications, and the examples of usage given arguably encourage use
> of deep hierarchies.
> 
> Given what we've now learnt about the kernel's lack of scalability
> wrt cgroup hierarchies, we'll be changing the way libvirt deals with
> cgroups, to flatten it out to only use 1 level by default. If the
> kernel docs had clearly expressed the limitations & made better
> recommendations on app usage we would never have picked the approach
> we originally chose.
> 
> Regards,
> Daniel
> 
I personally don't think this is such a crazy setup. It is perfectly
valid to say "all applications managed by libvirt as a whole cannot use
more than X". Now of course there are other ways to do it, and we really
need to make people more aware of the costs...
