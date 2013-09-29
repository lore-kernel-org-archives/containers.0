From: Amir Goldstein <amir-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [lxc-devel] RFC: Device Namespaces
Date: Sun, 29 Sep 2013 20:56:58 +0300
Message-ID: <CAA2m6vc8YiodZW-HN43xHqpKia1Te+-wSO09ghSC4rd=gqJ=rg@mail.gmail.com>
References: <CAA4jN2aw4zEW=UfKCyqaOvXnbiRb_J9srfCn4OXTFzc6vWBM4A@mail.gmail.com>
	<20130822182118.GA28331@sergelap>
	<CAA4jN2YL7Lfu2+DW-i+MovFxWEhJfT4aBBKREU_vy7JX9TKGHA@mail.gmail.com>
	<8761udlu0d.fsf@xmission.com>
	<CAA2m6vexArJ+6jFbK80Amstk=LK30=XDNHdBHSswP=LgpSP-6A@mail.gmail.com>
	<871u4yddg4.fsf@xmission.com>
	<CAA2m6vc_kWWGDWcdjk26N3YvTqZySLFxPQRjOD9_ypBOka2+GQ@mail.gmail.com>
	<CAE=NcrbyFFoMn2nfBA_=ZtwD=eGLvqK=L-U9MuGrtJFLZfZppw@mail.gmail.com>
	<87ioxo4pm5.fsf@xmission.com>
	<AD5F7BD2-0166-46BD-AB14-463C0E88BC92@cs.columbia.edu>
	<8738osr2ue.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8738osr2ue.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Sep 26, 2013 at 12:47 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>wrote:

> Jeremy Andrus <jeremya-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
>
> > On Sep 25, 2013, at 4:23 PM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> wrote:
> >
> >> Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> >>
> >>> That being said, is there a valid reason why binder is part of device
> >>> namespace here instead of IPC?
> >>
> >> I think the practical issue with binder was simply that binder only
> >> allows for a single instance and thus is does not play nicely with
> >> containers.
> >
> > It's true that there was a singleton paradigm in binder that had to be
> > overcome, but I agree with Janne. It really belongs in the IPC namespace,
> > and I don't see any technical reason not to move it there.
>
> *Blink* I missed the IPC namespace suggestion.
>
> The IPC namespace sounds reasonable.
>

Binder rewrite for IPC namespace is in the works (by Oren)
We discussed this with Greg and adding namespace support to binder (in
staging) seemed reasonable to him as well.


> Of course binder is still in staging because it has implementation and
> ABI problems.  Little things like a 64bit kernel and a 32bit userspace
> don't work particularly well.  So while fixing those problems it might
> be possible to fix the single container problem as well.  It would be a
> weird direction for cleanup of binder to come from but I don't see why
> that wouldn't work.
>
> Personally until binder is out of staging it seems reasonable to push
> for an API that sucks less, or for a more general solution that Androdid
> could use instead of binder.
>
> One of the uses of namespaces is to clean up after problematic kernel
> design decisions.  If we still have the option I would rather fix the
> problems than clean up after them.
>
> Eric
>
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
>
