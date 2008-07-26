From: "Peter Dolding" <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Roadmap for features planed for containers where and Some future
	features ideas.
Date: Sat, 26 Jul 2008 20:06:05 +1000
Message-ID: <e7d8f83e0807260306q194be9e9q53151abcea818624@mail.gmail.com>
References: <e7d8f83e0807210403g12b980e8jad4fa7e10d8b410e@mail.gmail.com>
	<m1k5ffmo48.fsf@frodo.ebiederm.org>
	<e7d8f83e0807210621y74ef1307x1c0ecbfb33182e85@mail.gmail.com>
	<m1y73uk8qc.fsf@frodo.ebiederm.org> <4885E927.7070505@cs.columbia.edu>
	<e7d8f83e0807221756y18ab14b6mfd8013b2e3424257@mail.gmail.com>
	<4888CACB.1000600@cs.columbia.edu>
	<e7d8f83e0807242032p3c93b3dbqcd5f4d44aad9ca6f@mail.gmail.com>
	<m1od4lruq8.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1od4lruq8.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
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
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Jul 26, 2008 at 5:05 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> "Peter Dolding" <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>
>> The simple problem that is not possible and most likely never will be.
>>  How to virtual opengl for VNC is use a program call
>> http://virtualgl.org  and that is not state less and gpu dependent.
>>
>> You are keeping on forgetting high end stuff like glsl need to be
>> processed in video cards gpu's to emulate need really large cpu's.  2d
>> rendering is simple to do stateless.
>>
>> Your opinion is simply not workable.  You are not thinking of the
>> problem correct.
>>
>> Lets say you want to migrate between X86 and PPC running applications
>> using containers how are you going to do it.   This is really the
>> level of complexity you have inside video card gpu's.  They are that
>> far different.   Programs have to generate there glsl code to suit the
>> video card they are talking to or it will not work correctly.  Reason
>> why some games have on box only NVidia or only ATI gpu's.
>>
>> Now before you say emulate.  Like to point something nasty out.
>> State dump of a gpu is basically not documented its a black box so
>> emulation is not a option.  Even if you could you are talking about
>> emulating something that will need the power of a 16 core 4 ghz intel
>> processor if it has only 1 GPU to emulate.  Note some video cards have
>> upto 4.   How effective gpu's are at doing there job is highly under
>> estimated .
>>
>> Yes the issue is some opengl programs can be done stateless up until
>> they start using shader languages physics and other things in GPU.
>> Past that point stateless and gpu independent stuff.  Lots and lots of
>> programs need the GPU dependant stuff.
>>
>> Virtualgl does rendering server side due to the massive amounts of
>> data that can be travelling between the cpu and gpu.   It really like
>> saying we are not going to have a maths processer in the server and
>> every time you want to do some maths you have to go threw network to
>> do it.
>>
>> GPU are not just drawing to screen.   They do all kinds of things
>> these days.  They have to be used locally to the program running there
>> is not enough network bandwidth and they will not run right.
>
> I need to research this some more, but migration is essentially the
> same problem as suspend and hibernation (admittedly different kinds of
> video make this trickier).  Migration and hibernation we can handle
> today with hardware going away and coming back.  It sounds like to me
> the most general approach is a light-weight proxy X server that can
> forward things on the slow path and allow the fast path accesses to
> go fast.
>
Issue is light-weight proxy fails as soon as you start dealing with
the GPU processing stuff.

This has already been fairly heavily researched.   Complete system
suspend works because you take the complete gpu off line and restore
it back to where it was on the same GPU.

Migration is worse than you can dream.  Even the same model GPU loaded
with a different GPU save state can fail if maker has altered paths
due to damage in 1 chip.  I see no trick around this.  Even GPU's on
the same card can fail if you try to restore the wrong state back into
them.

Using a light-weight proxy you will be able to tag applications using
advanced GPU instructions that will not migrate or suspend happily.

http://partiwm.org/wiki/xpra  Is one of the ones you will want to work
with when building a light weight proxy.   This allows X11
applications to be disconnected from one X11 server and connected to
another.

http://www.cs.toronto.edu/~andreslc/xen-gl/ Also got so far along
forwarding opengl.

Its more you will have to sort.  It will break down into 4.

2d and maybe some opengl suspendable because interface can be simplely
regenerated on a new X11 server using nothing GPU targeted.

Using GPU heavily with a detectable resend of everything to gpu with
corrections for change of video card.   This would cover some games
that at change of level and restart game engine with diagnostics.
This would be more setting fixed suspend points where application
could only be suspended at those points.  Some applications that do
some gpu off loading of tasks.   Ie comes like trying to stop a
critical section of kernel have to wait.

Using GPU no clean suspend points.   Has to be lost in the suspend or
transfer process.

Final would be a way is to build in a Xen system for GPU access a
cooperative setup were application can be told to suspend and restore
self.

Most likely all 4 types will be needed to cover everything.  Or close
to everything you can.

This is the issue you are dealing with exactly in pcode.

start of program
Detect GPU
create needed gpu code
send gpu code to gpu.

Later on in program
Call the uploaded gpu code in the first place.
do some code.
get the results from gpu call earlier.
do some code
get another lot of results from the same gpu function started before.
.... repeating until program completes.

Reason someone run something like a random number provider in the gpu.
  Now stoping and restoring anywhere in that is going to need
knowledge of what is going on in the gpu you cannot get.

Basically a complete parallel thread can be looping away in the gpu.
Without inspecting the gpu code or seeing it directly terminated you
don't know if its going to be accessed again.  And if it should be
running and its not program splat.   Even worse if its some form of
collective state like gpu is simulating gravity effects on char or
rebound effects.   Even throwing the starting program into the gpu is
not going to work because its not going to have the correct state.

Issue with inspecting the gpu lot of programs will be outputing for
ATI Nvidia gpus then even specialising that code down to the mode gpu
from there code base.

Worst bit application may not be graphical at all
http://graphics.stanford.edu/projects/brookgpu/  might be something
using this to off load processing to the GPU.

Suspend is basically imposable on a application using gpu without
suspending everything else in that gpu.  Until that feature is added
to gpu.  Even worse migration is not dependable between gpu's on the
same card let alone different cards.   So other paths will have to be
taken.

GPU is the problem.   Most of the other rendering stuff is simple to
solve.   GPU are a stack of rogue threads.

There is no magical way around this problem.   We all wish there were.
  Every nice virtual solution is a brick wall.  Mixed solution is
kinda needed.   Also the reason why I did not care if desktop use
complete broke mean to migrate and suspend its a lot simpler that way.

Of course you might dream up some way I have not even considered.

Peter Dolding

PS own GPU language will only work for newly code applications also
will be slower as some programs build there own gpu code locallly in
advance and upload it on demand.
