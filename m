From: Dimitri John Ledkov <xnox-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] KEYS: allow changing key ownership with CAP_SYS_ADMIN in
	a NS
Date: Sat, 14 Oct 2017 21:59:11 +0100
Message-ID: <CANBHLUiF2keHZHZMan_F+9-Z=mP7GfAiV9sGxfesnGh=P12ugA@mail.gmail.com>
References: <20171003024528.28242-1-xnox@ubuntu.com>
	<87fub0gb6k.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87fub0gb6k.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 3 October 2017 at 04:30, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Dimitri John Ledkov <xnox-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
>
>> Currently, changing key ownership from one namespaced uid/gid to
>> another namespaced uid/gid is only allowed by processes that have
>> CAP_SYS_ADMIN in the intial namespace. Fix the capability check to
>> also check the capability in the current capability.
>
> Nacked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>
> I won't deny the issue, but unless I am misreading something this
> will allow me to change the the uid of any key simply by unsharing
> a user namespace.  At which point there is no point in having a
> permission check at all.
>

Reading the code I do not believe this is true. But I'm not sure how
we can prove this.

My understanding is that chown operation is change of source uid/guid
to some target uid/guid.

Source uid/gid are validated by calling lookup_user_key() and this is
where the source ACL is asserted. I am not sure about the flags
requested, but it looks to me that ctx.cred = get_current_cred() is
used in key_task_permission() already and thus already requires the
owner of the key, or be in the group, or the other permissions to
allow setattr permission, and on top of that LSM module must ok this
too. What I'm not sure about is if the "other" permissions check is
correctly namespaced, since "other" permissions should not imho leak
between user namespaces.

If lookup_user_key() is not allowed by get_current_cred() the function
bails out, even before doing capability check.

The capability check validates the target uid/gid only. And it decides
whether the change of source -> target is deemed to be permissible,
when the current process is otherwise allowed to tinker with the
source key. We already look up target uid/gid relative current user
namespace thus both target & source uid/gid are from the same
namespace. And we then allow change of group by the key owner, within
the groups one is in, and we only allow uid change for CAP_SYS_ADMIN.
However the CAP_SYS_ADMIN we demand here is the one from initial
namespace, rather than from current user namespace.

Does above assessment addresses your immediate concern?
Is my understanding of this code flawed, especially the bit about the
security of lookup_user_key()?

I do want to write test cases to assert current behavior and
experimentally assert change of behavior with my patch applied. Is
there existing test-suite / unit-tests for changing key permissions?
(e.g. some keyctl test-suite and/or some namespace tests?) Any tips /
pointers of where that should live, or if there are any existing unit
tests w.r.t. to this functionality?

Regards,

Dimitri.

>
>> Fixes: https://github.com/systemd/systemd/issues/6281
>> Signed-off-by: Dimitri John Ledkov <xnox-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
>> ---
>>
>>  Dear containers mailing list,
>>
>>  There is now userspace code that uses kernel keyring, in
>>  user-namespaces, and tries to chown the keyrings from one namespaced
>>  uid/gid to another. See systemd keyring code to store invocation id
>>  in src/core/execute.c.
>>
>>  This code fails under system user-namespace containers, such as
>>  OpenVZ, LXC, LXD.
>>
>>  Setup for a reproducer:
>>  ## enter a user-names, however you like. Using lxd as an example
>>  $ lxc init ubunt-daily:a test-keyring
>>  $ lxc exec test-keyring bash
>>  # apt install keyutils
>>
>>  Reproducer:
>>  # keyctl session
>>  Joined session keyring: 556756508
>>  # keyctl chown 556756508 1000
>>  keyctl_chown: Permission denied
>>  # keyctl chown 556756508 0
>>  # echo $?
>>
>>  The permission denied is unexpected, and this patch resolves
>>  this. I've tested this patch by recompiling Ubuntu kernel with this
>>  patch applied and testing above in a VM.
>>
>>  Some prior art. When user namespaces were written in 2011, code to
>>  switch from capable to ns_capable was written, but eventually not
>>  merged due to siding on a being more conservative, as mentioned in
>>  the pull request in 2012. Given that user-namespaces are more mature
>>  now, and actually in active use, it is time to lax capability checks
>>  to probe user namespace rather than initial naspace.
>>
>>  Please consider applying this patch.
>>
>>  References to prior art:
>>  https://lists.onap.org/pipermail/containers/2011-September/028137.html
>>  https://github.com/torvalds/linux/commit/437589a74b6a590d175f86cf9f7b2efcee7765e7
>>
>>       Ultimately there will be work to relax privlige checks from
>>      "capable(FOO)" to "ns_capable(user_ns, FOO)" where it is safe
>>      allowing root in a user names to do those things that today we
>>      only forbid to non-root users because it will confuse suid root
>>      applications.
>>
>>  security/keys/keyctl.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
>> index ab0b337c84b4..dc554bb80325 100644
>> --- a/security/keys/keyctl.c
>> +++ b/security/keys/keyctl.c
>> @@ -822,65 +822,65 @@ long keyctl_chown_key(key_serial_t id, uid_t user, gid_t group)
>>       struct key_user *newowner, *zapowner = NULL;
>>       struct key *key;
>>       key_ref_t key_ref;
>>       long ret;
>>       kuid_t uid;
>>       kgid_t gid;
>>
>>       uid = make_kuid(current_user_ns(), user);
>>       gid = make_kgid(current_user_ns(), group);
>>       ret = -EINVAL;
>>       if ((user != (uid_t) -1) && !uid_valid(uid))
>>               goto error;
>>       if ((group != (gid_t) -1) && !gid_valid(gid))
>>               goto error;
>>
>>       ret = 0;
>>       if (user == (uid_t) -1 && group == (gid_t) -1)
>>               goto error;
>>
>>       key_ref = lookup_user_key(id, KEY_LOOKUP_CREATE | KEY_LOOKUP_PARTIAL,
>>                                 KEY_NEED_SETATTR);
>>       if (IS_ERR(key_ref)) {
>>               ret = PTR_ERR(key_ref);
>>               goto error;
>>       }
>>
>>       key = key_ref_to_ptr(key_ref);
>>
>>       /* make the changes with the locks held to prevent chown/chown races */
>>       ret = -EACCES;
>>       down_write(&key->sem);
>>
>> -     if (!capable(CAP_SYS_ADMIN)) {
>> +     if (!ns_capable(current_user_ns(), CAP_SYS_ADMIN)) {
>>               /* only the sysadmin can chown a key to some other UID */
>>               if (user != (uid_t) -1 && !uid_eq(key->uid, uid))
>>                       goto error_put;
>>
>>               /* only the sysadmin can set the key's GID to a group other
>>                * than one of those that the current process subscribes to */
>>               if (group != (gid_t) -1 && !gid_eq(gid, key->gid) && !in_group_p(gid))
>>                       goto error_put;
>>       }
>>
>>       /* change the UID */
>>       if (user != (uid_t) -1 && !uid_eq(uid, key->uid)) {
>>               ret = -ENOMEM;
>>               newowner = key_user_lookup(uid);
>>               if (!newowner)
>>                       goto error_put;
>>
>>               /* transfer the quota burden to the new user */
>>               if (test_bit(KEY_FLAG_IN_QUOTA, &key->flags)) {
>>                       unsigned maxkeys = uid_eq(uid, GLOBAL_ROOT_UID) ?
>>                               key_quota_root_maxkeys : key_quota_maxkeys;
>>                       unsigned maxbytes = uid_eq(uid, GLOBAL_ROOT_UID) ?
>>                               key_quota_root_maxbytes : key_quota_maxbytes;
>>
>>                       spin_lock(&newowner->lock);
>>                       if (newowner->qnkeys + 1 >= maxkeys ||
>>                           newowner->qnbytes + key->quotalen >= maxbytes ||
>>                           newowner->qnbytes + key->quotalen <
>>                           newowner->qnbytes)
>>                               goto quota_overrun;
>>
>>                       newowner->qnkeys++;
