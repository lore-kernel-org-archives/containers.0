From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [REVIEW][PATCH 1/2] userns: Better restrictions on when proc
	and sysfs can be mounted
Date: Fri, 15 Nov 2013 14:14:58 +0800
Message-ID: <5285BBE2.7010001@cn.fujitsu.com>
References: <878uzmhkqg.fsf@xmission.com>
	<52749663.2000701@cn.fujitsu.com>	<527C4D88.10907@cn.fujitsu.com>
	<87k3gigmgj.fsf@xmission.com>	<5283299B.8080702@cn.fujitsu.com>
	<5284AF90.7060506@cn.fujitsu.com>	<CALCETrXtWtF=JgiwENNzh7UZKnXijHauOQ5ZjHYxYJC-BAU5Aw@mail.gmail.com>	<528575EC.2030309@cn.fujitsu.com>
	<87txfexo25.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87txfexo25.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On 11/15/2013 12:54 PM, Eric W. Biederman wrote:
> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
> 
>> On 11/15/2013 12:54 AM, Andy Lutomirski wrote:
>>> On Thu, Nov 14, 2013 at 3:10 AM, Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>>> On 11/13/2013 03:26 PM, Gao feng wrote:
>>>>> On 11/09/2013 01:42 PM, Eric W. Biederman wrote:
>>>>>> Right now I would rather not have the empty directory exception than
>>>>>> remove this code.
>>>>>>
>>>>>> The test is a little trickier to write than it might otherwise be
>>>>>> because /proc and /sys tend to be slightly imperfect filesystems.
>>>>>>
>>>>>> I think the only way to really test that is to call readdir on the
>>>>>> directory itself :(  I don't like that thought.
>>>>>>
>>>>>> I don't know what I was thinking when I wrote that test but I definitely
>>>>>> goofed up.  Grr!
>>>>>>
>>>>>> I can certainly filter out any directory with nlink > 2.  That would be
>>>>>> an easy partial step forward.
>>>>>>
>>>>>> The real question though is how do I detect directories it is safe to
>>>>>> mount on where there will not be files in them.  I can't call iterate
>>>>>> with the namespace_lock held so things are a bit tricky.
>>>>>>
>>>>>
>>>>> I know this problem is not easy to be resolved. why not let the user
>>>>> make the decision?  maybe we can introduce a new mount option MS_LOCK,
>>>>> if user wants to use mount to hide something, he should use mount with
>>>>> option MS_LOCK. so the unpriviged user can't umount this filesystem and
>>>>> fail to mount the filesystem if one of it's child mount is mounted with
>>>>> MS_LOCK option otherwise he use MS_REC too.
>>>>>
>>>>
>>>> Something like this.
>>>>
>>>> From 437f33ea366623c7a9d557b2e84cae424876a44f Mon Sep 17 00:00:00 2001
>>>> From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>>>> Date: Wed, 13 Nov 2013 16:06:46 +0800
>>>> Subject: [PATCH] userns: introduce new mount option MS_LOCK
>>>>
>>>> After commit 5ff9d8a65ce80efb509ce4e8051394e9ed2cd942
>>>> vfs: Lock in place mounts from more privileged users,
>>>> in userns, the mounts of child mntns which copied from
>>>> parent mntns is locked and user has no rights to umount/move
>>>> them, it's too strict.
>>>>
>>>> The core purpose of above commit is trying to prevent
>>>> unprivileged user from accessing files hidden by mount.
>>>> This patch introduces a new mount option MS_LOCK, this
>>>> gives user the capable to mount filesystem as the type
>>>> of lock if he wants to use mount to hide something.
>>>>
>>>
>>> This is bad -- if something was secure in old kernels, it needs to
>>> stay secure.  If you had MS_NOT_A_LOCK, that would be okay, but it
>>> might not solve your problem.
>>>
>>
>> what you mean old kernels here? I saw patch "vfs: Lock in place mounts from more privileged users"
>> is merged into upstream in linux 3.12-rc1, this is not very old. I think there
>> are not many userspace processes rely on this feature.
> 
> Sort of true.  Most people aren't that silly.  This feature was added to
> defend against a theoretical attack that you can use with mount
> namespaces.
> 
> In particular the scenario we are concerned with is:
> 
> Suppose the file system looks like:
> 
> Suppose there are two filesystems a and b that look like:
> 
> a:/usr/
> a:/usr/my_very_secret_file
> a:/dev/
> a:/etc/
> a:/lib/
> 
> b:/bin/
> b:/etc/
> b:/games/
> b:/include/
> b:/lib/
> b:/lib32/
> b:/local/
> b:/sbin/
> b:/share/
> b:/src/
> 
> And filesystem b is mounted on a:/usr hiding a:/usr/my_very_secret_file
> 
> So the filesystem looks like:
> 
> /usr/
> /usr/bin/
> /usr/etc/
> /usr/games/
> /usr/include/
> /usr/lib/
> /usr/lib32/
> /usr/local/
> /usr/sbin/
> /usr/share/
> /usr/src/
> /dev/
> /etc/
> /lib/
> 
> Without locking mounts into place an unprivileged user can clone the
> mount namespace and do "umount /usr" and read /usr/my_very_secret_file.
> 
> Most systems don't hide sensitive things with mounts but it is very
> possible and guarding against is fairly cheap and easy.  And while a
> little annoying it should not be a large impediment to unprivileged user
> of the user namespace because pivot root still works.
> 
> This thread started talking about bugs in fs_fully_visible.  And those
> bugs are fixable and I aim to get to them shortly.  At the very least
> I can lie and test for nlink <= 2 which fixes the regression in mounting
> proc.
> 
> Then I can write the fun version that takes references and drops locks
> so it can call the internal version of readdir to see if a directory is
> actually empty.
> 
> But the principle remains the same we really don't want to reveal
> anything that is hidden under a mount on purpose or by mistake.  Just
> because then we don't have to think about those things from a security
> point of view making everyone's life easier.
> 

Ok,I agree with you that we should make container security by default.

What's your idea that introduces option MS_NOT_A_LOCK just like Andy's
advisement?

In libvirt, host creates dev and devpts directories for container,then
mount devpts, tmpfs on them and create device nodes inside these dirs
for container. and then in container, these filesystems are moved to
container's /dev/ /dev/pts directory. We really have no need to lock
these mounts. they are just created for container.

Thanks
