From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: Re: Interaction user namespace, /proc/1 ownership & cap_set
Date: Tue, 02 Jul 2013 22:24:47 +0200
Message-ID: <51D3370F.6000909@nod.at>
References: <20130701161625.GQ15954@redhat.com>
	<51D261D3.3030002@cn.fujitsu.com> <87wqp9uz9a.fsf@xmission.com>
	<51D295C5.1080003@nod.at> <20130702092554.GD2524@redhat.com>
	<87ehbhthbl.fsf@xmission.com> <51D2A649.9030102@cn.fujitsu.com>
	<8761wsudgk.fsf@xmission.com> <20130702164514.GB2524@redhat.com>
	<87k3l8sx6l.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k3l8sx6l.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Am 02.07.2013 19:12, schrieb Eric W. Biederman:
> "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> 
>> On Tue, Jul 02, 2013 at 09:35:39AM -0700, Eric W. Biederman wrote:
>>> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
>>>
>>>> On 07/02/2013 05:57 PM, Eric W. Biederman wrote:
>>>>> "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>>>>>
>>>>>> On Tue, Jul 02, 2013 at 10:56:37AM +0200, Richard Weinberger wrote:
>>>>>>> Am 02.07.2013 10:44, schrieb Eric W. Biederman:
>>>>>>>> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
>>>>>>>>
>>>>>>>>> On 07/02/2013 12:16 AM, Daniel P. Berrange wrote:
>>>>>>>>>> I'm struggling debugging a strange problem with interaction between user
>>>>>>>>>> namespaces, cap_set and ownership of files in /proc/1/
>>>>>>>>>>
>>>>>>>>>
>>>>>>>>> This problem is occured after we call setuid/gid.
>>>>>>>>>
>>>>>>>>> for example, a task whose pid is 1234 calls
>>>>>>>>> setregid(10,10);
>>>>>>>>> setreuid(10,10);
>>>>>>
>>>>>> If seems to get reset to the right values (0:0) when we execve()
>>>>>> the init binary though.  This doesn't happen if we have invoked
>>>>>> the capset() syscall in between the setregid & the execve() calls.
>>>>>
>>>>> Yes, execve() should reset the dumpable state.
>>>>>
>>>>> I took a quick look and I don't see a way around set_dumpable calls in
>>>>> setup_new_exec.  Why the process remains undumpable after exec is worth
>>>>> investigating.  That logic should not be user namespace specific
>>>>> however.
>>>>>
>>>>
>>>> I think it's the install_exec_creds, it calls commit_creds to set process undumpable
>>>>
>>>>         /* dumpability changes */
>>>>         if (!uid_eq(old->euid, new->euid) ||
>>>>             !gid_eq(old->egid, new->egid) ||
>>>>             !uid_eq(old->fsuid, new->fsuid) ||
>>>>             !gid_eq(old->fsgid, new->fsgid) ||
>>>>             !cred_cap_issubset(old, new)) {
>>>>                 if (task->mm)
>>>>                         set_dumpable(task->mm, suid_dumpable);
>>>>                 task->pdeath_signal = 0;
>>>>                 smp_wmb();
>>>>         }
>>>
>>> That looks like it could do it.  Especially if exec is increasing your
>>> capabilities.
>>
>> Ah, yes, that would explain it. My demo is removing the SYS_MODULE
>> capability, and then exec'ing the shell binary. Since we are uid==0,
>> and prctl(PR_CAPBSET_DROP) is not available inside the user namespace,
>> the rules for capabilities vs execve() call will cause the shell
>> binary to regain SYS_MODULE capability bit.
>>
>> So the problem I'm seeing in libvirt is all a result of the fact
>> that we can't use PR_CAPBSET_DROP inside the user namespace. Given
>> that there's no point trying to drop any capabilities inside the
>> user namespace.
>>
>> The only slight problem here is that we want to drop CAP_MKNOD so
>> that systemd can detect that it shouldn't attempt to run any units
>> which would rely on mknod.
> 
> I just looked at that and I don't see a justification for the
> restriciton.
> 
> Could you try the patch below and see if it fixes things for you?

With the patch applied my test program is able to drop it's caps
(using libcap-ng) and does not regain them upon execve.
Also reading from /proc/1/environ works. :)

> Eric
> 
> 
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Date: Tue, 2 Jul 2013 10:04:54 -0700
> Subject: [PATCH] userns: Allow PR_CAPBSET_DROP in a user namespace.
> 
> As the capabilites and capability bounding set are per user namespace
> properties it is safe to allow changing them with just CAP_SETPCAP
> permission in the user namespace.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Tested-by: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>

> ---
>  security/commoncap.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/security/commoncap.c b/security/commoncap.c
> index 4d787e6..fd9b08f 100644
> --- a/security/commoncap.c
> +++ b/security/commoncap.c
> @@ -843,7 +843,7 @@ int cap_task_setnice(struct task_struct *p, int nice)
>   */
>  static long cap_prctl_drop(struct cred *new, unsigned long cap)
>  {
> -	if (!capable(CAP_SETPCAP))
> +	if (!ns_capable(current_user_ns(), CAP_SETPCAP))
>  		return -EPERM;
>  	if (!cap_valid(cap))
>  		return -EINVAL;
> 

Thanks,
//richard
