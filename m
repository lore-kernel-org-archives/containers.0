From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH v2 1/3] ima: extend clone() with IMA namespace support
Date: Thu, 15 Mar 2018 14:26:05 -0400
Message-ID: <2183a3b4-6270-d2e9-70ad-a7399eb1681c@linux.vnet.ibm.com>
References: <20180309201421.6150-1-stefanb@linux.vnet.ibm.com>
	<20180309201421.6150-2-stefanb@linux.vnet.ibm.com>
	<87vadxfwqj.fsf@xmission.com>
	<c18b6e92-57f0-5994-eb60-5fadc6671832@linux.vnet.ibm.com>
	<1521135192.5348.64.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1521135192.5348.64.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, david.safford-JJi787mZWgc@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On 03/15/2018 01:33 PM, James Bottomley wrote:
> On Thu, 2018-03-15 at 11:26 -0400, Stefan Berger wrote:
>> On 03/15/2018 06:40 AM, Eric W. Biederman wrote:
>>> Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
>>>
>>>> From: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>>>
>>>> Add new CONFIG_IMA_NS config option.  Let clone() create a new
>>>> IMA namespace upon CLONE_NEWNS flag. Add ima_ns data structure in
>>>> nsproxy.  ima_ns is allocated and freed upon IMA namespace
>>>> creation and exit.  Currently, the ima_ns contains no useful IMA
>>>> data but only a dummy interface. This patch creates the framework
>>>> for namespacing the different aspects of IMA (eg. IMA-audit, IMA-
>>>> measurement, IMA-appraisal).
>>> IMA is not path based.  The only thing that belongs to a mount
>>> namespace are paths.  Therefore IMA is completely inappropriate to
>>> be joint with a mount namespace.
> Just to be clear: The mount namespace is not only about paths it's also
> about subtree properties.  However, the point still stands that IMA has
> a dependency on neither.
>
>> IMA measures the files described by these paths. The files also may
>> hold signatures (security.ima xattr) needed for IMA appraisal.
> The xattr is an inode property, which isn't namespaced by the mount_ns.
>
> When we had this discussion last year, we talked about possibly using
> the user_ns instead.  It makes sense because for IMA signatures you're

'using the user_ns' I suppose means hooking IMA namespace to it...

> going to need some type of keyring namespace and there's already one
> hanging off the user_ns:
>
> commit f36f8c75ae2e7d4da34f4c908cebdb4aa42c977e
> Author: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date:   Tue Sep 24 10:35:19 2013 +0100
>
>      KEYS: Add per-user_namespace registers for persistent per-UID
> kerberos caches

The benefit for IMA would be that this would then tie the keys needed 
for appraising to the IMA namespace's policy.
However, if you have an appraise policy in your IMA namespace, which is 
now hooked to the user namespace, and you join that user namespace but 
your files don't have signatures, nothing will execute anymore. That's 
now a side effect of joining this user namespace unless we have a magic 
exception. My feeling is, people may not like that...

>
>>> I saw that Serge even recently mentioned that you need to take
>>> this aspect of the changes back to the drawing board.  With my
>>> namespace maintainer hat on I repeat that.
>> Drawing board is here now (tuning on the text...):
>>
>> http://kernsec.org/wiki/index.php/IMA_Namespacing_design_consideratio
>> ns
> You mention an abuse case here which is basically a way of relaxing
> security policy.  Cannot we fix that by making policy hierarchical, so
> a child namespace must have the same or a more strict policy than the
> parent?

I updated the page now with a hopefully better idea. So that root cannot 
escape IMA-appraisal by spawning IMA namespaces and setting an IMA NULL 
policy, root's activities will *always* be evaluated against the 
init_ima_ns policy with keys found in the init_user_ns. In other word, 
if there is an appraisal policy (rule) on the host's init_ima_ns and 
root does something as uid 0 in any namespace, file activity for 
appraising purposes must pass signature checking. So just spawning a MNT 
namespace, mounting a filesystem with unknown apps won't execute any of 
them unless the stuff is signed.

>
>>>   From a 10,000 foot view I can already tell that this is hopeless.
>>> So for binding IMA namspaces and CLONE_NEWNS:
>>>
>>> Nacked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>>>
>>> I am not nacking IMA namespacing just inappropriately tying ima
>>> namespaces to mount namespaces.  These should be completely
>>> separate entities.
>> Let's say we go down the road of spawning it independently. Can we
>> use the unused clone flag 0x1000? Or should we come up with new
>> unshare2()/clone2() syscalls to extend the clone bits to 64 bit? Or
>> use a sysfs/securityfs file to spawn a new IMA namespace? Make this a
>> generic file not an IMA specific one?
> If, as a result of discussions, it turns out that a separate namespace
> is the correct way to proceed, I'm sure we can sort out the details of
> how we cope with the flag paucity problem.

Well, it's the side effects that people may not like when an IMA policy 
is active now and hooked to a USER namespace, as pointed out above. If 
we don't like the side effects, better create our own independent namespace.

    Stefan

>
> James
>
>
