From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] CFS CGroup: Report usage
Date: Thu, 25 Oct 2007 18:24:55 -0700
Message-ID: <6599ad830710251824w1e4a2720p90785e148b32f9c2__44354.0321117782$1193362084$gmane$org@mail.gmail.com>
References: <471D4523.4040509@google.com>
	<20071023164704.GE4667@linux.vnet.ibm.com>
	<6599ad830710230941y5d175688ob3a4d9ac42ba8c8f@mail.gmail.com>
	<20071023173837.GG4667@linux.vnet.ibm.com>
	<6599ad830710231928n65a80021w582a07b5993377f8@mail.gmail.com>
	<20071024043916.GA5357@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071024043916.GA5357-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/23/07, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>
> agreed, we need to be reporting idle time in (milli)seconds, although
> the requirement we had was to report it back in percentage. I guess the
> percentage figure can be derived from the raw idle time number.
>
> How about:
>
>         idle time = t4-t3 (effectively sleep time)
>
> in the above example?
>
> > It doesn't seem quite right to me that a cgroup's idle time metric be
> > affected by the activity of other cgroups on the machine,
>
> I don't see how the idle time metric defined above (t4-t3) can be
> affected by other cgroup activity, unless the execution pattern of one
> cgroup is dependent on the others.

If the other cgroups are busier, and t1-t2 is longer, then the cgroup
will get to the point where it's ready to sleep later in wallclock
time, and t4-t3 will be shorter in absolute terms. If there were no
other cgroups running, then presumably the sleep time would actually
be the sum of those three periods.

Even so, I guess you're right that t4-t3 is the most appropriate thing
to report, as long as people realise that it's a bit of a fuzzy value.

> I think primarily for systems management tools to report back various
> statistics about a OpenVZ/VServer-like container (just like top reports stats
> for a OS currently). Let me check if there are other uses envisoned for
> it.

Sorry, I didn't mean "how will you report it to users?", I meant "what
kinds of useful information will the users be able to get from it?"

Paul
