From: Peter Dolding <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Single process controlling all cgroups sounds like looking in
	right direction but wrong solution.
Date: Wed, 17 Jul 2013 08:06:50 +1000
Message-ID: <CANA3KFVeYkvidYu=1rV_We3JLH5QEsogCnYQEdA6VGBKD2sbYw__25798.7765515738$1374012424$gmane$org@mail.gmail.com>
References: <CANA3KFV6LmfKYUo305Fo2Yv_0kJGSSa7OjnGi8BMb+0Ys9e8NA@mail.gmail.com>
	<20130715032551.GA3046@ac100>
	<CANA3KFWdKbrpZDHHsqKeh-vugK7NjJ1xrFcXyYSRaKn0mUYewg@mail.gmail.com>
	<20130715123216.GA5663@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130715123216.GA5663@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, webmaster-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Serge You took it the wrong way I was not trying to be defensive.
That was my version of what the heck is wrong response.  Followed
policy and it wrong you kinda want to find out what is wrong.  Its if
something is out like this other people are going to go south.

So this is interesting there is a miss match between git and what the
website displays.   Fact that its old it the webmaster needs to be
informed so it can be fixed.      I have changed the who this is going
to.

Webmaster https://www.kernel.org/doc/linux/MAINTAINERS   and the
Maintainers file in git don't match.    Would suspect other sections
in doc directory are also out.

https://www.kernel.org/doc/linux/   Apparently this is one of the
things that broke when kernel.org was breached and has not been fixed
yet.   Nothing in that section of kernel.org appears to be updated
since the 19 Aug 2011.   Kernel.org breach was the 31 of Aug 2011.
So I would say the script or whatever was done to sync there has not
been operating because it was removed cleaning up from the breach.
If its never going to be operating sections there should be just
deleted so it does not lead people up garden path..

On Mon, Jul 15, 2013 at 10:32 PM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> Quoting Peter Dolding (oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
>> I followed the Maintainers File.  https://www.kernel.org/doc/linux/MAINTAINERS
>> CONTROL GROUPS (CGROUPS)
>> M:    Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>> M:    Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> L:    containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>
> Odd, my version has
>
> L:      containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> L:      cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>
> The cgroups entry was added in November 2011 according to git-blame.
> I don't know why the kernel.org version is so old.
>
> Still I think that should be patched to remove containers@.  I
> originally objected to the cgroup@ list creation, but since I
> do not believe the relevant cgroup folks read the containers@
> list any more, I don't think containers@ should be listed -
> certainly not first.
>
>> S:    Maintained
>> F:    include/linux/cgroup*
>> F:    kernel/cgroup*
>> F:    mm/*cgroup*
>>
>>
>> Apparently by your response this might be a bit out of date.  I just read
>> lwm and *Tejun Heo is not even as a main maintainer.  Listed as a sub part
>> maintainer.   By the maintainers file discussions should be in *
>> containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org where I sent this.
>>
>> Tejun Heo please inform if this is still correct.  Its either update this
>> or tell lwn.net to get your title correct in future.
>>
>> Serge I am trying to follow policy that is why I posted here in the first
>> place.
>
> That sounds unnecessarily defensive - I wasn't complaining, just trying
> to help your email get to where it would be best discussed  :)  Sorry
> that it involves an extra step (resending), but I didn't want to simply
> reply cc:ing cgroups@, as the email thread tends to get funky that way.
>
> -serge
