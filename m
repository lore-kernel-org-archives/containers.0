From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH 1/5] ima: extend clone() with IMA namespace support
Date: Thu, 8 Mar 2018 17:53:04 -0500
Message-ID: <a6ef5679-6aef-21de-7cdb-48e8af83f874@linux.vnet.ibm.com>
References: <20170720225033.21298-1-mkayaalp@linux.vnet.ibm.com>
	<20170720225033.21298-2-mkayaalp@linux.vnet.ibm.com>
	<2fac8414-6957-1fce-6b40-ad4b687ca83c@linux.vnet.ibm.com>
	<20180308201931.GA6462@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180308201931.GA6462-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On 03/08/2018 03:19 PM, Serge E. Hallyn wrote:
> Quoting Stefan Berger (stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>> On 07/20/2017 06:50 PM, Mehmet Kayaalp wrote:
>>> From: Yuqiong Sun<suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>>
>>> Add new CONFIG_IMA_NS config option.  Let clone() create a new IMA
>>> namespace upon CLONE_NEWNS flag. Add ima_ns data structure in nsproxy.
>>> ima_ns is allocated and freed upon IMA namespace creation and exit.
>>> Currently, the ima_ns contains no useful IMA data but only a dummy
>>> interface. This patch creates the framework for namespacing the different
>>> aspects of IMA (eg. IMA-audit, IMA-measurement, IMA-appraisal).
>>>
>>> Signed-off-by: Yuqiong Sun<suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>>
>>> Changelog:
>>> * Use CLONE_NEWNS instead of a new CLONE_NEWIMA flag
>>> * Use existing ima.h headers
>>> * Move the ima_namespace.c to security/integrity/ima/ima_ns.c
>>> * Fix typo INFO->INO
>>> * Each namespace free's itself, removed recursively free'ing
>>> until init_ima_ns from free_ima_ns()
>> With this patch we would use CLONE_NEWNS and create an IMA and mount
>> namespace at the same time. However, the code below creates two
>> inodes to handle the two namespaces separately via setns(). The
> ...  right.
>
> Either the ima and mounts namespaces are so closely tied that ima_ns
> should be unshared on every CLONE_NEWNS, or not.  If they are, then
> every setns(CLONE_NEWNS)  must also change the ima_ns.  That is not the
> case here.  Every clone creates a new ima_ns, but we're not forcing
> tasks to be in the ima_ns that is matched with its mntns, and
> furthermore we have another object lifecycle to worry about.
>
> It still seems to me that the only sane way to do this is to have the
> ima_ns be its own object;  have it be owned by a user_ns;  require
> CAP_SYS_ADMIN (or better CAP_MAC_ADMIN) to your current userns to
> clone a new one, maybe with no other tasks in userns yet, for good
> measure.  And support hierarchical measuring (so parents can still
> get information about a child's actions).

I think there is a real benefit to keeping the IMA namespace with the 
mount namespace since the mount namespace carries the signatures in the 
xattrs and IMA the (appraisal) policy. The user namespace has the keys 
IMA needs for signature verification and if missing, the appraisal will 
fail (at least that is how it could work but Mimi tells me the pointer 
to the IMA keyring is cached). So there's an incentive to keep the 
otherwise 'loose' namespaces 'together.' If we were to associate the IMA 
namespace with the user namespace or be stand-alone, it is easier to 
just setns() the mount namespace and circumvent the IMA (appraisal) policy.



> If IMA is to be at all trustworthy for remote appraisal, then I do

remote appraisal ? remote attestation ?

> not see how you can let a privileged insecure container completely
> bypass IMA.  The key difference between allowing new ima_ns with
> mntns or only with userns is that after unsharing my user_ns, my
> privilege with respect to the parent is lost.  A new mntns doesn't
> change anything about how I can corrupt the parent.

Not quite following. After unsharing the user_ns IMA could be made to 
loose access to its keys from the previous user_ns and starting apps 
would fail appraisal then, unless the new user_ns IMA keyring has the 
same keys again.
