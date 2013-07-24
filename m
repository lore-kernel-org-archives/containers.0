From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [REVIEW][PATCH] vfs: Lock in place mounts from more privileged
	users
Date: Tue, 23 Jul 2013 18:15:03 -0700
Message-ID: <CALCETrXXGhVbkG6AnRck+W1kMns5TJuNYAqe_tV44JvWgDoUzA@mail.gmail.com>
References: <877gghruwq.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <877gghruwq.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 23, 2013 at 11:30 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> When creating a less privileged mount namespace or propogating mounts
> from a more privileged to a less privileged mount namespace lock the
> submounts so they may not be unmounted individually in the child mount
> namespace revealing what is under them.

I would propose a different rule: if vfsmount b is mounted on vfsmount
a, then to unmount b, you must be ns_capable(CAP_SYS_MOUNT) on either
a's namespace or b's namespace.  The idea is that you should be able
to see under a mount if you own the parent (because it's yours) or if
you own the child (because you, or someone no more privileged than
you, put it there).  This may result in a simpler patch and should do
much the same thing.

>
> This enforces the reasonable expectation that it is not possible to
> see under a mount point.  Most of the time mounts are on empty
> directories and revealing that does not matter, however I have seen an
> occassionaly sloppy configuration where there were interesting things
> concealed under a mount point that probably should not be revealed.
>
> Expirable submounts are not locked because they will eventually
> unmount automatically so whatever is under them already needs
> to be safe for unprivileged users to access.
>
> From a practical standpoint these restrictions do not appear to be
> significant for unprivileged users of the mount namespace.  Recursive
> bind mounts and pivot_root continues to work, and mounts that are
> created in a mount namespace may be unmounted there.  All of which
> means that the common idiom of keeping a directory of interesting
> files and using pivot_root to throw everything else away continues to
> work just fine.

Is there some kind of recursive unmount that will get rid of the
pivot_root result and everything under it?

In any case, I think that something like this patch is probably
-stable material: I suspect that things like seunshare and systemd's
instance directories are currently insecure.

--Andy
