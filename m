From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC] Per-user namespace process accounting
Date: Tue, 3 Jun 2014 21:39:20 +0400
Message-ID: <538E0848.6060900@parallels.com>
References: <5386D58D.2080809@1h.com> <87tx88nbko.fsf@x220.int.ebiederm.org>
	<53870EAA.4060101@1h.com> <20140529153232.GB9714@ubuntumail>
	<538DFF72.7000209@parallels.com> <20140603172631.GL9714@ubuntumail>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140603172631.GL9714@ubuntumail>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LXC development mailing-list <lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 06/03/2014 09:26 PM, Serge Hallyn wrote:
> Quoting Pavel Emelyanov (xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
>> On 05/29/2014 07:32 PM, Serge Hallyn wrote:
>>> Quoting Marian Marinov (mm-108MBtLGafw@public.gmane.org):
>>>> -----BEGIN PGP SIGNED MESSAGE-----
>>>> Hash: SHA1
>>>>
>>>> On 05/29/2014 01:06 PM, Eric W. Biederman wrote:
>>>>> Marian Marinov <mm-108MBtLGafw@public.gmane.org> writes:
>>>>>
>>>>>> Hello,
>>>>>>
>>>>>> I have the following proposition.
>>>>>>
>>>>>> Number of currently running processes is accounted at the root user namespace. The problem I'm facing is that
>>>>>> multiple containers in different user namespaces share the process counters.
>>>>>
>>>>> That is deliberate.
>>>>
>>>> And I understand that very well ;)
>>>>
>>>>>
>>>>>> So if containerX runs 100 with UID 99, containerY should have NPROC limit of above 100 in order to execute any 
>>>>>> processes with ist own UID 99.
>>>>>>
>>>>>> I know that some of you will tell me that I should not provision all of my containers with the same UID/GID maps,
>>>>>> but this brings another problem.
>>>>>>
>>>>>> We are provisioning the containers from a template. The template has a lot of files 500k and more. And chowning
>>>>>> these causes a lot of I/O and also slows down provisioning considerably.
>>>>>>
>>>>>> The other problem is that when we migrate one container from one host machine to another the IDs may be already
>>>>>> in use on the new machine and we need to chown all the files again.
>>>>>
>>>>> You should have the same uid allocations for all machines in your fleet as much as possible.   That has been true
>>>>> ever since NFS was invented and is not new here.  You can avoid the cost of chowning if you untar your files inside
>>>>> of your user namespace.  You can have different maps per machine if you are crazy enough to do that.  You can even
>>>>> have shared uids that you use to share files between containers as long as none of those files is setuid.  And map
>>>>> those shared files to some kind of nobody user in your user namespace.
>>>>
>>>> We are not using NFS. We are using a shared block storage that offers us snapshots. So provisioning new containers is
>>>> extremely cheep and fast. Comparing that with untar is comparing a race car with Smart. Yes it can be done and no, I
>>>> do not believe we should go backwards.
>>>>
>>>> We do not share filesystems between containers, we offer them block devices.
>>>
>>> Yes, this is a real nuisance for openstack style deployments.
>>>
>>> One nice solution to this imo would be a very thin stackable filesystem
>>> which does uid shifting, or, better yet, a non-stackable way of shifting
>>> uids at mount.
>>
>> I vote for non-stackable way too. Maybe on generic VFS level so that filesystems 
>> don't bother with it. From what I've seen, even simple stacking is quite a challenge.
> 
> Do you have any ideas for how to go about it?  It seems like we'd have
> to have separate inodes per mapping for each file, which is why of
> course stacking seems "natural" here.

I was thinking about "lightweight mapping" which is simple shifting. Since
we're trying to make this co-work with user-ns mappings, simple uid/gid shift
should be enough. Please, correct me if I'm wrong.

If I'm not, then it looks to be enough to have two per-sb or per-mnt values
for uid and gid shift. Per-mnt for now looks more promising, since container's
FS may be just a bind-mount from shared disk.

> Trying to catch the uid/gid at every kernel-userspace crossing seems
> like a design regression from the current userns approach.  I suppose we
> could continue in the kuid theme and introduce a iiud/igid for the
> in-kernel inode uid/gid owners.  Then allow a user privileged in some
> ns to create a new mount associated with a different mapping for any
> ids over which he is privileged.

User-space crossing? From my point of view it would be enough if we just turn
uid/gid read from disk (well, from whenever FS gets them) into uids, that would
match the user-ns's ones, this sould cover the VFS layer and related syscalls
only, which is, IIRC stat-s family and chown.

Ouch, and the whole quota engine :\

Thanks,
Pavel
