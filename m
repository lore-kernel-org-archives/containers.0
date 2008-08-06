From: "Kyle Moffett" <kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org>
Subject: Re: [RFC][PATCH 0/6] Enable multiple mounts of devpts
Date: Tue, 5 Aug 2008 23:32:33 -0400
Message-ID: <f73f7ab80808052032h483cd746i644e629fafe176b4@mail.gmail.com>
References: <20080805011844.GA14940@us.ibm.com> <4897AECE.9060307@zytor.com>
	<20080805015334.GA16114@us.ibm.com> <4897B5DC.10502@zytor.com>
	<f73f7ab80808042157k1b22ef89sfa4a9f2dc2603c50@mail.gmail.com>
	<m17iawm1h9.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m17iawm1h9.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
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
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 5, 2008 at 2:15 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
>> There definitely needs to be a mount option (and possibly a config
>> option to forcibly enable the mount option).  I personally have 5 or 6
>> different custom scripts that depend on being able to unmount and
>> remount devpts without losing access to the TTYs therein.  Eventually
>> I will need to port those over to use "mount --move", but it would be
>> bad to have a random kernel upgrade just break my imaging/cloning
>> system.
>
> An interesting point.  What should the semantics be.  If we unmount /dev/pts
> and people still have ptys open.  -EBUSY?  Except for lazy unmounts?

Well, even if it's unmounted you can still access your pty with
/dev/tty.  As it stands right now it's possible to "umount /dev/pts"
from an SSH login and still have a mostly-functional system.  The only
failure will be when somebody needs a pseudo-TTY and you have devpts
unmounted and UNIX98 ptys turned off.

So for the legacy case, the behavior should be exactly as it is now.
In the CONFIG_DEVPTY_FORCE_PERMOUNT/"permount"-option case, I agree
that you could easily go either way.

Cheers,
Kyle Moffett
