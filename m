From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH v3 1/3] ima: extend clone() with IMA namespace support
Date: Wed, 28 Mar 2018 08:44:51 -0400
Message-ID: <13f08347-36f6-e122-4dd4-d745b34745df__38546.9533656307$1522241003$gmane$org@linux.vnet.ibm.com>
References: <1522159038-14175-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1522159038-14175-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<87sh8lcecn.fsf@xmission.com>
	<bc03161e-394b-bf4d-48c4-858dcf05458a@linux.vnet.ibm.com>
	<20180328121418.GA24712@wind.enjellic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180328121418.GA24712-DHO+NtfOqB5PEDpkEIzg7wC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Dr. Greg Wettstein" <greg-R92VP3DqSWVWk0Htik3J/w@public.gmane.org>
Cc: mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, david.safford-JJi787mZWgc@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On 03/28/2018 08:14 AM, Dr. Greg Wettstein wrote:
> On Wed, Mar 28, 2018 at 07:10:12AM -0400, Stefan Berger wrote:
>
> Good morning, I hope the day is starting out well for everyone.
>
>> On 03/27/2018 07:01 PM, Eric W. Biederman wrote:
>>> Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
>>>
>>>> From: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>>>
>>>> Add new CONFIG_IMA_NS config option.  Let clone() create a new IMA
>>>> namespace upon CLONE_NEWUSER flag. Attach the ima_ns data structure
>>>> to user_namespace. ima_ns is allocated and freed upon IMA namespace
>>>> creation and exit, which is tied to USER namespace creation and exit.
>>>> Currently, the ima_ns contains no useful IMA data but only a dummy
>>>> interface. This patch creates the framework for namespacing the different
>>>> aspects of IMA (eg. IMA-audit, IMA-measurement, IMA-appraisal).
>>> Tying IMA to the user namespace is far better than tying IMA
>>> to the mount namespace.  It may even be the proper answer.
>>>
>>> You had asked what it would take to unstick this so you won't have
>>> problems next time you post and I did not get as far as answering.
>>>
>>> I had a conversation a while back with Mimi and I believe what was
>>> agreed was that IMA to start doing it's thing early needs a write
>>> to securityfs/imafs.
>> Above you say 'proper answer' for user namespace. Now this sounds like
>> making it independent.
>>
>>> As such I expect the best way to create the ima namespace is by simply
>>> writing to securityfs/imafs.  Possibly before the user namespace is
>>> even unshared.  That would allow IMA to keep track of things from
>>> before a container is created.
>> So you are saying to not tie it to user namespace but make it an
>> independent namespace and to not use a clone flag (0x1000) but use
>> the filesystem to spawn a new namespace. Should that be an IMA
>> specific file or a file that can be shared with other subsystems?
> We've been platforming solutions for about 18 months now on top of a
> namespaced IMA implementation that we developed and carry against the
> 4.4.x kernel.  Technically its not an IMA namespace, but rather a
> behavioral namespace, since we implement information exchange event
> modeling, conceptually though its all the same and its origins were
> IMA.

Are you intending to make this publicly available and/or contribute it ?
>
> In some configurations we run unmodified Docker containers inside the
> behavioral/IMA namespace.  So if experience is a useful metric the
> 'integrity' namespace needs to be a first class entity and not
> subordinate or tied to any other resource namespaces.  We would also
> recommend, again based on our experiences, the use of a clone flag.

We have been using a clone flag in the first implementation, the mount 
flag afterwards.We treat containers independent of the host, meaning 
that it has its own policy, independent of the host, and allows for 
signed files inside containers to enable IMA-appraisal. It does require 
modifications to user space applications like Docker that have to pick 
up the file signatures.


>
> FWIW, at this point we have hoisted a lot of the integrity
> functionality out of the kernel and up into userspace so it can be run
> in a trusted execution environment.  There are always the issues with
> kernel<->userspace communication, particularly of the symmetric
> variety, but userspace seems to be a much better place for a lot of
> this functionality.  If the ELF module discussion is any indication it

Like what functionality? Are you supporting IMA-appraisal? Are you doing 
IMA-measurements? What about IMA-audit? Following our intended IMA 
namespacing, all of this would be done in the kernel following an IMA 
policy parsed by the kernel.


> appears as if userspace and the kernel may be destined to become more
> symbiotic in the future.
>
> Just our two cents.
>
>>     Stefan
> Have a good remainder of the week.
>
> Dr. Greg
>
> As always,
> Dr. G.W. Wettstein, Ph.D.   Enjellic Systems Development, LLC.
> 4206 N. 19th Ave.           Specializing in information infra-structure
> Fargo, ND  58102            development.
> PH: 701-281-1686
> FAX: 701-281-3949           EMAIL: greg-R92VP3DqSWVWk0Htik3J/w@public.gmane.org
> ------------------------------------------------------------------------------
> "So you got your butt kicked by an 'old' guy.
>
>   Before you taunted him did it ever cross your mind that the $1200
>   Schmoelke aero-bars he was laying on and the $900 Rocket7 cycling
>   shoes he was wearing might mean that the $10,000 custom bike frame he
>   was riding might be used for more than transportation to the Dairy
>   Queen each night for a Dilly Bar?"
>                                  -- Dr. G.W. Wettstein
>                                     Resurrection
>
