From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 02/10] userns: Add per user namespace sysctls.
Date: Thu, 21 Jul 2016 10:37:20 -0500
Message-ID: <87vazz57f3.fsf@x220.int.ebiederm.org>
References: <8737n5dscy.fsf@x220.int.ebiederm.org>
	<20160720012138.7894-1-ebiederm@xmission.com>
	<20160720012138.7894-2-ebiederm@xmission.com>
	<578F1A00.6030701@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <578F1A00.6030701-6AxghH7DbtA@public.gmane.org> (Nikolay Borisov's message of "Wed,
	20 Jul 2016 09:28:16 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
List-Id: containers.vger.kernel.org

Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:

> Just a couple of nits.
>
> On 07/20/2016 04:21 AM, Eric W. Biederman wrote:
>> Limit per userns sysctls to only be opened for write by a holder
>> of CAP_SYS_RESOURCE.
>> 
>> Add all of the necessary boilerplate for having per user namespace
>> sysctls.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>>  include/linux/user_namespace.h |  4 ++
>>  kernel/user_namespace.c        | 92 +++++++++++++++++++++++++++++++++++++++++-
>>  2 files changed, 94 insertions(+), 2 deletions(-)
>> 
>> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
>> index 9217169c64cb..7d59af1f08f1 100644
>> --- a/include/linux/user_namespace.h
>> +++ b/include/linux/user_namespace.h
>> @@ -39,6 +39,10 @@ struct user_namespace {
>>  	struct key		*persistent_keyring_register;
>>  	struct rw_semaphore	persistent_keyring_register_sem;
>>  #endif
>> +#ifdef CONFIG_SYSCTL
>> +	struct ctl_table_set	set;
>> +	struct ctl_table_header *sysctls;
>> +#endif
>>  };
>>  
>>  extern struct user_namespace init_user_ns;
>> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
>> index 68f594212759..b5b5cbb8fe92 100644
>> --- a/kernel/user_namespace.c
>> +++ b/kernel/user_namespace.c
>> @@ -30,6 +30,70 @@ static bool new_idmap_permitted(const struct file *file,
>>  				struct user_namespace *ns, int cap_setid,
>>  				struct uid_gid_map *map);
>>  
>> +#ifdef CONFIG_SYSCTL
>> +static struct ctl_table_set *
>> +set_lookup(struct ctl_table_root *root)
>> +{
>> +	return &current->cred->user_ns->set;
> Why not current_user_ns()->set?
>
>> +}
>> +
>> +static int set_is_seen(struct ctl_table_set *set)
>> +{
>> +	return &current->cred->user_ns->set == set;
> DITTO
>
>> +}
>> +
>> +static int set_permissions(struct ctl_table_header *head,
>> +				  struct ctl_table *table)
>> +{
>> +	struct user_namespace *user_ns =
>> +		container_of(head->set, struct user_namespace, set);
>> +	int mode;
>> +
>> +	/* Allow users with CAP_SYS_ADMIN unrestrainted access */
> Just a minor nit: The comment and following code don't match.
>
>> +	if (ns_capable(user_ns, CAP_SYS_RESOURCE))
>> +		mode = (table->mode & S_IRWXU) >> 6;
>> +	else
>> +	/* Allow all others at most read-only access */
>> +		mode = table->mode & S_IROTH;
>> +	return (mode << 6) | (mode << 3) | mode;
>> +}
>> +
>> +static struct ctl_table_root set_root = {
>> +	.lookup = set_lookup,
>> +	.permissions = set_permissions,
>> +};
>> +
>> +static struct ctl_table userns_table[] = {
>> +	{ }
>> +};
>> +#endif /* CONFIG_SYSCTL */
>> +
>> +static bool setup_userns_sysctls(struct user_namespace *ns)
>> +{
>> +#ifdef CONFIG_SYSCTL
>> +	struct ctl_table *tbl;
>> +	setup_sysctl_set(&ns->set, &set_root, set_is_seen);
>> +	tbl = kmemdup(userns_table, sizeof(userns_table), GFP_KERNEL);
>> +	if (tbl) {
>> +		ns->sysctls = __register_sysctl_table(&ns->set, "userns", tbl);
>> +	}
>> +	if (!ns->sysctls) {
>> +		kfree(tbl);
>> +		retire_sysctl_set(&ns->set);
>> +		return false;
>> +	}
>> +#endif
>> +	return true;
>> +}
>> +
>> +static void retire_userns_sysctls(struct user_namespace *ns)
>> +{
>> +#ifdef CONFIG_SYSCTL
>> +	unregister_sysctl_table(ns->sysctls);
>> +	retire_sysctl_set(&ns->set);
>> +#endif
>> +}
>> +
>>  static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
>>  {
>>  	/* Start with the same capabilities as init but useless for doing
>> @@ -107,12 +171,22 @@ int create_user_ns(struct cred *new)
>>  	ns->flags = parent_ns->flags;
>>  	mutex_unlock(&userns_state_mutex);
>>  
>> -	set_cred_user_ns(new, ns);
>> -
>>  #ifdef CONFIG_PERSISTENT_KEYRINGS
>>  	init_rwsem(&ns->persistent_keyring_register_sem);
>>  #endif
>> +	ret = -ENOMEM;
>> +	if (!setup_userns_sysctls(ns))
>> +		goto fail_keyring;
>> +
>> +	set_cred_user_ns(new, ns);
>>  	return 0;
>> +fail_keyring:
>> +#ifdef CONFIG_PERSISTENT_KEYRINGS
>> +	key_put(ns->persistent_keyring_register);
>> +#endif
>> +	ns_free_inum(&ns->ns);
>> +	kmem_cache_free(user_ns_cachep, ns);
>> +	return ret;
>>  }
>>  
>>  int unshare_userns(unsigned long unshare_flags, struct cred **new_cred)
>> @@ -141,6 +215,7 @@ void free_user_ns(struct user_namespace *ns)
>>  
>>  	do {
>>  		parent = ns->parent;
>> +		retire_userns_sysctls(ns);
>>  #ifdef CONFIG_PERSISTENT_KEYRINGS
>>  		key_put(ns->persistent_keyring_register);
>>  #endif
>> @@ -1012,9 +1087,22 @@ const struct proc_ns_operations userns_operations = {
>>  	.install	= userns_install,
>>  };
>>  
>> +static struct ctl_table_header *userns_header;
>>  static __init int user_namespaces_init(void)
>>  {
>> +	static struct ctl_table empty[1];
>>  	user_ns_cachep = KMEM_CACHE(user_namespace, SLAB_PANIC);
>> +
>> +#ifdef CONFIG_SYSCTL
>> +	/*
>> +	 * Avoid limits in the sysctl limitation by registering
>> +	 * "/proc/sys/userns" as an empty directory not in a network
>> +	 * namespace.
>> +	 */
> The comment is not very clear to someone who is not intimately familiar
> with the sysctl infrastructure, perhaps you can make it a bit more
> verbose?

Good point.  I don't think I can say meaningfully say much more than
this is necessary, but I will see if I can improve the comment a little.

>> +	userns_header = register_sysctl("userns", empty);
>> +	BUG_ON(!userns_header);
>> +#endif
>> +	BUG_ON(!setup_userns_sysctls(&init_user_ns));
> Do we really want the extra code the BUG_ON adds even in the
> !CONFIG_SYSCTL case, possibly the compiler could eliminate it but I
> can't help it but wonder.

BUG_ON is about two instructions so I am not too concerned.  When
possible it is generally preferable to not have code in #ifdef XXX as
then weird cases come up in maintenance.  In this case I am reworking
things to do a bit better so that the code doesn't throw warnings when
!CONFIG_SYSCTL.  Unnecessary warnings are the larger problem.

Eric
