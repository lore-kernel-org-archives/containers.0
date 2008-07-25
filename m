From: "Peter Dolding" <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Roadmap for features planed for containers where and Some future
	features ideas.
Date: Fri, 25 Jul 2008 13:32:54 +1000
Message-ID: <e7d8f83e0807242032p3c93b3dbqcd5f4d44aad9ca6f@mail.gmail.com>
References: <e7d8f83e0807210403g12b980e8jad4fa7e10d8b410e@mail.gmail.com>
	<m1k5ffmo48.fsf@frodo.ebiederm.org>
	<e7d8f83e0807210621y74ef1307x1c0ecbfb33182e85@mail.gmail.com>
	<m1y73uk8qc.fsf@frodo.ebiederm.org> <4885E927.7070505@cs.columbia.edu>
	<e7d8f83e0807221756y18ab14b6mfd8013b2e3424257@mail.gmail.com>
	<4888CACB.1000600@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4888CACB.1000600-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jul 25, 2008 at 4:32 AM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:
>
>
> Peter Dolding wrote:
>>
>> On Wed, Jul 23, 2008 at 12:05 AM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
>> wrote:
>>>
>>> Eric W. Biederman wrote:
>>>>
>>>> "Peter Dolding" <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>>>
>>>>> On Mon, Jul 21, 2008 at 10:13 PM, Eric W. Biederman
>>>>> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>>>>>
>>>>>> "Peter Dolding" <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>>>>>
>>>>>>> http://opensolaris.org/os/community/brandz/  I would like to see if
>>>>>>> something equal to this is on the roadmap in particular.   Being able
>>>>>>> to run solaris and aix closed source binaries contained would be
>>>>>>> useful.
>>>>>>
>>>>>> There have been projects to do this at various times on linux.  Having
>>>>>> a namespace dedicated to a certain kind of application is no big deal.
>>>>>> Someone would need to care enough to test and implement it though.
>>>>>>
>>>>>>> Other useful feature is some way to share a single process between
>>>>>>> PID
>>>>>>> containers as like a container bridge.  For containers used for
>>>>>>> desktop applications not having a single X11 server  interfacing with
>>>>>>> video card is a issue.
>>>>>>
>>>>>> X allows network connections, and I think unix domain sockets will
>>>>>> work.
>>>>>> The latter I need to check on.
>>>>>
>>>>> Does to a point until you see that local X11 is using shared memory
>>>>> for speed.   Hardest issue is getting GLX working.
>>>>
>>>> That is easier in general.  Don't unshare the sysvipc namespace.
>>>> Or share the mount of /dev/shmem at least for the file X cares about.
>>>>
>>>>>> The pid namespace is well defined and no a task will not be able
>>>>>> to change it's pid namespace while running.  That is nasty.
>>>>>
>>>>> Ok if that is imposable to extremely risky.
>>>>>
>>>>> What about a form of a proxy pid in the pid namespace proxying
>>>>> application chatter between 1 name space to another.  Applications
>>>>> being the bridge if its not possible to do it invisible to application
>>>>> could be made aware of it.   So they can provide shared memory and the
>>>>> like across pid namespaces. But only where they have a activated proxy
>>>>> to do there bidding.  This also allows applications to maintain there
>>>>> own internal secuirty between namespaces.
>>>>>
>>>>> Ie application is 1 pid number in its source container and virtual pid
>>>>> numbers in the following containers.  Symbolic linking at task level
>>>>> yes a little warped.  Yes this will annoying mean a special set of
>>>>> syscalls and a special set of capabilities and restrictions.  Like PID
>>>>> containers starting up forbidding proxy pid's or allowing them.
>>>>>
>>>>> If I am thinking right that avoids not be able to change it's pid.
>>>>> Instead sending and receiving the messages you need in the other name
>>>>> space threw a small proxy.   Yes I know that will cost some
>>>>> performance.
>>>>
>>>> Proxy pids don't actually do anything for you, unless you want to send
>>>> signals.  Because all of the namespaces are distinct.  So even at the
>>>> best of it you can see the X server but it still can't use your
>>>> network sockets or ipc shm.
>>>>
>>>> Better is working out the details on how to manipulate multiple
>>>> sysvipc and network namespaces from a single application.  Mostly
>>>> that is supported now by the objects there is just no easy way
>>>> of dealing with it.
>>>>
>>>>> Basically want to setup a neat universal container way of handling
>>>>> stuff like http://www.cs.toronto.edu/~andreslc/xen-gl/ without having
>>>>> to go network and hopefully in a way that limitations don't have to
>>>>> exist since messages are really only be sent threw 1 X11 server to 1
>>>>> driver system.  Only thing is really sending the correct messages to
>>>>> the correct place.   There will most likely be other services were a
>>>>> single entity at times is preferred.   Worst out come is if proxying
>>>>> .so is required.
>>>>
>>>> Yes.  I agree that is essentially desirable.  Given that I think
>>>> high end video card actually have multiple hardware contexts that
>>>> can be mapped into different user space processes there may be other
>>>> ways of handling this.
>>>>
>>>> Ideally we can find a high performance solution to X that also gives
>>>> us good isolation and migration properties.  Certainly something to talk
>>>> about tomorrow in the conference.
>>>
>>> In particular, if you wish to share private resources of a container
>>> between more than a single container, then you won't be able to use
>>> checkpoint/restart on neither container (unless you make special
>>> provisions in the code).
>>>
>>> I agree with Eric that the way to handle this is via virtualization
>>> as opposed to direct sharing. The same goes for other hardware, e.g.
>>> in the context of a user desktop - /dev/rtc, sound, and so on. My
>>> experience is that a proxy/virtualized device is what we probably
>>> want.
>>>
>>> Oren.
>>>
>> Giving up means to use checkpoint cleanly on containers independent of
>> each other when using X11 might be a requirement.   Reason in GPU
>> processing if you want to provide that a lot GPU's don't have a good
>> segmented freeze its either park the full GPU or risk issues on
>> startup.  Features need to be added to GPU so we can suspend
>> individual opengl context's to make that work.   So any application
>> using the GPU at most likely will have to be lost in a checkpoint
>> restore independent to the other X11 using the desktop.
>> Even suspending the GPU as a block there are still issues with some cards.
>>
>> Sorry Oren from using http://www.virtualgl.org I know suspending GPU's
>> is trouble.
>>
>> http://www.cs.toronto.edu/~andreslc/xen-gl/ blocks out all usage of
>> GPU for advance processing effectively crippling card.   Virtualized
>> basically is not going to cut it.   You need access to GPU for
>> particular software to work.
>>
>> This is more containers being used by desktop users to run many
>> distributions at once.
>>
>> Of course there is nothing stopping checkpoint process informing user
>> that they cannot go past this point in check pointing until the
>> following application are closed.  Ie the ones using the GPU shader
>> processing and the like.  We just have to wait for video card makers
>> to provide us with something equal intels and amd's cpu vitalisation
>> instructions to suspend independent opengl context's.
>>
>> Multiple hardware contexts are many independent gpu's stuck on cards
>> just like sticking more video cards in a computer  yes they can be
>> suspended independently yes how they are allocated should be
>> controllable,  These are not on every card out there.  Yet you want
>> migration sorry really bad new here.  A suspend of a gpu has to be
>> loaded backup on exactly the same type of GPU or you are stuffed.  2
>> different model cards will not work.  So this does not help you at all
>> with migration or even worse video card death.  Most people forget
>> that a suspend using compiz or anything else in gpu cannot be restored
>> if you have change video cards to a different gpu.  Brand card does
>> not help you here.
>>
>> Full X11 with Fully functional opengl will mean giving some things up.
>>  Means to keep every application running threw a migration or
>> checkpoint is impossable.   Applications container/suspend aware could
>> have some form of internal rebuild opengl context after restore from a
>> point they can restart there processing loop from but they will have
>> to redo all there shader code and other in gpu processing code in case
>> of change of gpu type and even there engine internal paths.  This
>> alteration would allow check pointing and migration back with
>> dependability but only if using aware applications.
>>
>> X11 2d can suspend and restore without major issue as
>> http://partiwm.org/wiki/xpra shows.  3d is a bugger.
>>
>> There is basically no magical trick to get around this problem.
>> Containers alone cannot solve it.  Rare section with loss has to be
>> excepted to make it work.  By it working will be like Xen when it
>> started started cpu makers looking at making it better.
>>
>> Restart should be a zero issue.   Clearing the opengl context
>> displayed on the X11 server gets done in case of a application splat
>> out reset would be equal.  When application restarts it will create
>> the opengl context new so no 3d issue.
>>
>> Video cards are different to most other hardware you are dealing with.
>>  They are a second processing core that you don't have full control
>> over and are different card to card to the point of being 100 percent
>> incompatible with each other.
>>
>
> If you want to migrate containers with user desktops, you really have
> to be able to load the state off the display hardware on the source
> machine and re-instate that state on the display hardware of the target
> machine. This is practically impossible given current hardware and the
> variance between vendors, and probably won't change. Instead, you _must_
> have a way to virtualize the display, for instance by using VNC. VNC is
> ok for regular work, but is inefficient in many aspects. Projects like
> THINC (http://www.ncl.cs.columbia.edu/research/thinc) improve on it by
> making the remote display efficient to the point that you can actually
> view movies with remote display. As far as I know the 3D case is not
> solved efficiently as of yet.
>
> Current solutions for running user desktop sessions in containers rely
> on remote display to virtualize the display, such that rendering is
> either done in software on the server or in hardware on the (stateless)
> client side. In my opinion the same should apply for 3D graphics within
> such environments, which probably means doing the actual rendering at
> the client side.

The simple problem that is not possible and most likely never will be.
 How to virtual opengl for VNC is use a program call
http://virtualgl.org  and that is not state less and gpu dependent.

You are keeping on forgetting high end stuff like glsl need to be
processed in video cards gpu's to emulate need really large cpu's.  2d
rendering is simple to do stateless.

Your opinion is simply not workable.  You are not thinking of the
problem correct.

Lets say you want to migrate between X86 and PPC running applications
using containers how are you going to do it.   This is really the
level of complexity you have inside video card gpu's.  They are that
far different.   Programs have to generate there glsl code to suit the
video card they are talking to or it will not work correctly.  Reason
why some games have on box only NVidia or only ATI gpu's.

Now before you say emulate.  Like to point something nasty out.
State dump of a gpu is basically not documented its a black box so
emulation is not a option.  Even if you could you are talking about
emulating something that will need the power of a 16 core 4 ghz intel
processor if it has only 1 GPU to emulate.  Note some video cards have
upto 4.   How effective gpu's are at doing there job is highly under
estimated .

Yes the issue is some opengl programs can be done stateless up until
they start using shader languages physics and other things in GPU.
Past that point stateless and gpu independent stuff.  Lots and lots of
programs need the GPU dependant stuff.

Virtualgl does rendering server side due to the massive amounts of
data that can be travelling between the cpu and gpu.   It really like
saying we are not going to have a maths processer in the server and
every time you want to do some maths you have to go threw network to
do it.

GPU are not just drawing to screen.   They do all kinds of things
these days.  They have to be used locally to the program running there
is not enough network bandwidth and they will not run right.

Peter Dolding
