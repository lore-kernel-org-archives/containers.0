From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Q: general lxc architecture
Date: Tue, 10 Nov 2009 11:35:48 +0100
Message-ID: <4AF94204.3090805@free.fr>
References: <4AF90856.2070904@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AF90856.2070904-Gdu+ltImwkhes2APU0mLOQ@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LXC Development <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Michael Tokarev wrote:
> Hello.  This is my first post here.
>
> I'm trying lxc, and while it (sorta) works, I've several questions,
> one of which is about general architecture of the userspace toolset.
>
> The question is -- what's the reasoning behind the usage of /var/lib/lxc
> and two sets of configuration.
>
> /var/lib/lxc is - in my opinion - a bad mix of things that should be
> either in /etc/lxc/ or in /var/run/[lxc/].  /var/lib/lxc contains both
> the persistent configuration (which should go to /etc), and runtime-only
> things (like PID of init, ifindex of interfaces and the like, and especially
> the "state" file -- all that should be cleared on reboot), for which the
> proper place is /var/run.  I may think of a way to keep it all in one place,
> but it's not how things are usually done in linux.
>
> And another question is about configuration part of containers.  Right
> now there are two sets of configuration, one is the file "config" in the
> container "home directory", and another is the same config which is split
> out into pieces in various subdirectories.  Why not keep the original
> config only, why the split is needed?
>
> Related, how to alter configuration once the container is created?  It looks
> like I have to tweak the split-out configuration _and_ the top-level
> "config" file, right?
>
> But the whole /var/lib/lxc thing looks - to me anyway - so wrong that the
> right thing to me is to mount a tmpfs over there on boot, keep whole
> configuration in /etc/lxc/$name.conf, lxc-create a container from there
> on boot (in the tmpfs mounted at /var/lib/lxc !) and run it the usual
> way.  Also quite ugly but this at least lets one to keep things in
> traditional places.
>   
Hi Michael,

(cc'ed lxc-devel@)

Your analysis is correct :)
This is something we are enhancing.  The different files in 
/var/lib/lxc/*  were removed and only the config file is stored now.

You can check the repository:
http://lxc.git.sourceforge.net/git/gitweb.cgi?p=lxc/lxc;a=shortlog


> And one more question.  Why /var/lib/lxc/$name/state file is needed?  Can
> the same be done in a slightly different way, like, for example, checking
> the presence of /dev/cgroup/$name directory (or where the cgroup mountpoint
> is)?  What I'm trying to say here is that the "state" file may not reflect
> reality while kernel knows reality for sure...
>   
Runtime information is no longer stored on the disk.

> I think I misunderstand something very important here.  I know that
> linux-vserver project used quite similar scheme (but without the top-level
> "config" file, so that whole configuration was in single place), but I don't
> understand lxc the same way as I didn't understand linux-vserver, and lxc
> looks even uglier to me... ;)
>   
Uglier than tomorrow, better than yesterday :)

Thanks
  -- Daniel
