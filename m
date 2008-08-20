From: Takuya Yoshikawa <yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Subject: Re: RFC: Attaching threads to cgroups is OK?
Date: Wed, 20 Aug 2008 14:52:38 +0900
Message-ID: <48ABB126.8000606@oss.ntt.co.jp>
References: <48AAA296.8050802@oss.ntt.co.jp>
	<20080819202237.edd75933.kamezawa.hiroyu@jp.fujitsu.com>
	<48AABC31.7070207@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48AABC31.7070207-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Thank you for comments and links!

Balbir Singh wrote:
> KAMEZAWA Hiroyuki wrote:
>>> I mean, in the current implementation, threads created before the 
>>> attachement of the parent process are not treated eaqually to those 
>>> created after.
>>>
>>> Could you tell me if you know something about the rules of attachement 
>>> of pid, or tid, to cgroups? -- what ID is OK to write to "tasks" file 
>>> and what we can expect as a result?
>>>
>> Any PID is ok for "tasks". IIRC, Paul proposed "procs" file, which support
>> moving all threads of the same PIDs.
>> This mail from Paul explains some : http://lwn.net/Articles/289930/
>>
> 
> Yes, this was also discussed at the containers mini-summit
> 
> Please see
> http://groups.google.com/group/fa.linux.kernel/browse_thread/thread/ccb5e818209af143
> 

I read the discussions and understood the reasons.

>>> Tsuruta-san, how about your bio-cgroup's tracking concerning this?
>>> If we want to use your tracking functions for each threads seperately, 
>>> there seems to be a problem.
>>> ===cf. mm_get_bio_cgroup()===================
>>>            owner
>>> mm_struct ----> task_struct ----> bio_cgroup
>>> =============================================
>>> In my understanding, the mm_struct of a thread is same as its parent's.
>>> So, even if we attach the TIDs of some threads to different cgroups the 
>>> tracking always returns the same bio_cgroup -- its parent's group.
>>> Do you have some policy about in which case we can use your tracking?
>>>
>> It's will be resitriction when io-controller reuse information of the owner
>> of memory. But if it's very clear who issues I/O (by tracking read/write
>> syscall), we may have chance to record the issuer of I/O to page_cgroup
>> struct. 
> 
> We already do some tracking (at dirty time, IIRC) for task IO accounting. For
> the memory controller, tasks are virtually grouped by the mm_struct.
> 

I understand that controlling threads with their parent through the 
common mm_struct is useful and in some sense reasonable. But the 
following situation seems to me little bit confusing.

TWO POSSIBLE WAYS OF CONTROL -- after the parent process was moved
===================================================================
NEW group: [parent process]----> COMMON mm_struct
                              |
OLD group: [threads]---------+

Threads can be
1. grouped by OLD group
2. (virtually) grouped by mm_struct
    --> same as grouped by NEW group
===================================================================
