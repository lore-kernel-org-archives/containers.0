From: Amir Goldstein <amir73il-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4] Introduce v3 namespaced file capabilities
Date: Tue, 20 Jun 2017 08:42:45 +0300
Message-ID: <CAOQ4uxhi5fezF7e9FpS=hHUb1LqzyCNq9BcG14RV_Srj1hS-Vw__46211.7525203668$1497937388$gmane$org@mail.gmail.com>
References: <20170508044408.GA11400@mail.hallyn.com>
	<CACOXgS9a=avAWZEre1Q1CGjSHeq78Pkq1fYfwPjiyEX-u=B5wQ@mail.gmail.com>
	<20170508181156.GA23112@mail.hallyn.com>
	<9f80188c-df03-066a-5dac-785cc711d064@linux.vnet.ibm.com>
	<20170613171818.GA9070@mail.hallyn.com>
	<74e490f3-3c47-abfa-86ae-0fa0d1ddb43a@linux.vnet.ibm.com>
	<20170613235521.GC15685@mail.hallyn.com>
	<ce471b11-e76a-25f3-eae8-eca30e7233af@linux.vnet.ibm.com>
	<20170615030543.GA8979@mail.hallyn.com>
	<f0df1914-bca2-31a0-cdba-df30d85d70b3@linux.vnet.ibm.com>
	<20170618221418.GA364@mail.hallyn.com> <87tw3boe5d.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87tw3boe5d.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jun 20, 2017 at 12:34 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
>
>> Quoting Stefan Berger (stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>>> On 06/14/2017 11:05 PM, Serge E. Hallyn wrote:
>>> >On Wed, Jun 14, 2017 at 08:27:40AM -0400, Stefan Berger wrote:
>>> >>On 06/13/2017 07:55 PM, Serge E. Hallyn wrote:
>>> >>>Quoting Stefan Berger (stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>>> >>>>  If all extended
>>> >>>>attributes were to support this model, maybe the 'uid' could be
>>> >>>>associated with the 'name' of the xattr rather than its 'value' (not
>>> >>>>sure whether that's possible).
>>> >>>Right, I missed that in your original email when I saw it this morning.
>>> >>>It's not what my patch does, but it's an interesting idea.  Do you have
>>> >>>a patch to that effect?  We might even be able to generalize that to
>>> >>No, I don't have a patch. It may not be possible to implement it.
>>> >>The xattr_handler's  take the name of the xattr as input to get().
>>> >That may be ok though.  Assume the host created a container with
>>> >100000 as the uid for root, which created a container with 130000 as
>>> >uid for root.  If root in the nested container tries to read the
>>> >xattr, the kernel can check for security.foo[130000] first, then
>>> >security.foo[100000], then security.foo.  Or, it can do a listxattr
>>> >and look for those.  Am I overlooking one?
>>> >
>>> >>So one could try to encode the mapped uid in the name. However, that
>>> >I thought that's exactly what you were suggesting in your original
>>> >email?  "security.capability[uid=2000]"
>>> >
>>> >>could lead to problems with stale xattrs in a shared filesystem over
>>> >>time unless one could limit the number of xattrs with the same
>>> >>prefix, e.g., security.capability*. So I doubt that it would work.
>>> >Hm.  Yeah.  But really how many setups are there like that?  I.e. if
>>> >you launch a regular docker or lxd container, the image doesn't do a
>>> >bind mount of a shared image, it layers something above it or does a
>>> >copy.  What setups do you know of where multiple containers in different
>>> >user namespaces mount the same filesystem shared and writeable?
>>>
>>> I think I have something now that accomodates userns access to
>>> security.capability:
>>>
>>> https://github.com/stefanberger/linux/commits/xattr_for_userns
>>
>> Thanks!
>>
>>> Encoding of uid is in the attribute name now as follows:
>>> security.foo@uid=<uid>
>>>
>>> 1) The 'plain' security.capability is only r/w accessible from the
>>> host (init_user_ns).
>>> 2) When userns reads/writes 'security.capability' it will read/write
>>> security.capability@uid=<uid> instead, with uid being the uid of
>>> root , e.g. 1000.
>>> 3) When listing xattrs for userns the host's security.capability is
>>> filtered out to avoid read failures iof 'security.capability' if
>>> security.capability@uid=<uid> is read but not there. (see 1) and 2))
>>> 4) security.capability* may all be read from anywhere
>>> 5) security.capability@uid=<uid> may be read or written directly
>>> from a userns if <uid> matches the uid of root (current_uid())
>>
>> This looks very close to what we want.  One exception - we do want
>> to support root in a user namespace being able to write
>> security.capability@uid=<x> where <x> is a valid uid mapped in its
>> namespace.  In that case the name should be rewritten to be
>> security.capability@uid=<y> where y is the unmapped kuid.val.
>>
>> Eric,
>>
>> so far my patch hasn't yet hit Linus' tree.  Given that, would you
>> mind taking a look and seeing what you think of this approach?  If
>> we may decide to go this route, we probably should stop my patch
>> from hitting Linus' tree before we have to continue supporting it.
>
> Agreed.  I will take a look.  I also want to see how all of this works
> in the context of stackable filesystems.  As that is the one case that
> looked like it could be a problem case in your current patchset.
>

Apropos stackable filesystems [cc some overlayfs folks], is there any
way that parts of this work could be generalized towards ns aware
trusted@uid.* xattr?

With overlayfs, files are written to underlying fs with mounter's
credentials. How this affects v3 security capabilities and how exactly
security xattrs are handled in overtlayfs I'm not sure. Vivek?

But, if we had an infrastructure to store trusted@<rootid> xattr, then
unprivileged overlayfs mount would become a very reachable goal.
Much closer goal then loop mounting...

Amir.
