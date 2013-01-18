From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH RESEND] userns: enable tmpfs support for user namespace
Date: Thu, 17 Jan 2013 22:10:03 -0800
Message-ID: <50F8E73B.7000903@parallels.com>
References: <1358331945-4106-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20130116143532.GA4035@sergelap> <50F74EC6.60004@cn.fujitsu.com>
	<20130117171451.GA31219@sergelap> <87fw1zbd03.fsf@xmission.com>
	<20130118042404.GA15079@sergelap> <87vcavys6k.fsf@xmission.com>
	<50F8DEBF.1020701@parallels.com> <87ip6vyqkf.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ip6vyqkf.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 01/17/2013 10:04 PM, Eric W. Biederman wrote:
> Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
> 
>> On 01/17/2013 09:29 PM, Eric W. Biederman wrote:
>>> Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
>>>
>>>> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>>>>> Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
>>>>>
>>>>>> I actually was waiting for Eric to do it, but I'll happily send it
>>>>>> to linux-fsdevel and lkml (in a bit).
>>>>>
>>>>> I might just.
>>>>>
>>>>> I will take a look at this in a week or so.  I want to get through the
>>>>> core userspace bits first so I can just cross those off my list of
>>>>> things that need to be done.
>>>>>
>>>>> Eric
>>>>
>>>> Ok, I'll wait on sending it then - thanks.
>>>
>>> Next up is my patch to shadow-utils and then taking a good hard stare at
>>> what is left kernel side.
>>>
>>> One of the questions I need to answer is:  Do cgroups actually work
>>> for what needs to be limited?  Or does the the focus of cgroups on
>>> processes without other ownership in objects fundamentally limit what
>>> can be expressed with cgroups in a problematic way.  In which case would
>>> some hierarchical limits based on user namespaces and rlimits be easier
>>> to implement and make more sense.
>>>
>>> I think the answer will be that cgroups are good enough but that
>>> question certainly needs looking at.
>>>
>>> Anyway.  shadow-utils, minimal tmpfs, minimal devpts, and then the rest.
>>>
>> First easy question:
>>
>> cgroups are not necessarily configured.
>>
>> IIUC, the aim of this patch is to allow unprivileged mounts of tmpfs
>> relying on the fact that cgroups will stop memory abuse (correct me if I
>> am wrong).
>>
>> But what if the user is not using cgroups?
> 
> The requirement for tmpfs to be safe is that there should be a control
> that root can use to prevent DOS attacks.  If you don't choose to use
> what is available then shrug.
> 

Yes, but if you are an unprivileged user, the whole box would go down,
not just your namespace/container/group, etc.

So at first it seems to me very risky to allow an unprivileged mount of
something that may or may not be constrained. IOW: not depending on
cgroups and relying solely on namespaces to achieve seems better at first.
