From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/7] [RFC] Support named cgroups hierarchies
Date: Tue, 31 Mar 2009 01:12:32 -0700
Message-ID: <6599ad830903310112x626252c4je760a80eb1eaa1d@mail.gmail.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>
	<20090312105122.24154.73633.stgit@menage.corp.google.com>
	<49BF46BC.4080302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49BF46BC.4080302-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Mar 16, 2009 at 11:44 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>
>> - should the specification be via a name= option as in this patch, or
>>   should we simply use the "device name" as passed to the mount()
>>   system call?  Using the device name is more conceptually clean and
>>   consistent with the filesystem API; however, given that the device
>>   name is currently ignored by cgroups, this would lead to a
>>   user-visible behaviour change.
>>
>
> If we use "device name" and don't allow it to be changed on remount,
> this seems a change that may break/suprise existing users?

Potentially, yes.

>
> And another issue is, using "device name" won't allow us to use NULL
> name, which is also user-visible in /proc/pid/cgroups/.

Hmm. We could treat "none" specially, but I guess that's a bit ugly.

>> +
>> +     /* The name for this hierarchy - may be empty */
>> +     char name[PATH_MAX];
>
> I think 32 or 64 is sufficient. How about reuse MAX_CGROUP_TYPE_NAMELEN
> which is the length limit of cgroup_subsys.name?

I've added a new define MAX_CGROUP_ROOT_NAMELEN, value 64
>> +             } else if (!strncmp(token, "name=", 5)) {
>> +                     /* Specifying two names is forbidden */
>> +                     if (opts->name)
>> +                             return -EINVAL;
>> +                     opts->name = kzalloc(PATH_MAX, GFP_KERNEL);
>> +                     if (!opts->name)
>> +                             return -ENOMEM;
>> +                     strncpy(opts->name, token + 5, PATH_MAX - 1);
>> +                     opts->name[PATH_MAX - 1] = 0;
>
> kstrndup()

Good idea.

>>
>> -     /* Next check flags */
>> -     if (new->flags != root->flags)
>
> Is this change intended or unintended? With this change we allow:
>  # mount -t cgroup -o cpu xxx /mnt1
>  # mount -t cgroup -o cpu,noprefix xxx /mnt2
> But files in /mnt2 still prefix with 'cpu.'

That fits in better with existing semantics for other filesystems - if
you mount an already-mounted device with different superblock mount
options, the new mount still has the superblock options associated
with the old mount.

Arguably this might mean that we should ignore all options when
mounting a hierarchy by name that already exists, even if you specify
a different set of subsystems from what is mounted.

>
>> +     /* If we asked for subsystems then they must match */
>> +     if (new->subsys_bits && new->subsys_bits != root->subsys_bits)
>>               return 0;
>
> This has already been checked.

Where?
>> -     init_cgroup_root(root);
>> -     root->subsys_bits = opts.subsys_bits;
>> -     root->flags = opts.flags;
>> -     if (opts.release_agent) {
>> -             strcpy(root->release_agent_path, opts.release_agent);
>> -             kfree(opts.release_agent);
>> -     }
>
> leaking opts.release_agent and opts.name with every successful mount.

Good point, fixed.

Paul
