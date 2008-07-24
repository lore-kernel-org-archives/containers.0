From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: C/R minisummit notes
Date: Thu, 24 Jul 2008 02:58:54 -0700
Message-ID: <m1r69ja9i9.fsf@frodo.ebiederm.org>
References: <4887163F.5090801@fr.ibm.com> <20080723211818.GA10295@us.ibm.com>
	<4887A4CC.5070009@cs.columbia.edu>
	<20080724014122.GA23105@us.ibm.com>
	<20080724032616.GB9839@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080724032616.GB9839-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Wed, 23 Jul 2008 22:26:16 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> No no, the idea (IIUC) is that if you want to do a very short-downtime
> migrate, you stay in step 1 for a long time, writing the container
> memory to disk, checking how different the disk img is from the memory
> image, updating the version on disk, checking again, etc.  Then when
> you decide that the disk and memory are very close together, you
> quickly do steps 2-4, where 4 in this case is kill.  In the meantime
> you would have been loading the disk data into memory ahead of time
> at the new machine, so you can also quickly complete the restart.
>
> So 3, 'Dump', in this case really becomes "dump the metadata and any
> more changes that have happened."  Presumably, if when you get to 3,
> you find that there was suddenly a lot of activity and there is too
> much data to write quickly, you bail on the migrate and step 4 is
> a resume rather than kill.  Then you start again at step 1.
>
> At least that was my understanding.

Yes.  Too some extent you need those steps separate in the kernel so you can
coordinate with filesystem snapshots and the like.

Despite being in one large syscall we still have a few small other pieces
of userspace we need to coordinate with.

Eric
