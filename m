From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Mount remount operations propagating from container to host
	and	other containers.
Date: Thu, 1 Apr 2010 09:50:54 -0500
Message-ID: <20100401145054.GE22648@us.ibm.com>
References: <1270129248.7564.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1270129248.7564.43.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Michael H. Warfield" <mhw-UGBql2FAF+1Wk0Htik3J/w@public.gmane.org>
Cc: containers-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Michael H. Warfield (mhw-UGBql2FAF+1Wk0Htik3J/w@public.gmane.org):
> Hey all,
> 
> Been running into an ugly situation with LXC-Tools that seems to be
> pointing up a real serious leakage from containers.  If you have a mount
> inside a container (presumably a bind mount in this case), if the
> container does a mount -o remount (say rw->ro or ro->rw) this propagates
> to the host mount points (all the way to the primary mount point for
> that partition in some cases) and is reflected in other containers.

I think you'll want to mount --make-rslave or --make-rprivate
during container setup.  Distros vary with how they leave /
set up, and if it is all rshared from the start, then yeah
your containers' mount actions will propagate backward.

> This first show up with containers running full VM's running on a
> mounted fs (aot the host / fs) were causing the real mounted fs to
> become ro when they were shut down (the VM was remounting its rootfs as
> ro and it was leaking out of the container).
> 
> I've since confirmed that and encountered it trying to have a shared ro
> mounted fs in a container using bind mounts (bind mounts since 2.6.26
> have allowed setting the ro flag on individual mount points) and
> discovering that one container could make it rw and then all the other
> containers would see it as rw as well!  If a container made a mount
> point ro, all the other containers would see it as ro and the mount
> point for the entire real fs in the host would become ro!  This is very
> not good.  That's a pretty serious leakage from the containers out to
> the host.
> 
> Is this a problem with the container isolation or some problem in
> creating the container?
> 
> I'm running and testing on a Fedora 12 system with a 2.6.32 kernel.  Not
> related (I don't think) but I have also noted that linux-utils-ng on F16
> seems to also have a bug irt something similar here.  If I mount a
> directory from a mounted partition onto another location and then make
> that other location ro, the entire partition becomes ro.  BUT!  If I
> then make the partition rw, that does not propagate back up and the bind
> mount remains ro.
> 
> What should work is this:
> 
> Partition /export
> Directory /export/readonly
> 
> mount --bind /export/readonly /srv/readonly
> 
> At this point, /export and /srv/readonly are both rw
> 
> mount -o remount,ro /srv/readonly
> 
> Now. both /export and /srv/readonly are ro!  This is wrong.
> Only /srv/readonly is suppose to be ro!
> 
> Now, running...
> 
> mount -o remount,rw /export
> 
> now, /export is rw and /srv/readonly is readonly.
> 
> Back to containers...
> 
> If I have /srv/readonly mounted in several containers (same mount point)
> it's ro in the host and in the containers...
> 
> Running this in one container:
> 
> mount -o remount,rw /srv/readonly
> 
> (I seriously wish this would NOT WORK AT ALL, but it does.  I don't want
> the container to be able to write to that partition at all, like the
> media was RO.  Anybody have any ideas on that one?)
> 
> Now /srv/readonly is rw in the host and all the containers!
> 
> (EVEN WORSE!)
> 
> Running this in one container:
> 
> mount -o remount,ro /srv/readonly
> 
> NOW /srv/readonly is ro in all the containers and /export is ro in the
> host.  NOT GOOD.
> 
> Thoughts?
> 
> Regards,
> Mike
> -- 
> Michael H. Warfield (AI4NB) | (770) 985-6132 |  mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org
>    /\/\|=mhw=|\/\/          | (678) 463-0932 |  http://www.wittsend.com/mhw/
>    NIC whois: MHW9          | An optimist believes we live in the best of all
>  PGP Key: 0x674627FF        | possible worlds.  A pessimist is sure of it!



> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
