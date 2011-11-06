From: "Andrew G. Morgan" <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/6] user namespace: clamp down users of cap_raised
Date: Sat, 5 Nov 2011 18:14:22 -0700
Message-ID: <CALQRfL45djx3ZawUOFNZRpbTBOqJiCAMkQodZwu1Lzp15Zhw4A@mail.gmail.com>
References: <1320445482-8459-1-git-send-email-serge@hallyn.com>
	<1320445482-8459-4-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1320445482-8459-4-git-send-email-serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: richard-/L3Ra7n9ekc@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Acked-by: Andrew G. Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Cheers

Andrew

On Fri, Nov 4, 2011 at 3:24 PM, Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>
> A few modules are using cap_raised(current_cap(), cap) to authorize
> actions. =A0This means that tasks which are privileged in non-initial
> user namespaces will be deemed privileged. =A0The privilege should only
> be granted if the task is in the initial user namespace.
>
> Switching the calls to capable() would change the behavior - it would
> cause the LSM capable hooks to be called, and set PF_SUPERPRIV if
> the capability was used. =A0So instead, put in an explicit check and
> refuse privilege if the caller is not in init_user_ns.
>
> Changelog:
> Oct 23: Use a nice macro to make the code shorter and easier to read,
> =A0 =A0 =A0 =A0per advice from Andrew Morgan and David Howells.
>
> Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
> Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
> =A0drivers/block/drbd/drbd_nl.c =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/md/dm-log-userspace-transfer.c | =A0 =A02 +-
> =A0drivers/staging/pohmelfs/config.c =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/video/uvesafb.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0include/linux/cred.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 ++
> =A05 files changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
> index af2a250..b7b19b8 100644
> --- a/drivers/block/drbd/drbd_nl.c
> +++ b/drivers/block/drbd/drbd_nl.c
> @@ -2297,7 +2297,7 @@ static void drbd_connector_callback(struct cn_msg *=
req, struct netlink_skb_parms
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (!cap_raised(current_cap(), CAP_SYS_ADMIN)) {
> + =A0 =A0 =A0 if (!IN_ROOT_USER_NS() || !cap_raised(current_cap(), CAP_SY=
S_ADMIN)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retcode =3D ERR_PERM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto fail;
> =A0 =A0 =A0 =A0}
> diff --git a/drivers/md/dm-log-userspace-transfer.c b/drivers/md/dm-log-u=
serspace-transfer.c
> index 1f23e04..126a79b 100644
> --- a/drivers/md/dm-log-userspace-transfer.c
> +++ b/drivers/md/dm-log-userspace-transfer.c
> @@ -134,7 +134,7 @@ static void cn_ulog_callback(struct cn_msg *msg, stru=
ct netlink_skb_parms *nsp)
> =A0{
> =A0 =A0 =A0 =A0struct dm_ulog_request *tfr =3D (struct dm_ulog_request *)=
(msg + 1);
>
> - =A0 =A0 =A0 if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
> + =A0 =A0 =A0 if (!IN_ROOT_USER_NS() || !cap_raised(current_cap(), CAP_SY=
S_ADMIN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0spin_lock(&receiving_list_lock);
> diff --git a/drivers/staging/pohmelfs/config.c b/drivers/staging/pohmelfs=
/config.c
> index b6c42cb..327c047 100644
> --- a/drivers/staging/pohmelfs/config.c
> +++ b/drivers/staging/pohmelfs/config.c
> @@ -525,7 +525,7 @@ static void pohmelfs_cn_callback(struct cn_msg *msg, =
struct netlink_skb_parms *n
> =A0{
> =A0 =A0 =A0 =A0int err;
>
> - =A0 =A0 =A0 if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
> + =A0 =A0 =A0 if (!IN_ROOT_USER_NS() || !cap_raised(current_cap(), CAP_SY=
S_ADMIN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0switch (msg->flags) {
> diff --git a/drivers/video/uvesafb.c b/drivers/video/uvesafb.c
> index 7f8472c..94e0e9d 100644
> --- a/drivers/video/uvesafb.c
> +++ b/drivers/video/uvesafb.c
> @@ -73,7 +73,7 @@ static void uvesafb_cn_callback(struct cn_msg *msg, str=
uct netlink_skb_parms *ns
> =A0 =A0 =A0 =A0struct uvesafb_task *utask;
> =A0 =A0 =A0 =A0struct uvesafb_ktask *task;
>
> - =A0 =A0 =A0 if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
> + =A0 =A0 =A0 if (!IN_ROOT_USER_NS() || !cap_raised(current_cap(), CAP_SY=
S_ADMIN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0if (msg->seq >=3D UVESAFB_TASKS_MAX)
> diff --git a/include/linux/cred.h b/include/linux/cred.h
> index 4030896..2f75da7 100644
> --- a/include/linux/cred.h
> +++ b/include/linux/cred.h
> @@ -359,9 +359,11 @@ static inline void put_cred(const struct cred *_cred)
>
> =A0#ifdef CONFIG_USER_NS
> =A0#define current_user_ns() (current_cred_xxx(user_ns))
> +#define IN_ROOT_USER_NS() (current_user_ns() =3D=3D &init_user_ns)
> =A0#else
> =A0extern struct user_namespace init_user_ns;
> =A0#define current_user_ns() (&init_user_ns)
> +#define IN_ROOT_USER_NS() (1)
> =A0#endif
>
>
> --
> 1.7.0.4
>
>
