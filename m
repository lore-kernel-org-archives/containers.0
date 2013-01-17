From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] user_ns: Add support for unprivileged remount
Date: Thu, 17 Jan 2013 15:17:46 +0800
Message-ID: <50F7A59A.1080601@cn.fujitsu.com>
References: <50519CB2.7040801@gmail.com> <87fw6lfwc3.fsf@xmission.com>
	<5052F783.3040904@gmail.com> <877grxdk48.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060902080505070302040304"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <877grxdk48.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


--------------060902080505070302040304
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 2012/09/14 17:33, Eric W. Biederman wrote:
> Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>=20
>> On 2012-9-14 5:26, Eric W. Biederman wrote:
>>> Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>>
>>>> From: Zhao Hongjiang <zhaohongjiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>>>
>>>> Relax the permission checks to allow unprivileged users that have
>>>> CAP=5FSYS=5FADMIN permissions in the user namespace referred to by the
>>>> current mount namespace to be allowed to remount filesystems.
>>>
>>> Remount in general make filesystem configuration changes not mount level
>>> changes.
>>>
>>> In general remount is not safe for unprivielged users.
>>>
>>> Do you have a use case where you need to remount a filesystem?
>>
>> As we can do a umount+mount=EF=BC=8CI don't see why remount operation is=
 not allowed.
>> Shouldn't we add checks in remount path in the specific filesystem to en=
sure
>> safety instead when we enable unprivilleged mount?
>=20
> But the thing is remount !=3D mount+umount.  Remount is change lowlevel
> filesystem options.
>=20
> The basic danger is if someone in the primary user namespace mounted a
> filesystem, and then we cloned that filesystem.
>=20
> umounting filesystems is ok.  There reference count will drop or they
> will just unmount if the ref count goes to zero.
>=20
> However mount -o remount -r /home could very easily remount everyone's
> home directory in all mount namespaces read-only by making the
> filesystem itself readonly.
>=20
> That danger applies even to some extent even if the options are safe for
> us to perform at the filesystem level.
>=20
> Now that doesn't mean remount is a hopeless operation.  What it does
> mean is that we need to be very carefully with enabling remounting
> of a filesystem.
>=20
Hi Eric

what's you idea about the patch below.
Maybe it better to add a new fs=5Fflags FS=5FUSERNS=5FREMOUNT?
It's not a good experience that remount is disabled in container.

Thanks!
=

--------------060902080505070302040304
Content-Transfer-Encoding: 7bit
Content-Type: text/x-patch;
 name="0001-userns-allow-remount-filesystem-in-un-init-userns.patch"
Content-Disposition: attachment;
 filename*0="0001-userns-allow-remount-filesystem-in-un-init-userns.patch"

From 8c5a01c007d72c748018665d3bd27cd2bde52c0f Mon Sep 17 00:00:00 2001
From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date: Thu, 17 Jan 2013 14:41:00 +0800
Subject: [PATCH] userns: allow remount filesystem in un-init userns

The proc and sysfs filesystem already enable userns support,
remounting these filesystems in un-init userns do no harm
to the host.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/namespace.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 55605c5..b9d83fb 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1748,7 +1748,10 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 	struct super_block *sb = path->mnt->mnt_sb;
 	struct mount *mnt = real_mount(path->mnt);
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (sb->s_type->fs_flags & FS_USERNS_MOUNT) {
+		if (!ns_capable(mnt->mnt_ns->user_ns, CAP_SYS_ADMIN))
+			return -EPERM;
+	} else if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
 	if (!check_mnt(mnt))
-- 
1.7.11.7


--------------060902080505070302040304
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--------------060902080505070302040304--
