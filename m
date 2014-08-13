From: Kenton Varda <kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org>
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Tue, 12 Aug 2014 21:45:06 -0700
Message-ID: <CAOP=4widH1rMZ1O=hzAT+M_8exdzRPA8pJ+wH29AQ9L0ogu9nw@mail.gmail.com>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>
	<53EAD180.4010906@amacapital.net>
	<87sil1nhut.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87sil1nhut.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Aug 12, 2014 at 9:17 PM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
wrote:

> If you can find a userspace application that matters I might care
> that a security fix breaks it.
>

FWIW, it broke Sandstorm.io, but we already pushed a fix, and I'm not sure
if you'd say that we "matter".


> If there is an actual regression of actual code I am happy to deal
> with it.  But having the MNT_NODEV on those mounts has been the case
> for a long time now and is not new (no regression).  This change just
> closed the security hole that allowed nodev to be removed.  And that
> security hole we need to have fixed.
>

The problem is that users like us had no idea that nodev was being silently
added in the first place, and thus didn't know that we needed to specify it
in remounts. We create the tmpfs, put some things in it, and then want to
remount it read-only for the sandbox. It seems reasonable to expect that a
newly-created tmpfs would have exactly the flags I gave it when I created
it, not silently get an additional flag that I then need to pass on remount.

Note further that it may be very hard for normal developers to figure out
why their remount is failing in this case. Andy only discovered the silent
nodev by reading the kernel code.

-Kenton
