From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Single process controlling all cgroups sounds like looking in
	right direction but wrong solution.
Date: Mon, 15 Jul 2013 07:32:16 -0500
Message-ID: <20130715123216.GA5663@sergelap>
References: <CANA3KFV6LmfKYUo305Fo2Yv_0kJGSSa7OjnGi8BMb+0Ys9e8NA@mail.gmail.com>
	<20130715032551.GA3046@ac100>
	<CANA3KFWdKbrpZDHHsqKeh-vugK7NjJ1xrFcXyYSRaKn0mUYewg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CANA3KFWdKbrpZDHHsqKeh-vugK7NjJ1xrFcXyYSRaKn0mUYewg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Dolding <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Peter Dolding (oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> I followed the Maintainers File.  https://www.kernel.org/doc/linux/MAINTAINERS
> CONTROL GROUPS (CGROUPS)
> M:	Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> M:	Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> L:	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org

Odd, my version has

L:      containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
L:      cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

The cgroups entry was added in November 2011 according to git-blame.
I don't know why the kernel.org version is so old.

Still I think that should be patched to remove containers@.  I
originally objected to the cgroup@ list creation, but since I
do not believe the relevant cgroup folks read the containers@
list any more, I don't think containers@ should be listed -
certainly not first.

> S:	Maintained
> F:	include/linux/cgroup*
> F:	kernel/cgroup*
> F:	mm/*cgroup*
> 
> 
> Apparently by your response this might be a bit out of date.  I just read
> lwm and *Tejun Heo is not even as a main maintainer.  Listed as a sub part
> maintainer.   By the maintainers file discussions should be in *
> containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org where I sent this.
> 
> Tejun Heo please inform if this is still correct.  Its either update this
> or tell lwn.net to get your title correct in future.
> 
> Serge I am trying to follow policy that is why I posted here in the first
> place.

That sounds unnecessarily defensive - I wasn't complaining, just trying
to help your email get to where it would be best discussed  :)  Sorry
that it involves an extra step (resending), but I didn't want to simply
reply cc:ing cgroups@, as the email thread tends to get funky that way.

-serge
