From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: mounts & namespaces
Date: Wed, 18 Nov 2009 10:20:22 -0600
Message-ID: <20091118162022.GD23694@us.ibm.com>
References: <4B03C2FF.5080004@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B03C2FF.5080004-Gdu+ltImwkhes2APU0mLOQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Michael Tokarev (mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org):
> Hello.
> 
> I asked similar question on lxc-devel@ but got no reply.  Since
> the issue is in kernel entirely, I'm asking in containers@ now.
> 
> As a base, I used lxc utils.
> 
> First of all, I'm concerned about file namespace security in a
> container.  It is, basically, just a chroot(2), or at least it
> looks like that to me.  But as we know, root can break out of
> chroot.  Are there any protection methods that prevents this
> break-out?

Not that I know of.  I haven't looked at the relevant source in
lxc/ in awhile, and haven't tested, but you should easily be
able to verify by finding the chroot escape code and running it
from inside a container...

Of course you can use Smack or SELinux (or probably even and
Apparmor profile) to prevent it.

> I see lxc-start performs one additional rbind-mount - whole root
> filesystem of a container to a temporary directory (mktemp), and
> uses that temp dir as root for the container.  I wonder what it
> is trying to achieve this way.  Is it related to the first
> question and prevents breaking out of chroot somehow?
> 
> On a similar note, can pivot_root be used there instead of a chroot?
> But see below for this one.

That is what libvirt does, for that very reason.  However, that
can make startup a bit more fragile, due to requirements in
sys_pivot_root that mounts involved not be shared.  It can be
worked around, but it starts to feel kludgy.  In particular,
libvirt-lxc broke briefly because fedora was marking / as
MS_SHARED, while we were expecting / to be private (which is
the usual case).

So for the moment, I personally was quite happy that libvirt
and lxc were were each taking different approaches  :)

> Inside a container, /proc/mounts is a complete mess, since most
> paths are not accessible (out of chroot).  When using real
> /etc/mtab things become much nicer, but mtab has been made a
> link to /proc/mounts for a purpose.
> 
> So I wonder if we can clean that stuff up for real.  I mean, not
> /proc/mounts by itself but the namespace.  For that, using
> pivot_root instead of a chroot to keep other filesystems
> available directly, and umount all of them which are not
> useful.  I understand it is not always possible (you can't
> umount /oldroot/usr as long as /oldroot/usr/containerroot
> is bind-mounted to /), but I think it's worth to try, at
> least in cases where it is doable (maybe not for general
> utils but in custom use-case).
> 
> But before trying, I want to understand the security
> implicatins and the whole root barrier thing if any --
> see my first question.
> 
> Thanks!
> 
> /mjt
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
