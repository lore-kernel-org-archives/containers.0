From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/7] [RFC] Support named cgroups hierarchies
Date: Wed, 01 Apr 2009 14:24:36 +0800
Message-ID: <49D308A4.3030302@cn.fujitsu.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>	
	<20090312105122.24154.73633.stgit@menage.corp.google.com>	
	<49BF46BC.4080302@cn.fujitsu.com>
	<6599ad830903310112x626252c4je760a80eb1eaa1d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830903310112x626252c4je760a80eb1eaa1d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

>>> -     /* Next check flags */
>>> -     if (new->flags != root->flags)
>> Is this change intended or unintended? With this change we allow:
>>  # mount -t cgroup -o cpu xxx /mnt1
>>  # mount -t cgroup -o cpu,noprefix xxx /mnt2
>> But files in /mnt2 still prefix with 'cpu.'
> 
> That fits in better with existing semantics for other filesystems - if
> you mount an already-mounted device with different superblock mount
> options, the new mount still has the superblock options associated
> with the old mount.
> 
> Arguably this might mean that we should ignore all options when
> mounting a hierarchy by name that already exists, even if you specify
> a different set of subsystems from what is mounted.
> 

Then I think it's better to make it a different patch, but not hiding
this change in this patch.

>>> +     /* If we asked for subsystems then they must match */
>>> +     if (new->subsys_bits && new->subsys_bits != root->subsys_bits)
>>>               return 0;
>> This has already been checked.
> 
> Where?

My mistake, please ignore. :)
