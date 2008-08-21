From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 7/8]: Auto-create ptmx node when mounting devpts
Date: Thu, 21 Aug 2008 16:00:40 -0500
Message-ID: <20080821210040.GA14532@us.ibm.com>
References: <20080821022126.GA29449@us.ibm.com>
	<20080821022908.GG29658@us.ibm.com>
	<20080821102139.43c44f67@lxorguk.ukuu.org.uk>
	<48AD932F.8090908@zytor.com>
	<20080821172700.781b0011@lxorguk.ukuu.org.uk>
	<48AD9C93.6080302@zytor.com> <20080821172342.GA8059@us.ibm.com>
	<48ADA890.4060309@zytor.com> <20080821181133.GB8059@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080821181133.GB8059-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> H. Peter Anvin [hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org] wrote:
> > sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> >> I had the new ptmx node only in 'multi-mount' mode initially. But if users
> >> want the multi-mount semantics, /dev/ptmx must be a symlink. If its a 
> >> symlink,
> >> we break in the single-mount case (which does not have the ptmx node and
> >> we don't support mknod in pts).
> >
> > True, but changing that is still a configuration change (adding newns to 
> > the fstab); it's not that much more work to change whatever else needs to 
> > change.
> 
> Hmm, so, single and multi-mount don't coexist ? i.e some are multi-mounts
> while others are single-mounts.
> 
> The way I looked at is that even if a distro has not yet updated the
> startup script (fstab), we could use the multi-mount. Maybe a container
> startup script could change /dev/ptmx to symlink and both types of
> mounts can work simultaneously.

Suka, I think you are missing Eric's point.

You're imagining there is a problem because you can't have a file inthe
same /dev be both a device node and a symlink.

Eric is pointing out that you don't need a symlink, because the device
node can be a target for a bind mount.  So you can do

	mknod /dev/ptmx c 5 2
	clone(CLONE_NEWNS)
	mount --bind /dev/pts/ptmx /dev/ptmx

with no problems in either namespace.

> Would that be unnecessary ?
> 
> >
> > I personally don't expect a whole lot of back-and-forth; I suspect people 
> > will switch from the legacy model to the newns model mostly as part of a 
> > distro upgrade.
> >
> >>>> I'm open to being convinced and the
> >>>> other problems with that code are more pressing.
> >> Yes, I will look at the latest in linux-next and the ->driver_data
> >> approach.
> >> But just to confirm, we do want try and keep single-mount semantics.
> >
> > Certainly for several years at least.
> 
> Ok.
> 
> >
> > 	-hpa
