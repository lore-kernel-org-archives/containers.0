From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: [REGRESSION v4.16-rc6] [PATCH] mqueue: forbid unprivileged user
	access to internal mount
Date: Fri, 23 Mar 2018 17:04:57 +1100
Message-ID: <20180323060457.sxgsd3j2obi33fyw@gordon>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5120055141587333277=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============5120055141587333277==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="mkwhpp2yu2pyrkbn"
Content-Disposition: inline


--mkwhpp2yu2pyrkbn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Felix reported weird behaviour on 4.16.0-rc6 with regards to mqueue[1],
which was introduced by 36735a6a2b5e ("mqueue: switch to on-demand
creation of internal mount").

Basically, the reproducer boils down to being able to mount mqueue if
you create a new user namespace, even if you don't unshare the IPC
namespace.

Previously this was not possible, and you would get an -EPERM. The mount
is the *host* mqueue mount, which is being cached and just returned from
mqueue_mount(). To be honest, I'm not sure if this is safe or not (or if
it was intentional -- since I'm not familiar with mqueue).

To me it looks like there is a missing permission check. I've included a
patch below that I've compile-tested, and should block the above case.
Can someone please tell me if I'm missing something? Is this actually
safe?

[1]: https://github.com/docker/docker/issues/36674

--8<--------------------------------------------------------------------

Fix a regression caused by 36735a6a2b5e ("mqueue: switch to on-demand
creation of internal mount"), where an unprivileged user is permitted to
mount mqueue even if they don't have CAP_SYS_ADMIN in the ipcns's
associated userns. This can be reproduced as in the following.

  % unshare -Urm                       # ipc isn't unshare'd
  # mount -t mqueue mqueue /dev/mqueue # should have failed
  # echo $?
  0

Previously the above would error out with an -EPERM, as the mount was
protected by mount_ns(), but the patch in question switched to
kern_mount_data() which doesn't do this necessary permission check. So
add it explicitly to mq_internal_mount().

Fixes: 36735a6a2b5e ("mqueue: switch to on-demand creation of internal moun=
t")
Reported-by: Felix Abecassis <fabecassis-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
---
 ipc/mqueue.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index d7f309f74dec..ddb85091398d 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -353,6 +353,12 @@ static struct vfsmount *mq_internal_mount(void)
 {
 	struct ipc_namespace *ns =3D current->nsproxy->ipc_ns;
 	struct vfsmount *m =3D ns->mq_mnt;
+	/*
+	 * Match the semantics of mount_ns, to avoid unprivileged users from being
+	 * able to mount mqueue from an IPC namespace they don't have ownership o=
f.
+	 */
+	if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN))
+		return ERR_PTR(-EPERM);
 	if (m)
 		return m;
 	m =3D kern_mount_data(&mqueue_fs_type, ns);
--=20
2.16.2

--=20
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
<https://www.cyphar.com/>

--mkwhpp2yu2pyrkbn
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEXzbGxhtUYBJKdfWmnhiqJn3bjbQFAlq0mQgACgkQnhiqJn3b
jbSX+g//csB1W7Uq8uwJeJsbdF4DwmoAW6wqS0ur2OZKuY5nDlgPXLMEpPc+4L/J
LEspc1mhN7U2SEypffN0fpAdf9SDANX5lKbKn93L1oJS59Ap0vjVtkRv2pBOuqDv
24mDkUsZGhtEqump4AkCkoJivQRzpHseXpgs5WfDGZJXEKCapkTS3ozfCbrmJRrL
1npE/vPcWT/tpxXBo8pFdvcFZ08EhqQ1tRINNdHXF5ii8rmAxT/RTEN33e461G4+
QUNZbJCHhrQKyJDOD9vychOMQUbFlI/WUVm7WvUo8RzS5r7TuDw3DDlHoiO0zbhR
Ns/9ZAO9MCA2o15rcXzI5kZUS7ZJL3FHr3lLTS8JOTCZCdIDkjJoIEtvbAg/7TAH
S6n7r+qJffKwCjC93VKiOZ9CxsmdMGaUX3J6vYvU07o6CIiD6oL6/Q07weE2RRUV
31P/YOdKf9EYxU9SqBtPQJxeeKKDvIbebwv/iLLu4quuIJIbybe9i4cDuu15Yrj3
eh735RAl8vtKc0Em1SushCT9NaTBe4qXQSw9I4jJWgaLL9b49lbqFdHlaMyl7uQe
BgK81ykG/V3qXRm+0L57Oj1AglqBTYJwgUrG8C0eGQstz+XN3ir9AqpSWXtZl6m9
ZNEm4UHc3BnroM5TaLWRt/OWjmfB7m5sDSrBCXsCfBFrswe9fxQ=
=5QhP
-----END PGP SIGNATURE-----

--mkwhpp2yu2pyrkbn--

--===============5120055141587333277==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============5120055141587333277==--
