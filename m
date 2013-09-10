From: Amir Goldstein <amir-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Subject: Re: RFC: Device Namespaces
Date: Tue, 10 Sep 2013 09:09:31 +0200
Message-ID: <CAA2m6vc_kWWGDWcdjk26N3YvTqZySLFxPQRjOD9_ypBOka2+GQ@mail.gmail.com>
References: <CAA4jN2aw4zEW=UfKCyqaOvXnbiRb_J9srfCn4OXTFzc6vWBM4A@mail.gmail.com>
	<20130822182118.GA28331@sergelap>
	<CAA4jN2YL7Lfu2+DW-i+MovFxWEhJfT4aBBKREU_vy7JX9TKGHA@mail.gmail.com>
	<8761udlu0d.fsf@xmission.com>
	<CAA2m6vexArJ+6jFbK80Amstk=LK30=XDNHdBHSswP=LgpSP-6A@mail.gmail.com>
	<871u4yddg4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871u4yddg4.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Sep 9, 2013 at 2:51 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>wrote:

> Amir Goldstein <amir-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org> writes:
>
> > On Fri, Sep 6, 2013 at 7:50 PM, Eric W. Biederman
> > <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> >
> > Hi Eric,
> >
> > If we can get people to take a quick look at the code before LPC
> > that could make the LPC discussions more effective.
> > Even looking at one of the subsystem patches can give a basic
> > idea of the work we have done:
> > https://github.com/Cellrox/linux/commits/devns-goldfish-3.4
> >
> >     I think you are talking about having wrappers around your devices
> >     so you
> >     can share.  Which is not the quite same problem the rest of us
> >     have been
> >     thinking of when talking about a device namespace.
> >
> > We are interested in all problems related to virtualizated view of
> > devices
> > inside a container, so let our work so far be a starting point to
> > discuss all of them.
> >
> >     My first impression is that this is better solved with more
> >     appropriate
> >     abstractions in userspace or in the kernel.
>
> As I read your code, you are solving the problem of one opener of a
> device among a group of openers being able to access a device at a time.
> Which leads to the question why can't the multiplexing happen in
> userspace?
>
> I think with your design it would not be possible to play a song in one
> device namespace while doing work in the other.  As a security model
> that isn't wrong but as someone trying to get work done that could be a
> real pain.
>

As a matter of fact, in our multi persona phone, you *can* hear music played
from background persona, but you *cannot* see images drawn from background
persona.


> The more common concern is to have devices we can use all of the time.
>
> There may be a need for a device namespace and multiplexing access to
> hardware devices makes that clearer.  So far nothing has risen to the
> level of we actually need a device namespace to do X.  Especially in an
> erra of hotplug and dynamic device numbers.
>
> It is arguable that you could do your kind of device multiplexing with a
> fuse device in userspace that implements your desired policy.
>

I agree about it being arguable :-)
We shall present our arguments on LPC.


>
> And policy is where cell situtation seems to fall down because it hard
> codes one specific policy into the kernel, and a policy most situations
> don't find useful.
>
>
It's true that for our product, we have made hardcoded policy decisions in
our kernel
patches, but that was just as a proof of concept for the technique.

We do envision being able to dynamically assign a device to a specific devns
(e.g. block,loop) keep a device shared between multi devns (e.g. audio)
and in addition to that, being able to multiplex a device between multi
devns (e.g. framebuffer)



> Eric
>
