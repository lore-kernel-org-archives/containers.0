From: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Subject: Re: [REVIEW][PATCH 0/6] Wrapping up the vfs support for unprivileged
	mounts
Date: Tue, 29 May 2018 17:40:50 +0200
Message-ID: <CANxcAMt5f7=TV3Yqc6iavos=saGFOPKC4R4Yr9yGbKoVwq3YGw__11575.3014492386$1527608353$gmane$org@mail.gmail.com>
References: <87o9h6554f.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87o9h6554f.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

On Thu, May 24, 2018 at 1:22 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> Very slowly the work has been progressing to ensure the vfs has the
> necessary support for mounting filesystems without privilege.
>
> This patchset contains one more core piece of that work, ensuring a few
> more operations that would write back an inode and confuse an exisiting
> filesystem are denied.
>
> The rest of the changes actually enable userns root to do things with
> filesystems that the userns root has mounted.  Most of these have been
> waiting in the wings a long time, held back because I wanted the core
> of the patchset to be solid before I started allowing additional
> behavor.
>
> It is definitely time for these changes so the effect of s_user_ns
> becomes less theoretical.
>
> The change to allow mknod is new, but consistent with everything else
> and harmless as device nodes on filesystems mounted without privilege
> are ignored.
>
> Unless problems show up in the during review I plan to merge these changes.

Thank you for the great work. I have been looking forward to seeing it.
I have just gathered available relevant patches in my branch:

https://github.com/kinvolk/linux/tree/dongsu/fuse-userns-for-4.18

With this branch, I tested sshfs/fuse from non-init user namespace.
It works fine as expected. So you can add:

Tested-by: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>

Thanks!
Dongsu

> These changes are also available at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git userns-test
>
> Eric W. Biederman (5):
>       vfs: Don't allow changing the link count of an inode with an invalid uid or gid
>       vfs: Allow userns root to call mknod on owned filesystems.
>       fs: Allow superblock owner to replace invalid owners of inodes
>       fs: Allow superblock owner to access do_remount_sb()
>       capabilities: Allow privileged user in s_user_ns to set security.* xattrs
>
> Seth Forshee (1):
>       fs: Allow CAP_SYS_ADMIN in s_user_ns to freeze and thaw filesystems
>
>  fs/attr.c            | 36 ++++++++++++++++++++++++++++--------
>  fs/ioctl.c           |  4 ++--
>  fs/namei.c           | 16 ++++++++++++----
>  fs/namespace.c       |  4 ++--
>  security/commoncap.c |  8 ++++++--
>  5 files changed, 50 insertions(+), 18 deletions(-)
>
> Eric
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
