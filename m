From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Roadmap for features planed for containers where and Some future
	features ideas.
Date: Sat, 26 Jul 2008 00:05:19 -0700
Message-ID: <m1od4lruq8.fsf@frodo.ebiederm.org>
References: <e7d8f83e0807210403g12b980e8jad4fa7e10d8b410e@mail.gmail.com>
	<m1k5ffmo48.fsf@frodo.ebiederm.org>
	<e7d8f83e0807210621y74ef1307x1c0ecbfb33182e85@mail.gmail.com>
	<m1y73uk8qc.fsf@frodo.ebiederm.org> <4885E927.7070505@cs.columbia.edu>
	<e7d8f83e0807221756y18ab14b6mfd8013b2e3424257@mail.gmail.com>
	<4888CACB.1000600@cs.columbia.edu>
	<e7d8f83e0807242032p3c93b3dbqcd5f4d44aad9ca6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <e7d8f83e0807242032p3c93b3dbqcd5f4d44aad9ca6f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Peter Dolding's message of "Fri, 25 Jul 2008 13:32:54 +1000")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Dolding <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

"Peter Dolding" <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> The simple problem that is not possible and most likely never will be.
>  How to virtual opengl for VNC is use a program call
> http://virtualgl.org  and that is not state less and gpu dependent.
>
> You are keeping on forgetting high end stuff like glsl need to be
> processed in video cards gpu's to emulate need really large cpu's.  2d
> rendering is simple to do stateless.
>
> Your opinion is simply not workable.  You are not thinking of the
> problem correct.
>
> Lets say you want to migrate between X86 and PPC running applications
> using containers how are you going to do it.   This is really the
> level of complexity you have inside video card gpu's.  They are that
> far different.   Programs have to generate there glsl code to suit the
> video card they are talking to or it will not work correctly.  Reason
> why some games have on box only NVidia or only ATI gpu's.
>
> Now before you say emulate.  Like to point something nasty out.
> State dump of a gpu is basically not documented its a black box so
> emulation is not a option.  Even if you could you are talking about
> emulating something that will need the power of a 16 core 4 ghz intel
> processor if it has only 1 GPU to emulate.  Note some video cards have
> upto 4.   How effective gpu's are at doing there job is highly under
> estimated .
>
> Yes the issue is some opengl programs can be done stateless up until
> they start using shader languages physics and other things in GPU.
> Past that point stateless and gpu independent stuff.  Lots and lots of
> programs need the GPU dependant stuff.
>
> Virtualgl does rendering server side due to the massive amounts of
> data that can be travelling between the cpu and gpu.   It really like
> saying we are not going to have a maths processer in the server and
> every time you want to do some maths you have to go threw network to
> do it.
>
> GPU are not just drawing to screen.   They do all kinds of things
> these days.  They have to be used locally to the program running there
> is not enough network bandwidth and they will not run right.

I need to research this some more, but migration is essentially the
same problem as suspend and hibernation (admittedly different kinds of
video make this trickier).  Migration and hibernation we can handle
today with hardware going away and coming back.  It sounds like to me
the most general approach is a light-weight proxy X server that can
forward things on the slow path and allow the fast path accesses to
go fast.

Eric
