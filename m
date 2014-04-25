From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: pid ns feature request
Date: Fri, 25 Apr 2014 14:23:40 -0700
Message-ID: <CALCETrX9aCxsGs9T6v4kQpG_4sOzse5E2V0RnQeYdmoi22dj8g@mail.gmail.com>
References: <CALCETrVSaboa0Y2v_sTbSz3xOxOZ-6jSq_D7DyQXMRB9VXJB8w@mail.gmail.com>
	<87ha5h42va.fsf@x220.int.ebiederm.org>
	<CALCETrX3GjNkhKkST9Nw4sk2ETt=MRUWcc+bNXnGFTXn7ve-ww@mail.gmail.com>
	<87tx9h2m2w.fsf@x220.int.ebiederm.org>
	<CALCETrU_SE=7QH-rDOqOsB5T4v+VEGL_3ZYRPgt6QWHB5BEGdg@mail.gmail.com>
	<87oazpyupx.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87oazpyupx.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Serge E. Hallyn" <serge-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Apr 25, 2014 at 2:17 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
>
>> On Fri, Apr 25, 2014 at 1:25 PM, Eric W. Biederman
>> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
>>>
>>>> On Fri, Apr 25, 2014 at 12:37 PM, Eric W. Biederman
>>>> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>>>> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
>>>>>
>>>>>> Unless I'm missing some trick, it's currently rather painful to mount
>>>>>> a namespace /proc.  You have to actually be in the pid namespace to
>>>>>> mount the correct /proc instance, and you can't unmount the old /proc
>>>>>> until you've mounted the new /proc.  This means that you have to fork
>>>>>> into the new pid namespace before you can finish setting it up.
>>>>>
>>>>> Yes.  You have to be inside just about all namespaces before you can
>>>>> finish setting them up.
>>>>>
>>>>> I don't know the context in which needed to be inside the pid namespace
>>>>> is a burden.
>>>>
>>>> I'm trying to sandbox myself.  I unshare everything, setup up new
>>>> mounts, pivot_root, umount the old stuff, fork, and wait around for
>>>> the child to finish.
>>>>
>>>> This doesn't work: the parent can't mount the new /proc, and the child
>>>> can't either because it's too late.
>>>>
>>>> The only solution I can think of without kernel changes is to fork the
>>>> child (pid 1) before pivot_root, which makes everything more
>>>> complicated.  I suppose I can unshare, fork immediately, have the
>>>> child set up all the mounts, and then wake the parent, but this is an
>>>> annoying bit of extra complexity for no obvious gain.
>>>
>>> Or perhaps just use clone and clone flags.
>>>
>>> What are you doing with the parent process?  What value does it serve?
>>
>> I'm not entirely sure.  I'm hacking on this thing:
>>
>> https://github.com/amluto/sandstorm/tree/userns
>>
>> which isn't really my code.  But there's an inner sandbox and an outer
>> sandbox, and only the inner sandbox is in a pid namespace.
>>
>> I suppose what what I'm doing is a bit strange.
>
> A bit.   But doing strange things is good.
>
> Right now most of my energy is focused on closely the last of the design
> issues.  So I don't have much energy for new namespace related features
> right now.

No problem.  I may write up the patch, although I'll have to support
current kernels anyway.

--Andy
