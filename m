From: "Kyle Moffett" <kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org>
Subject: Re: [RFC][PATCH 0/6] Enable multiple mounts of devpts
Date: Tue, 5 Aug 2008 00:57:24 -0400
Message-ID: <f73f7ab80808042157k1b22ef89sfa4a9f2dc2603c50@mail.gmail.com>
References: <20080805011844.GA14940@us.ibm.com> <4897AECE.9060307@zytor.com>
	<20080805015334.GA16114@us.ibm.com> <4897B5DC.10502@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4897B5DC.10502-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Cc: "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Aug 4, 2008 at 10:07 PM, H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org> wrote:
> You're right, I think we can do this and still retain most of the
> advantages, at least for a transition period.
>
> The idea would be that you'd have a mount option, that if you do not specify
> it, you get a bind to the in-kernel mount; otherwise you get a new instance.
>  ptmx, if not invoked from inside a devpts filesystem, would default to the
> kernel-mounted instance.
>
> Unfortunately I believe that means parsing the command options in
> getpts_get_sb() to know if we do have the "multi" option, but that isn't
> really all that difficult; it just means breaking the parser out as a
> separate subroutine.

There definitely needs to be a mount option (and possibly a config
option to forcibly enable the mount option).  I personally have 5 or 6
different custom scripts that depend on being able to unmount and
remount devpts without losing access to the TTYs therein.  Eventually
I will need to port those over to use "mount --move", but it would be
bad to have a random kernel upgrade just break my imaging/cloning
system.

Cheers,
Kyle Moffett
