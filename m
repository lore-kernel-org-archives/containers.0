From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: What can OpenVZ do?
Date: Fri, 13 Mar 2009 17:04:55 -0700
Message-ID: <m1wsatrmu0.fsf__33810.3628172123$1236989376$gmane$org@fess.ebiederm.org>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz> <20090213102732.GB4608@elte.hu>
	<20090213113248.GA15275@x200.localdomain>
	<20090213114503.GG15679@elte.hu>
	<20090213222818.GA17630@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090213222818.GA17630-2ev+ksY9ol182hYKe6nXyg@public.gmane.org> (Alexey Dobriyan's
	message of "Sat\, 14 Feb 2009 01\:28\:18 +0300")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Fri, Feb 13, 2009 at 12:45:03PM +0100, Ingo Molnar wrote:
>> 
>> * Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> 
>> > On Fri, Feb 13, 2009 at 11:27:32AM +0100, Ingo Molnar wrote:
>> > > Merging checkpoints instead might give them the incentive to get
>> > > their act together.
>> > 
>> > Knowing how much time it takes to beat CPT back into usable shape every time
>> > big kernel rebase is done, OpenVZ/Virtuozzo have every single damn incentive
>> > to have CPT mainlined.
>> 
>> So where is the bottleneck? I suspect the effort in having forward ported
>> it across 4 major kernel releases in a single year is already larger than
>> the technical effort it would  take to upstream it. Any unreasonable upstream 
>> resistence/passivity you are bumping into?
>
> People were busy with netns/containers stuff and OpenVZ/Virtuozzo bugs.

Yes.  Getting the namespaces particularly the network namespace finished
has consumed a lot of work.

Then we have a bunch of people helping with ill conceived patches that seem
to wear out the patience of people upstream.  Al, Greg kh, Linus.

The whole recent ressurection of the question of we should have a clone
with pid syscall.

Eric
