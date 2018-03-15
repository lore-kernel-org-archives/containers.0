From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH v2 1/3] ima: extend clone() with IMA namespace support
Date: Thu, 15 Mar 2018 15:15:25 -0400
Message-ID: <056e5b9e-b4d3-1862-baea-06dda4bd0713@linux.vnet.ibm.com>
References: <20180309201421.6150-1-stefanb@linux.vnet.ibm.com>
	<20180309201421.6150-2-stefanb@linux.vnet.ibm.com>
	<87vadxfwqj.fsf@xmission.com>
	<c18b6e92-57f0-5994-eb60-5fadc6671832@linux.vnet.ibm.com>
	<1521135192.5348.64.camel@HansenPartnership.com>
	<2183a3b4-6270-d2e9-70ad-a7399eb1681c@linux.vnet.ibm.com>
	<1521139535.5348.89.camel@HansenPartnership.com>
	<0dc5b856-8dc6-7b5a-eeac-febd19f6498c@linux.vnet.ibm.com>
	<1521140467.5348.94.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1521140467.5348.94.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
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

On 03/15/2018 03:01 PM, James Bottomley wrote:
> On Thu, 2018-03-15 at 14:51 -0400, Stefan Berger wrote:
>> On 03/15/2018 02:45 PM, James Bottomley wrote:
> [...]
>>>>> going to need some type of keyring namespace and there's
>>>>> already
>>>>> one hanging off the user_ns:
>>>>>
>>>>> commit f36f8c75ae2e7d4da34f4c908cebdb4aa42c977e
>>>>> Author: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>>>> Date:   Tue Sep 24 10:35:19 2013 +0100
>>>>>
>>>>>        KEYS: Add per-user_namespace registers for persistent
>>>>> per-UID
>>>>> kerberos caches
>>>> The benefit for IMA would be that this would then tie the keys
>>>> needed for appraising to the IMA namespace's policy.
>>>> However, if you have an appraise policy in your IMA namespace,
>>>> which is now hooked to the user namespace, and you join that user
>>>> namespace but your files don't have signatures, nothing will
>>>> execute anymore. That's now a side effect of joining this user
>>>> namespace unless we have a magic  exception. My feeling is,
>>>> people may not like that...
>>> Agree, but I think the magic might be to populate the ima keyring
>>> with the parent on user_ns creation.  That way the user_ns owner
>>> can delete the parent keys if they don't like them, but by default
>>> the parent appraisal policy should just work.
>> That may add keys to your keyring but doesn't get you signatures on
>> your  files.
> But it doesn't need to.  The only way we'd get a failure is if the file
> is already being appraised and we lose access to the key.  If the

Well, the configuration I talked about above was assuming that we have 
an appraisal policy active in the IMA namespace, which is now tied to 
the user namespace that was just joined.

If we are fine with the side effects of an IMA policy active as part of 
a user namespace then let's go with it. The side effects in case of an 
active IMA appraisal may then be that files cannot be read/accessed, or 
file measurements or IMA auditing may occur.

The alternative is we have an independent IMA namespace. If one joins 
the USER namespace and there are no IMA-related side effects. If one 
joins the IMA namespace its IMA policy should start being enforced. If 
the current active USER namespace has the keys that go with the 
signatures of the filesystem, then we're fine from the appraisal 
perspective. If not, then IMA namespace joining may prevent file accesses.

> parent policy isn't appraisal, entering the IMA NS won't cause

Why parent policy? The policy of the namespace that was joined should be 
the active one, no ?

> appraisal to be turned on unless the owner asks for it, in which case
> it's caveat emptor: As it works today, if as root I add a default
> appraisal policy to IMA without either a key or xattrs, I get an
> unusable system.

    Stefan

>
> James
>
