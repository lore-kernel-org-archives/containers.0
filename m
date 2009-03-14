From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Date: Fri, 13 Mar 2009 17:27:02 -0700
Message-ID: <m1hc1xrlt5.fsf__36051.8534471796$1236990722$gmane$org@fess.ebiederm.org>
References: <1234479845.30155.220.camel@nimitz>
	<20090226155755.GA1456@x200.localdomain>
	<20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr>
	<20090312145311.GC12390@us.ibm.com> <1236891719.32630.14.camel@bahia>
	<20090312212124.GA25019@us.ibm.com>
	<604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>
	<20090313053458.GA28833@us.ibm.com>
	<alpine.LFD.2.00.0903131018390.3940@localhost.localdomain>
	<20090313193500.GA2285@x200.localdomain>
	<alpine.LFD.2.00.0903131401070.3940@localhost.localdomain>
	<1236981097.30142.251.camel@nimitz> <49BADAE5.8070900@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49BADAE5.8070900-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Fri\, 13 Mar 2009 18\:15\:01 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:

> Dave Hansen wrote:
>> On Fri, 2009-03-13 at 14:01 -0700, Linus Torvalds wrote:
>>> On Fri, 13 Mar 2009, Alexey Dobriyan wrote:
>>>>> Let's face it, we're not going to _ever_ checkpoint any kind of general 
>>>>> case process. Just TCP makes that fundamentally impossible in the general 
>>>>> case, and there are lots and lots of other cases too (just something as 
>>>>> totally _trivial_ as all the files in the filesystem that don't get rolled 
>>>>> back).
>>>> What do you mean here? Unlinked files?
>>> Or modified files, or anything else. "External state" is a pretty damn 
>>> wide net. It's not just TCP sequence numbers and another machine.
>> 
>> This is precisely the reason that we've focused so hard on containers,
>> and *didn't* just jump right into checkpoint/restart; we're trying
>> really hard to constrain the _truly_ external things that a process can
>> interact with.  
>> 
>> The approach so far has largely been to make things are external to a
>> process at least *internal* to a container.  Network, pid, ipc, and uts
>> namespaces, for example.  An ipc/sem.c semaphore may be external to a
>> process, so we'll just pick the whole namespace up and checkpoint it
>> along with the process.
>> 
>> In the OpenVZ case, they've at least demonstrated that the filesystem
>> can be moved largely with rsync.  Unlinked files need some in-kernel TLC
>> (or /proc mangling) but it isn't *that* bad.
>
> And in the Zap we have successfully used a log-based filesystem
> (specifically NILFS) to continuously snapshot the file-system atomically
> with taking a checkpoint, so it can easily branch off past checkpoints,
> including the file system.
>
> And unlinked files can be (inefficiently) handled by saving their full
> contents with the checkpoint image - it's not a big toll on many apps
> (if you exclude Wine and UML...). At least that's a start.

Oren we might want to do a proof of concept implementation like I did
with network namespaces.  That is done in the community and goes far
enough to show we don't have horribly nasty code.  The patches and
individual changes don't need to be quite perfect but close enough
that they can be considered for merging.

For the network namespace that seems to have made a big difference.

I'm afraid in our clean start we may have focused a little too much
on merging something simple and not gone far enough on showing that
things will work.

After I had that in the network namespace and we had a clear vision of
the direction.   We started merging the individual patches and things
went well.

Eric
