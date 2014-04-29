From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: ioctl CAP_LINUX_IMMUTABLE is checked in the wrong namespace
Date: Tue, 29 Apr 2014 16:22:55 -0700
Message-ID: <CALCETrVJY6SWjdbqSSCeOo9oid22TnL83v9oDVg06XLZfPkLCw@mail.gmail.com>
References: <535FADDA.2070803@1h.com> <20140429183534.GB19325@thunk.org>
	<20140429185251.GA27969@ubuntumail> <53601E5B.5050004@1h.com>
	<20140429220234.GC28410@ubuntumail> <536026B3.1020905@1h.com>
	<20140429222913.GD28410@ubuntumail> <53602B84.1020304@mit.edu>
	<536033A9.5070504@1h.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <536033A9.5070504-108MBtLGafw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Marian Marinov <mm-108MBtLGafw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Ted Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Apr 29, 2014 at 4:20 PM, Marian Marinov <mm-108MBtLGafw@public.gmane.org> wrote:
> On 04/30/2014 01:45 AM, Andy Lutomirski wrote:
>>
>> On 04/29/2014 03:29 PM, Serge Hallyn wrote:
>>>
>>> Quoting Marian Marinov (mm-108MBtLGafw-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org):
>>>>
>>>> On 04/30/2014 01:02 AM, Serge Hallyn wrote:
>>>>>
>>>>> Quoting Marian Marinov (mm-108MBtLGafw-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org):
>>>>>>
>>>>>> On 04/29/2014 09:52 PM, Serge Hallyn wrote:
>>>>>>>
>>>>>>> Quoting Theodore Ts'o (tytso-3s7WtUTddSA-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org):
>>>>>>>>
>>>>>>>> On Tue, Apr 29, 2014 at 04:49:14PM +0300, Marian Marinov wrote:
>>>>>>>>>
>>>>>>>>>
>>>>>>>>> I'm proposing a fix to this, by replacing the
>>>>>>>>> capable(CAP_LINUX_IMMUTABLE)
>>>>>>>>> check with ns_capable(current_cred()->user_ns,
>>>>>>>>> CAP_LINUX_IMMUTABLE).
>>>>>>>>
>>>>>>>>
>>>>>>>> Um, wouldn't it be better to simply fix the capable() function?
>>>>>>>>
>>>>>>>> /**
>>>>>>>>   * capable - Determine if the current task has a superior
>>>>>>>> capability in effect
>>>>>>>>   * @cap: The capability to be tested for
>>>>>>>>   *
>>>>>>>>   * Return true if the current task has the given superior
>>>>>>>> capability currently
>>>>>>>>   * available for use, false if not.
>>>>>>>>   *
>>>>>>>>   * This sets PF_SUPERPRIV on the task if the capability is
>>>>>>>> available on the
>>>>>>>>   * assumption that it's about to be used.
>>>>>>>>   */
>>>>>>>> bool capable(int cap)
>>>>>>>> {
>>>>>>>>         return ns_capable(&init_user_ns, cap);
>>>>>>>> }
>>>>>>>> EXPORT_SYMBOL(capable);
>>>>>>>>
>>>>>>>> The documentation states that it is for "the current task", and I
>>>>>>>> can't imagine any use case, where user namespaces are in effect,
>>>>>>>> where
>>>>>>>> using init_user_ns would ever make sense.
>>>>>>>
>>>>>>>
>>>>>>> the init_user_ns represents the user_ns owning the object, not the
>>>>>>> subject.
>>>>>>>
>>>>>>> The patch by Marian is wrong.  Anyone can do 'clone(CLONE_NEWUSER)',
>>>>>>> setuid(0), execve, and end up satisfying
>>>>>>> 'ns_capable(current_cred()->userns,
>>>>>>> CAP_SYS_IMMUTABLE)' by definition.
>>>>>>>
>>>>>>> So NACK to that particular patch.  I'm not sure, but IIUC it should
>>>>>>> be
>>>>>>> safe to check against the userns owning the inode?
>>>>>>>
>>>>>>
>>>>>> So what you are proposing is to replace
>>>>>> 'ns_capable(current_cred()->userns, CAP_SYS_IMMUTABLE)' with
>>>>>> 'inode_capable(inode, CAP_SYS_IMMUTABLE)' ?
>>>>>>
>>>>>> I agree that this is more sane.
>>>>>
>>>>>
>>>>> Right, and I think the two operations you're looking at seem sane
>>>>> to allow.
>>>>
>>>>
>>>> If you are ok with this patch, I will fix all file systems and send
>>>> patches.
>>>
>>>
>>> Sounds good, thanks.
>>>
>>>> Signed-off-by: Marian Marinov <mm-NV7Lj0SOnH0-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org>
>>>
>>>
>>> Acked-by: Serge E. Hallyn
>>> <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org>
>>
>>
>> Wait, what?
>>
>> Inodes aren't owned by user namespaces; they're owned by users.  And any
>> user can arrange to have a user namespace in which they pass an
>> inode_capable check on any inode that they own.
>>
>> Presumably there's a reason that CAP_SYS_IMMUTABLE is needed.  If this
>> gets merged, then it would be better to just drop CAP_SYS_IMMUTABLE
>> entirely.
>
>
> The problem I'm trying to solve is this:
>
> container with its own user namespace and CAP_SYS_IMMUTABLE should be able
> to use chattr on all files witch this container has access to.
>
> Unfortunately with the capable(CAP_SYS_IMMUTABLE) check this is not working.
>
> With the proposed two fixes CAP_SYS_IMMUTABLE started working in the
> container.
>
> The first solution got its user namespace from the currently running process
> and the second gets its user namespace from the currently opened inode.
>
> So what would be the best solution in this case?

I'd suggest adding a mount option like fs_owner_uid that names a uid
that owns, in the sense of having unlimited access to, a filesystem.
Then anyone with caps on a namespace owned by that uid could do
whatever.

Eric?

--Andy
