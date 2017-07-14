From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Fri, 14 Jul 2017 13:17:08 -0500
Message-ID: <8760euyjbv.fsf__36007.9655809843$1500056720$gmane$org@xmission.com>
References: <87y3rscz9j.fsf@xmission.com>
	<20170713164012.brj2flnkaaks2oci@thunk.org>
	<87k23cb6os.fsf@xmission.com>
	<847ccb2a-30c0-a94c-df6f-091c8901eaa0@linux.vnet.ibm.com>
	<87bmoo8bxb.fsf@xmission.com>
	<9a3010e5-ca2b-5e7a-656b-fcc14f7bec4e@linux.vnet.ibm.com>
	<87h8yf7szd.fsf@xmission.com>
	<65dbe654-0d99-03fa-c838-5a726b462826@linux.vnet.ibm.com>
	<20170714133437.GA16737@mail.hallyn.com>
	<596f808b-e21d-8296-5fef-23c1ce7ab778@linux.vnet.ibm.com>
	<20170714173556.GA19669@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170714173556.GA19669-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Fri, 14 Jul 2017 12:35:56 -0500")
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
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, Mimi Zohar <zohar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Stefan Berger (stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>> On 07/14/2017 09:34 AM, Serge E. Hallyn wrote:
>> >Quoting Stefan Berger (stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>> >>On 07/13/2017 08:38 PM, Eric W. Biederman wrote:
>> >>>Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
>> >>>
>> >>>>On 07/13/2017 01:49 PM, Eric W. Biederman wrote:
>> >>>>
>> >>>>>My big question right now is can you implement Ted's suggested
>> >>>>>restriction.  Only one security.foo or secuirty.foo@... attribute ?
>> >>>>We need to raw-list the xattrs and do the check before writing them. I am fairly sure this can be done.
>> >>>>
>> >>>>So now you want to allow security.foo and one security.foo@uid=<> or just a single one security.foo(@[[:print:]]*)?
>> >>>>
>> >>>The latter.
>> >>That case would prevent a container user from overriding the xattr
>> >>on the host. Is that what we want? For limiting the number of xattrs
>> >Not really.  If the file is owned by a uid mapped into the container,
>> >then the container root can chown the file which will clear the file
>> >capability, after which he can set a new one.  If the file is not
>> >owned by a uid mapped into the container, then container root could
>> >not set a filecap anyway.
>> 
>> Let's say I installed a container where all files are signed and
>> thus have security.ima. Now for some reason I want to re-sign some
>> or all files inside that container. How would I do that ? Would I
>> need to get rid of security.ima first, possibly by copying each
>> file, deleting the original file, and renaming the copied file to
>> the original name, or should I just be able to write out a new
>> signature, thus creating security.ima@uid=1000 besides the
>> security.ima ?
>> 
>>    Stefan
>
> Hi Mimi,
>
> what do you think makes most sense for IMA?

I am going to give my two cents since I have been thinking about this.

First I think this entire scheme plays hobs with the security.evm
attribute as security.evm needs to know the names of the xattrs to
protect.

I forget which attributes has a hash and what has a message
athentication code.

If there is an attribute with a simple file hash I think it only make
sense for the kernel to touch it, and I don't see any sense in having
multiples.

If there is an attribute with a message authentication code (roughly a
signed hash) it makes sense to have that to be tied to the kernel key
ring that controlls the keys.  (Which probably means a per user
namespace thing at some point).  But again pretty untouchable otherwise.

Which brings us to the semantic question of would it be nice to have
stacked IMA/EVM on the same file.

I really don't think we do.  I think allowing multiple keys for
different part of trusting files is easy enough that we should have no
need to fight over which keys do which.

Looking at integrity.h I see signature_v2_hdr that has a keyid.  Any use
case I can think of for distributing a distribution image with ima/evm
xattrs will need to use asymmetric keys aka public/private keypairs so
that the originator of the content does not give away their private
keys.

Given that usefully we are talking about content that should be
connected to keys in one way or another I don't believe it even makes
sense at this point to attempt to use uids for dealing with ima and
evm content.

Further looking Serge's previous patch is 300 lines of code Setfan's
patch that provides the possibility of code resuse is 500 lines of code.

Increasingly it is looking to me that code reuse rather than concept
reuse is a false economy.  The code does not get smaller.  The semantic
differences make it problematic.  Possibly to the problematic to the
point where significant pieces may not be reused.  The format breaks
assumptions for other parts of the code like security.evm.  The format
by multiple names instead of a single attribute requires more disk
access so is less efficient.

In short I am seeing more code that runs slower and is harder to
maintain.  Please point out where I am wrong.

Eric
