From: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 03/11] fs: Allow superblock owner to change ownership of
	inodes
Date: Tue, 13 Feb 2018 14:18:21 +0100
Message-ID: <CAOssrKcZeAHsRz7P_dxh==QAKnp7HeSTh4vWY2tgbWa1ZD918g__41193.6576165774$1518527821$gmane$org@mail.gmail.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<ac3d34002d7690f6ca5928b57b7fc4d707104b04.1512041070.git.dongsu@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ac3d34002d7690f6ca5928b57b7fc4d707104b04.1512041070.git.dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 22, 2017 at 3:32 PM, Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org> wrote:
> From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>
> Allow users with CAP_SYS_CHOWN over the superblock of a filesystem to
> chown files.  Ordinarily the capable_wrt_inode_uidgid check is
> sufficient to allow access to files but when the underlying filesystem
> has uids or gids that don't map to the current user namespace it is
> not enough, so the chown permission checks need to be extended to
> allow this case.
>
> Calling chown on filesystem nodes whose uid or gid don't map is
> necessary if those nodes are going to be modified as writing back
> inodes which contain uids or gids that don't map is likely to cause
> filesystem corruption of the uid or gid fields.

How can the filesystem be corrupted if chown is denied?

It is not clear to me what the purpose of this patch is or what the
exact usecase this is fixing.

Thanks,
Miklos
