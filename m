From: John Johansen <john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [RFC PATCH v3 1/3] ima: extend clone() with IMA namespace support
Date: Wed, 18 Apr 2018 08:59:01 -0700
Message-ID: <cdb2a5b2-f0e8-e7ba-7b76-bd295dc654ad__28035.3161892437$1524067059$gmane$org@canonical.com>
References: <1522159038-14175-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1522159038-14175-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<87sh8lcecn.fsf@xmission.com>
	<bc03161e-394b-bf4d-48c4-858dcf05458a@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <bc03161e-394b-bf4d-48c4-858dcf05458a-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Content-Language: en-GB
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, david.safford-JJi787mZWgc@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On 03/28/2018 04:10 AM, Stefan Berger wrote:
> On 03/27/2018 07:01 PM, Eric W. Biederman wrote:
>> Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
>>
>>> From: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>>
>>> Add new CONFIG_IMA_NS config option.=A0 Let clone() create a new IMA
>>> namespace upon CLONE_NEWUSER flag. Attach the ima_ns data structure
>>> to user_namespace. ima_ns is allocated and freed upon IMA namespace
>>> creation and exit, which is tied to USER namespace creation and exit.
>>> Currently, the ima_ns contains no useful IMA data but only a dummy
>>> interface. This patch creates the framework for namespacing the differe=
nt
>>> aspects of IMA (eg. IMA-audit, IMA-measurement, IMA-appraisal).
>> Tying IMA to the user namespace is far better than tying IMA
>> to the mount namespace.=A0 It may even be the proper answer.
>>
>>
>> You had asked what it would take to unstick this so you won't have
>> problems next time you post and I did not get as far as answering.
>>
>> I had a conversation a while back with Mimi and I believe what was
>> agreed was that IMA to start doing it's thing early needs a write
>> to securityfs/imafs.
> =

> Above you say 'proper answer' for user namespace. Now this sounds like ma=
king it independent.
> =

Agreed, and if we want to broaden out to LSMs implementing namespacing keep=
ing them independent is the correct solution

>>
>> As such I expect the best way to create the ima namespace is by simply
>> writing to securityfs/imafs.=A0 Possibly before the user namespace is
>> even unshared.=A0 That would allow IMA to keep track of things from
>> before a container is created.
> =

> So you are saying to not tie it to user namespace but make it an independ=
ent namespace and to not use a clone flag (0x1000) but use the filesystem t=
o spawn a new namespace. Should that be an IMA specific file or a file that=
 can be shared with other subsystems?
> =


A clone flag could work for IMA, but I don't see it working for all the LSM=
s looking at or doing namespacing, especially if the stacking work ever lan=
ds.

As for using an IMA specific file vs shared with the other subsystems, I th=
ink subsystem specific makes sense, that or we are going to have to design =
something that can be shared if LSM stacking ever lands.
