From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH 7/8]: Auto-create ptmx node when mounting devpts
Date: Thu, 21 Aug 2008 10:40:32 -0700
Message-ID: <48ADA890.4060309@zytor.com>
References: <20080821022126.GA29449@us.ibm.com>
	<20080821022908.GG29658@us.ibm.com>
	<20080821102139.43c44f67@lxorguk.ukuu.org.uk>
	<48AD932F.8090908@zytor.com>
	<20080821172700.781b0011@lxorguk.ukuu.org.uk>
	<48AD9C93.6080302@zytor.com> <20080821172342.GA8059@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080821172342.GA8059-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> 
> I had the new ptmx node only in 'multi-mount' mode initially. But if users
> want the multi-mount semantics, /dev/ptmx must be a symlink. If its a symlink,
> we break in the single-mount case (which does not have the ptmx node and
> we don't support mknod in pts).
> 

True, but changing that is still a configuration change (adding newns to 
the fstab); it's not that much more work to change whatever else needs 
to change.

I personally don't expect a whole lot of back-and-forth; I suspect 
people will switch from the legacy model to the newns model mostly as 
part of a distro upgrade.

>>> I'm open to being convinced and the
>>> other problems with that code are more pressing.
> 
> Yes, I will look at the latest in linux-next and the ->driver_data
> approach.
> 
> But just to confirm, we do want try and keep single-mount semantics.

Certainly for several years at least.

	-hpa
