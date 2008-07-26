From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Roadmap for features planed for containers where and Some future
	features ideas.
Date: Sat, 26 Jul 2008 06:56:45 -0700
Message-ID: <m14p6cpx42.fsf@frodo.ebiederm.org>
References: <e7d8f83e0807210403g12b980e8jad4fa7e10d8b410e@mail.gmail.com>
	<m1k5ffmo48.fsf@frodo.ebiederm.org>
	<e7d8f83e0807210621y74ef1307x1c0ecbfb33182e85@mail.gmail.com>
	<m1y73uk8qc.fsf@frodo.ebiederm.org> <4885E927.7070505@cs.columbia.edu>
	<e7d8f83e0807221756y18ab14b6mfd8013b2e3424257@mail.gmail.com>
	<4888CACB.1000600@cs.columbia.edu>
	<e7d8f83e0807242032p3c93b3dbqcd5f4d44aad9ca6f@mail.gmail.com>
	<m1od4lruq8.fsf@frodo.ebiederm.org>
	<e7d8f83e0807260306q194be9e9q53151abcea818624@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <e7d8f83e0807260306q194be9e9q53151abcea818624-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Peter Dolding's message of "Sat, 26 Jul 2008 20:06:05 +1000")
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

> Issue is light-weight proxy fails as soon as you start dealing with
> the GPU processing stuff.
>
> This has already been fairly heavily researched.   Complete system
> suspend works because you take the complete gpu off line and restore
> it back to where it was on the same GPU.

Darn.  2D X (the last I looked at it) has the property where the applications
are required at any point to be able to repaint all of their windows.  It sounds
like this is not the case for 3D X applications and it is a real shame.

I also suspect that even if I use the repaint trick do it in such a way
that I am allowed to switch the gpu buggy applications will fail.

> Migration is worse than you can dream.  Even the same model GPU loaded
> with a different GPU save state can fail if maker has altered paths
> due to damage in 1 chip.  I see no trick around this.  Even GPU's on
> the same card can fail if you try to restore the wrong state back into
> them.

Not really.  I know that direct hardware access by application programs
is a problem.   My practical question is how robust programs are to hardware
hotplug.

> Using a light-weight proxy you will be able to tag applications using
> advanced GPU instructions that will not migrate or suspend happily.

That sounds very practical.

> http://partiwm.org/wiki/xpra  Is one of the ones you will want to work
> with when building a light weight proxy.   This allows X11
> applications to be disconnected from one X11 server and connected to
> another.
>
> http://www.cs.toronto.edu/~andreslc/xen-gl/ Also got so far along
> forwarding opengl.
>
> Its more you will have to sort.  It will break down into 4.
>
> 2d and maybe some opengl suspendable because interface can be simplely
> regenerated on a new X11 server using nothing GPU targeted.
>
> Using GPU heavily with a detectable resend of everything to gpu with
> corrections for change of video card.   This would cover some games
> that at change of level and restart game engine with diagnostics.
> This would be more setting fixed suspend points where application
> could only be suspended at those points.  Some applications that do
> some gpu off loading of tasks.   Ie comes like trying to stop a
> critical section of kernel have to wait.
>
> Using GPU no clean suspend points.   Has to be lost in the suspend or
> transfer process.

Yep.


> GPU is the problem.   Most of the other rendering stuff is simple to
> solve.   GPU are a stack of rogue threads.
>
> There is no magical way around this problem.   We all wish there were.
>   Every nice virtual solution is a brick wall.  Mixed solution is
> kinda needed.   Also the reason why I did not care if desktop use
> complete broke mean to migrate and suspend its a lot simpler that way.

Totally and if we have the capabilities today to make it work without
the possibility of suspend/resume I am happy with that.

> Of course you might dream up some way I have not even considered.

Certainly worth thinking about.

For I am concerned with getting the basics working solid.  So I don't
plan on working on any of this any time soon.  Other contributions
are welcome.

> Peter Dolding
>
> PS own GPU language will only work for newly code applications also
> will be slower as some programs build there own gpu code locallly in
> advance and upload it on demand.

Nah.  I'm happy so long as we have a way to say: "Hey!  You silly application
that was talking directly to the hardware.  You have to deal with new hardware
now.  Cope."

Eric
