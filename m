From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Tue, 12 Aug 2014 21:38:49 -0700
Message-ID: <CALCETrUEfKKMZ=5mK3HzALaGsXdiUeSjtg_RwjD14CNoZ+R_jQ@mail.gmail.com>
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
Cc: Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Kenton Varda <kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Aug 12, 2014 at 9:17 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
>
>> On 08/05/2014 05:57 PM, Eric W. Biederman wrote:
>>
>> Sorry for catching this late.  I think this fix is likely to
>> unnecessarily break valid userspace due to an odd interaction.
>
> The code is correct and safe (no security issues), but yes a blind
> remount might hit a snag.
>
> If you can find a userspace application that matters I might care
> that a security fix breaks it.
>
> I think you have made a point that several more filesystems might
> be ok to not set nodev on (because we can not do anything to create
> device nodes on those filesystems).  I personally would prefer the much
> more paranoid approach of only allowing device nodes on a unprivileged
> mount if we have audited all of the code paths and know it is safe
> for device nodes to appear there.
>
> I don't actually think anyone cares ad remounts of filesystems like
> tmpfs, mqueue, sysfs, proc, ramfs are all quite rare.  Blind remounts
> are even rare.  The normal userspace utilities look at the appropriate
> version of /proc/mounts on remount.

Bind remounts are the only kind of remounts, because we've never
supported do_remount_sb in a user namespace.  So, if you want to
create some static content in your user namespace, the way to do it
is:

unshare(CLONE_NEWUSER | CLONE_NEWNS);
mount tmpfs somewhere;
write to the tmpfs;
mount("path to tmpfs", "path to tmpfs", nullptr, MS_REMOUNT | MS_BIND
| MS_RDONLY);

>
> These are not filesystems that a blind remount will likely be applied
> to.
>
> Furthermore there is work underway to prepare patches to allow
> "mount --bind -ro" to work as expected.  That will further reduce
> the pressure from blind remounts.

Not for example above.  It really does need the remount.

>
> If there is an actual regression of actual code I am happy to deal
> with it.  But having the MNT_NODEV on those mounts has been the case
> for a long time now and is not new (no regression).  This change just
> closed the security hole that allowed nodev to be removed.  And that
> security hole we need to have fixed.

Sandstorm does this.  (Well, it did until today.)

--Andy
