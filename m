From: Amir Goldstein <amir73il-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4] Introduce v3 namespaced file capabilities
Date: Tue, 20 Jun 2017 22:56:59 +0300
Message-ID: <CAOQ4uxhi06Yr4XRnKvy34MQhBPJ9GmG0GnyU6aKpb2rLb07sAg@mail.gmail.com>
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
	<CAOQ4uxhi5fezF7e9FpS=hHUb1LqzyCNq9BcG14RV_Srj1hS-Vw@mail.gmail.com>
	<645d3a5e-4b76-cc90-50d6-4a7a7c3b678c@linux.vnet.ibm.com>
	<87dfaf3b-f466-9831-1c76-32d4cabd8cf6@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87dfaf3b-f466-9831-1c76-32d4cabd8cf6-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jun 20, 2017 at 8:33 PM, Stefan Berger
<stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> On 06/20/2017 08:19 AM, Stefan Berger wrote:
>>
>> On 06/20/2017 01:42 AM, Amir Goldstein wrote:

>>>>
>>> Apropos stackable filesystems [cc some overlayfs folks], is there any
>>> way that parts of this work could be generalized towards ns aware
>>> trusted@uid.* xattr?
>>
>>
>> I am at least removing all string comparison with xattr names from the
>> core code and move the enabled xattr names into a list. For the security.*
>> extended attribute names we would enumerated the enabled ones in that list,
>> only security.capability for now. I am not sure how the trusted.* space
>> works.
>
>
> I extended 'the infrastructure' now to support prefix matching for trusted.*
> and probably others as well. It's fairly easy to do that but would not write
> the code like that for exact string matching to support security.capability.
> The patch lets me write trusted.foo@uid=100 from within the userns if
> uid=100 exists, rejects it otherwise. It may be written out as
> trusted.foo@uid=1100 for root mapping to uid 1000. I can list this entry on
> the host. For some reason trusted.* is not listed at all inside the userns.
> So something else needs to be enabled as well. For now it looks like this:
>
>
> https://github.com/stefanberger/linux/commit/8ae131e731c9e1def92a2100697632ea35e007d0
>

That looks useful!
I hope someone who knows his way around trusted xattr can say what's missing.

Thanks,
Amir.
