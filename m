From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH review 02/13] mnt: Refactor fs_fully_visible into
	mount_too_revealing
Date: Fri, 24 Jun 2016 01:56:31 -0500
Message-ID: <20160624065631.GA403__24740.6407529072$1466751417$gmane$org@mail.hallyn.com>
References: <87fus77pns.fsf@x220.int.ebiederm.org>
	<20160620172130.15712-1-ebiederm@xmission.com>
	<20160620172130.15712-2-ebiederm@xmission.com>
	<CALCETrXv2aeP38AmUaRVMC+O-oeWKwDcy8fPfsOCu1f8mncZEA@mail.gmail.com>
	<874m8m4bky.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <874m8m4bky.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jun 21, 2016 at 01:54:21PM -0500, Eric W. Biederman wrote:
> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
> 
> > On Mon, Jun 20, 2016 at 10:21 AM, Eric W. Biederman
> > <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> >> Replace the call of fs_fully_visible in do_new_mount from before the
> >> new superblock is allocated with a call of mount_too_revealing after
> >> the superblock is allocated.   This winds up being a much better location
> >> for maintainability of the code.
> >>
> >> The first change this enables is the replacement of FS_USERNS_VISIBLE
> >> with SB_I_USERNS_VISIBLE.  Moving the flag from struct filesystem_type
> >> to sb_iflags on the superblock.
> >
> > Why is this useful?
> 
> A couple of reasons.
> - It helps clean up do_new_mount which is currently so overloaded by
>   special cases that it is difficult to see the core logic.

Agreed, i find this easier to read and reason about.

> - It makes the check about the actual superblock that is being mounted
>   rather than the superblock that might be mounted.
> 
> - The practical place where being about the actual superblock that is
>   being mounted helps is that in "11/13 mnt: Simplify mount_too_revealing"
>   that removes the MNT_LOCK_NOSUID MNT_LOCK_NOEXEC and MNT_LOCK_NODEV
>   tests from the code, while verify that those tests are not needed
>   because the sb_iflags contains SB_I_NOEXEC and SB_I_NODEV.
> 
> - The conceptual change of testing once the superblock has been
>   generated makes changes like the one above much more sensible
>   and it helps untangle mount namespace versus superblock concerns.
> 
> That last is a big part of what this patchset is about.  When do we care
> about the superblock and when do we care about the mount namespace.
> 
> Eric
