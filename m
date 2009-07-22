From: Danny Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix reverse unlock sequence in cgroup_get_sb
Date: Wed, 22 Jul 2009 09:42:41 +0800
Message-ID: <4A666E91.4090405__30588.7553644881$1248227013$gmane$org@redhat.com>
References: <1248171926-20232-1-git-send-email-dfeng@redhat.com>
	<20090721111019.GV24157@balbir.in.ibm.com>
	<8522a3d30907210438u6fce081fi835bf964d0c01e8a@mail.gmail.com>
	<20090721120106.GW24157@balbir.in.ibm.com>
	<4A66630C.3030303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A66630C.3030303-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Zefan Li <lizf.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/22/2009 08:53 AM, Li Zefan wrote:
>>>> Seems reasonable to me. You might also want to mention that elsewhere
>>>> the sequence is unlock cgroup_mutex followed by inode->i_mutex.
>>>>
>>>> Acked-by: Balbir Singh balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
>>>>          
>>> No, the unlock order is irrelevant. It's the lock order that matters. So
>>> this patch
>>> fixes nothing.
>>>
>>> Xiaotian, you didn't run into deadlock, did you?
>>>
>>>        
>> Li, Consider the following
>>
>>
>> lock(A)
>> lock(B)
>> unlock(A)
>> unlock(B)
>>
>> Tomorrow if a unsuspecting programmer does this
>>
>> lock(A)
>> lock(B)
>> unlock(A)
>>
>> code block
>>
>> unlock(B)
>>
>>
>> What protects code block? lock B? Is that the intention?
>>
>>      
>
> I won't worry about that. If unlock order is a concern,
> we should have taught lockdep to detect it.
>
> Here's a reply from Linus on this issue:
>
> 	http://lkml.org/lkml/2008/10/8/150
>    
OK, this patch is trivial. Just for consistency with previous unlock 
sequence:-)
