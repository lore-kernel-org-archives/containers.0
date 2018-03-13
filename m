From: Christian Brauner <christian.brauner-cl+VPiYnx/1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 0/4 v5] devpts: handle bind-mounts correctly
Date: Tue, 13 Mar 2018 17:51:33 +0100
Message-ID: <20180313165133.GA17319@mailbox.org>
References: <20180313121713.32551-1-christian.brauner@ubuntu.com>
	<87y3iw0vz7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87y3iw0vz7.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Mar 13, 2018 at 11:41:00AM -0500, Eric W. Biederman wrote:
> Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Hey everyone,
> >
> > This is the fith iteration of this patch. Per-patch changes are
> > summarized in the individual patches:
> 
> Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> I guess we need to answer the question do I pick up this series or does
> gregkh.  This series would seem to fit in his tty tree.
> 
> You haven't copied gregkh so you may need to resend and do that.

I'll resend and CC grekh now.

Christian

> 
> Eric
> 
> 
> > ChangeLog v4->v5:
> > * added non-functional patch to document devpts_mntget().
> >   Reason for putting this in a separate patch is that it allows you,
> >   Linus and Eric, to simply drop it if judged useless.
> > * reverse error handling logic to further simplify
> > * dput() dentry in the non-function patch. This was not really a problem
> >   since the following patch included a fix for it. But better to get it
> >   right in all individual patches.
> > * I did another rewrite of the problem analysis for
> >   posterity in the patch "Subject: [PATCH 2/3 v3] devpts: resolve devpts
> >   bind-mounts" and in this cover letter.
> >
> > ChangeLog v3->v4:
> > * small logical simplifications
> > * add test that bind-mounts of /dev/pts/ptmx to locations that do not
> >   resolve to a valid slave pty path under the originating devpts mount
> >   fail
> >
> > ChangeLog v2->v3:
> > * rewritten commit message to thoroughly analyse the problem for
> >   posterity in the patch "Subject: [PATCH 2/3 v3] devpts: resolve devpts
> >   bind-mounts" and in this cover letter.
> > * extended selftests to test for correct handling of /dev/pts/ptmx
> >   bind-mounts to /dev/ptmx and non-standard devpts mounts such as
> >   mount -t devpts devpts /mnt
> >
> > ChangeLog v1->v2:
> > * see individual patches
> > ChangeLog v0->v1:
> > * see individual patches
> >
> > Christian Brauner (4):
> >   devpts: hoist out check for DEVPTS_SUPER_MAGIC
> >   devpts: resolve devpts bind-mounts
> >   devpts: comment devpts_mntget()
> >   selftests: add devpts selftests
> >
> >  fs/devpts/inode.c                                |  66 +++--
> >  tools/testing/selftests/Makefile                 |   1 +
> >  tools/testing/selftests/filesystems/.gitignore   |   1 +
> >  tools/testing/selftests/filesystems/Makefile     |   2 +-
> >  tools/testing/selftests/filesystems/devpts_pts.c | 313 +++++++++++++++++++++++
> >  5 files changed, 363 insertions(+), 20 deletions(-)
> >  create mode 100644 tools/testing/selftests/filesystems/devpts_pts.c
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
