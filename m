From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: storage considerations
Date: Wed, 04 Feb 2009 18:04:06 -0500
Message-ID: <498A1EE6.3000204@cs.columbia.edu>
References: <7B7881568CF40E4388B615CD06F87B980989E9@clara.maurer-it.com>	<49887307.1080105@free.fr>
	<20090204160518.GC2039@us.ibm.com> <4989C7C0.6060906@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4989C7C0.6060906-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org



Daniel Lezcano wrote:
> Serge E. Hallyn wrote:
>> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
>>   
>>> Dietmar Maurer wrote:
>>>     
>>>> Hi Daniel,
>>>>
>>>> I think we should have several options for the root storage:
>>>>
>>>> 1.) simply use the host filesystem (like Openvz)
>>>>
>>>> 	- special quota support is needed (simfs?)
>>>>
>>>> 	- quota support depends on ext3 fs, so this only works for
>>>> 	  local attached storage (does not work on NFS)
>>>>
>>>> 	- LVM snapshots are slow, because the snapshot includes all
>>>> container
>>>> 	  on that filesystem.
>>>>       
>> I'm looking forward to the btrfs, tux3, and nilfs snapshotting
>> capabilities.
>>   
> Interesting, especially the nilfs.
> The COW file systems is missing in the linux kernel. Do you think the 
> btrfs has a chance to go to mainline ?

We've been using NILFS (v1) for 2 years already with Zap, and it works
quite well. We had to make slight (trivial) changes to be able to
control it nicely for c/r purposes.

See our DejaView paper at
	http://www.ncl.cs.columbia.edu/publications/sosp2007_dejaview.pdf

Oren.
