From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix reverse unlock sequence in cgroup_get_sb
Date: Wed, 22 Jul 2009 10:18:28 +0800
Message-ID: <4A6676F4.7070201__40361.2684378915$1248229268$gmane$org@cn.fujitsu.com>
References: <1248171926-20232-1-git-send-email-dfeng@redhat.com>
	<6599ad830907210903q7206cac2l83a9139d19c5e1a@mail.gmail.com>
	<4A667218.7040105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A667218.7040105-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Danny Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Danny Feng wrote:
> On 07/22/2009 12:03 AM, Paul Menage wrote:
>> On Tue, Jul 21, 2009 at 3:25 AM, Xiaotian Feng<dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>  wrote:
>>> In cgroup_get_sb, the lock sequence is:
>>>         mutex_lock(&inode->i_mutex);
>>>         mutex_lock(&cgroup->mutex);
>>> so the last unlock sequence should be:
>>
>> Make this "so for consistency the last ..." ?
>>
>> Maybe make the patch title "Make unlock sequence in cgroup_get_sb
>> consistent" so someone looking through the change logs for fixes to
>> backport doesn't wrongly thing that this fixes any bug"?
>>
> 
> Yep, this is a trivial patch.  Modified following your suggestion, thank
> you.
> 

As far as it's not declared as a fix, I has no objection to this
patch.

Please always inline the patch in the mail body. And when resending
the patch, add the acked-by you collected in it:

Acked-by: Balbir ...
Acked-by: Paul ...
Signed-off-by: Xiaotian ...

You may resend the patch to Andrew Morton, who picks up cgroup
patches, otherwise the patch may be overlooked.

>>>         mutex_unlock(&cgroup->mutex);
>>>         mutex_unlock(&inode->i_mutex);
>>>
>>> Signed-off-by: Xiaotian Feng<dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>
>> Acked-by: Paul Menage<menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>
>> Paul
> 
