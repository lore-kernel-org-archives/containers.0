From: "Andrew G. Morgan" <morgan@kernel.org>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Sun, 31 May 2009 13:26:21 -0700
Message-ID: <d4f050d30905311326i59bf5e2fjfa837f2720d076dc@mail.gmail.com>
References: <20090529223229.GA14536@us.ibm.com>
	 <20090529223319.GE14602@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090529223319.GE14602@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Serge,

I'm not sure I'm too happy with hard coding the 64-bitness of
capability sets. It may well be a very long time before we increase
their size, but couldn't you prepare for that with some reference to
the prevailing magic numbers for the current ABI representation?

Also, the use of 'error' as both a variable and a goto destination
looks a little confusing.

Cheers

Andrew


On Fri, May 29, 2009 at 3:33 PM, Serge E. Hallyn <serue@us.ibm.com> wro=
te:
> An application checkpoint image will store capability sets
> (and the bounding set) as __u64s. =C2=A0Define checkpoint and
> restart functions to translate between those and kernel_cap_t's.
>
> Define a common function do_capset_tocred() which applies capability
> set changes to a passed-in struct cred.
>
> The restore function uses do_capset_tocred() to apply the restored
> capabilities to the struct cred being crafted, subject to the
> current task's (task executing sys_restart()) permissions.
>
> Changelog:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0May 28: add helpers to c/r securebits
>
> Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
> ---
> =C2=A0include/linux/capability.h | =C2=A0 =C2=A07 +++
> =C2=A0kernel/capability.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 94 ++++=
+++++++++++++++++++++++++++++++++------
> =C2=A0security/commoncap.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 51 +++++++++=
+++++++--------
> =C2=A03 files changed, 122 insertions(+), 30 deletions(-)
>
> diff --git a/include/linux/capability.h b/include/linux/capability.h
> index c302110..b3853ca 100644
> --- a/include/linux/capability.h
> +++ b/include/linux/capability.h
> @@ -536,6 +536,13 @@ extern const kernel_cap_t __cap_empty_set;
> =C2=A0extern const kernel_cap_t __cap_full_set;
> =C2=A0extern const kernel_cap_t __cap_init_eff_set;
>
> +extern void checkpoint_save_cap(__u64 *dest, kernel_cap_t src);
> +struct cred;
> +extern int checkpoint_restore_cap(__u64 e, __u64 i, __u64 p, __u64 x=
,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct cred *cred);
> +extern void checkpoint_save_securebits(unsigned *, unsigned);
> +extern int checkpoint_restore_securebits(unsigned, struct cred *);
> +
> =C2=A0/**
> =C2=A0* has_capability - Determine if a task has a superior capabilit=
y available
> =C2=A0* @t: The task in question
> diff --git a/kernel/capability.c b/kernel/capability.c
> index 4e17041..d2c9bb3 100644
> --- a/kernel/capability.c
> +++ b/kernel/capability.c
> @@ -217,6 +217,45 @@ SYSCALL_DEFINE2(capget, cap_user_header_t, heade=
r, cap_user_data_t, dataptr)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
>
> +static int do_capset_tocred(kernel_cap_t *effective, kernel_cap_t *i=
nheritable,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 kernel_cap_t *permitted, struct cred *new)
> +{
> + =C2=A0 =C2=A0 =C2=A0 int ret;
> +
> + =C2=A0 =C2=A0 =C2=A0 ret =3D security_capset(new, current_cred(),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 effective, inheritable, permitted);
> + =C2=A0 =C2=A0 =C2=A0 if (ret < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> +
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* for checkpoint-restart, do we want to =
wait until end of restart?
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* not sure we care */
> + =C2=A0 =C2=A0 =C2=A0 audit_log_capset(current->pid, new, current_cr=
ed());
> +
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> +static int do_capset(kernel_cap_t *effective, kernel_cap_t *inherita=
ble,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 kernel_cap_t *permitted)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct cred *new;
> + =C2=A0 =C2=A0 =C2=A0 int ret;
> +
> + =C2=A0 =C2=A0 =C2=A0 new =3D prepare_creds();
> + =C2=A0 =C2=A0 =C2=A0 if (!new)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;
> +
> + =C2=A0 =C2=A0 =C2=A0 ret =3D do_capset_tocred(effective, inheritabl=
e, permitted, new);
> + =C2=A0 =C2=A0 =C2=A0 if (ret < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto error;
> +
> + =C2=A0 =C2=A0 =C2=A0 return commit_creds(new);
> +
> +error:
> + =C2=A0 =C2=A0 =C2=A0 abort_creds(new);
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> =C2=A0/**
> =C2=A0* sys_capset - set capabilities for a process or (*) a group of=
 processes
> =C2=A0* @header: pointer to struct that contains capability version a=
nd
> @@ -240,7 +279,6 @@ SYSCALL_DEFINE2(capset, cap_user_header_t, header=
, const cap_user_data_t, data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct __user_cap_data_struct kdata[_KERNE=
L_CAPABILITY_U32S];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned i, tocopy;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0kernel_cap_t inheritable, permitted, effec=
tive;
> - =C2=A0 =C2=A0 =C2=A0 struct cred *new;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pid_t pid;
>
> @@ -271,22 +309,52 @@ SYSCALL_DEFINE2(capset, cap_user_header_t, head=
er, const cap_user_data_t, data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0i++;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 new =3D prepare_creds();
> - =C2=A0 =C2=A0 =C2=A0 if (!new)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;
> + =C2=A0 =C2=A0 =C2=A0 return do_capset(&effective, &inheritable, &pe=
rmitted);
>
> - =C2=A0 =C2=A0 =C2=A0 ret =3D security_capset(new, current_cred(),
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &effective, &inheritable, &permitted);
> - =C2=A0 =C2=A0 =C2=A0 if (ret < 0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto error;
> +}
>
> - =C2=A0 =C2=A0 =C2=A0 audit_log_capset(pid, new, current_cred());
>
> - =C2=A0 =C2=A0 =C2=A0 return commit_creds(new);
> +void checkpoint_save_cap(__u64 *dest, kernel_cap_t src)
> +{
> + =C2=A0 =C2=A0 =C2=A0 *dest =3D src.cap[0] | (src.cap[1] << sizeof(_=
_u32));
> +}
>
> -error:
> - =C2=A0 =C2=A0 =C2=A0 abort_creds(new);
> - =C2=A0 =C2=A0 =C2=A0 return ret;
> +static void do_capbset_drop(struct cred *cred, int cap)
> +{
> + =C2=A0 =C2=A0 =C2=A0 cap_lower(cred->cap_bset, cap);
> +}
> +
> +int checkpoint_restore_cap(__u64 newe, __u64 newi, __u64 newp, __u64=
 newx,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 struct cred *cred)
> +{
> + =C2=A0 =C2=A0 =C2=A0 kernel_cap_t effective, inheritable, permitted=
, bset;
> + =C2=A0 =C2=A0 =C2=A0 int may_dropbcap =3D capable(CAP_SETPCAP);
> + =C2=A0 =C2=A0 =C2=A0 int ret, i;
> +
> + =C2=A0 =C2=A0 =C2=A0 effective.cap[0] =3D newe;
> + =C2=A0 =C2=A0 =C2=A0 effective.cap[1] =3D (newe >> sizeof(__u32));
> + =C2=A0 =C2=A0 =C2=A0 inheritable.cap[0] =3D newi;
> + =C2=A0 =C2=A0 =C2=A0 inheritable.cap[1] =3D (newi >> sizeof(__u32))=
;
> + =C2=A0 =C2=A0 =C2=A0 permitted.cap[0] =3D newp;
> + =C2=A0 =C2=A0 =C2=A0 permitted.cap[1] =3D (newp >> sizeof(__u32));
> + =C2=A0 =C2=A0 =C2=A0 bset.cap[0] =3D newx;
> + =C2=A0 =C2=A0 =C2=A0 bset.cap[1] =3D (newx >> sizeof(__u32));
> +
> + =C2=A0 =C2=A0 =C2=A0 ret =3D do_capset_tocred(&effective, &inherita=
ble, &permitted, cred);
> + =C2=A0 =C2=A0 =C2=A0 if (ret < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> +
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < CAP_LAST_CAP; i++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (cap_raised(bse=
t, i))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 continue;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!cap_raised(cu=
rrent_cred()->cap_bset, i))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 continue;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!may_dropbcap)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 return -EPERM;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do_capbset_drop(cr=
ed, i);
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> =C2=A0}
>
> =C2=A0/**
> diff --git a/security/commoncap.c b/security/commoncap.c
> index beac025..8054a07 100644
> --- a/security/commoncap.c
> +++ b/security/commoncap.c
> @@ -804,6 +804,28 @@ int cap_task_setnice (struct task_struct *p, int=
 nice)
> =C2=A0}
> =C2=A0#endif
>
> +int cap_set_securebits(struct cred *new, unsigned securebits)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if ((((new->securebits & SECURE_ALL_LOCKS) >> =
1)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0& (new->securebits ^ secur=
ebits)) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0/*[1]*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 || ((new->securebits & SECURE_AL=
L_LOCKS & ~securebits)) =C2=A0 =C2=A0 /*[2]*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 || (securebits & ~(SECURE_ALL_LO=
CKS | SECURE_ALL_BITS)) =C2=A0 =C2=A0 /*[3]*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 || (cap_capable(current, current=
_cred(), CAP_SETPCAP,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 SECURITY_CAP_AUDIT) !=3D 0) =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*[4]*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* [1] no cha=
nging of bits that are locked
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* [2] no unl=
ocking of locks
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* [3] no set=
ting of unsupported bits
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* [4] doing =
anything requires privilege (go read about
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=
=A0 the "sendmail capabilities bug")
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 )
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* cannot change a=
 locked bit */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EPERM;
> + =C2=A0 =C2=A0 =C2=A0 new->securebits =3D securebits;
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> =C2=A0/**
> =C2=A0* cap_task_prctl - Implement process control functions for this=
 security module
> =C2=A0* @option: The process control function requested
> @@ -861,24 +883,9 @@ int cap_task_prctl(int option, unsigned long arg=
2, unsigned long arg3,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * capability-based-privilege environment.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case PR_SET_SECUREBITS:
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 error =3D -EPERM;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((((new->secure=
bits & SECURE_ALL_LOCKS) >> 1)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
& (new->securebits ^ arg2)) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*[1]*/
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 || (=
(new->securebits & SECURE_ALL_LOCKS & ~arg2)) =C2=A0 /*[2]*/
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 || (=
arg2 & ~(SECURE_ALL_LOCKS | SECURE_ALL_BITS)) =C2=A0 /*[3]*/
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 || (=
cap_capable(current, current_cred(), CAP_SETPCAP,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SECURITY_CAP_AUDIT) !=
=3D 0) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*[4]*/
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* [1] no changing of bits that are locked
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* [2] no unlocking of locks
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* [3] no setting of unsupported bits
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* [4] doing anything requires privilege (go read about
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* =C2=A0 =C2=A0 the "sendmail capabilities bug")
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 )
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 /* cannot change a locked bit */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 error =3D cap_set_=
securebits(new, arg2);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (error)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0goto error;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 new->securebits =3D=
 arg2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto changed;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case PR_GET_SECUREBITS:
> @@ -921,6 +928,16 @@ error:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return error;
> =C2=A0}
>
> +void checkpoint_save_securebits(unsigned *b, unsigned cred_securebit=
s)
> +{
> + =C2=A0 =C2=A0 =C2=A0 *b =3D cred_securebits;
> +}
> +
> +int checkpoint_restore_securebits(unsigned b, struct cred *cred)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return cap_set_securebits(cred, b);
> +}
> +
> =C2=A0/**
> =C2=A0* cap_syslog - Determine whether syslog function is permitted
> =C2=A0* @type: Function requested
> --
> 1.6.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-secur=
ity-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
